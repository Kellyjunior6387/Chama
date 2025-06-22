import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Types "./types";
import Storage "./storage";
import Debug "mo:base/Debug";
import Order "mo:base/Order";
import Error "mo:base/Error";
import Int "mo:base/Int";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";

module {
    public type ContributionStatus = {
        #Paid;
        #Unpaid;
        #PendingVerification;
    };

    public type ContributionResult = {
        status : Text;
        contributionAmount : Nat;
        receiver : ?Principal;
        nextPayoutDate : ?Int;
        transactionId : ?Text;
    };

    public type RoundStatus = {
        #Active;
        #Complete;
        #Pending;
    };

    public type RoundInfo = {
        roundNumber : Nat;
        receiver : Principal;
        expectedContributions : Nat;
        currentContributions : Nat;
        startTime : Int;
        endTime : ?Int;
        status : RoundStatus;
    };

    public type DateInfo = {
        year : Nat;
        month : Nat;
        day : Nat;
        hour : Nat;
        minute : Nat;
        second : Nat;
    };

    public type ReceiverInfo = {
        principal : Principal;
        name: Text;
        expectedAmount : Nat;
        dueDate : DateInfo;
        status : Text;
    };

    private type StateTransition = {
        #Initialize;
        #Complete;
        #Reset;
    };

    private type ChamaState = {
        currentRound : RoundInfo;
        receiverHistory : [Principal];
    };

    public type MemberDetails = {
        id : Principal;
        name : Text;
        contributed : Nat;
        receivedPayout : Bool;
    };
    public type ChamaSummary = {
    id : Nat;
    name : Text;
    owner : Principal;
    ownerName : Text;
    memberCount : Nat;
    isCurrentUserOwner : Bool;
    joinedDate : Int;  // Timestamp when the user joined
    totalContributed : Nat;
    currentRound : ?{
        roundNumber : Nat;
        receiver : Principal;
        receiverName : Text;
        expectedContributions : Nat;
        currentContributions : Nat;
        startTime : Int;
        status : RoundStatus;
    };
};

    public class ContributionLogic(storage : Storage.Storage) {
        private let CONTRIBUTION_AMOUNT : Nat = 100_000_000; // 1 ICP = 100_000_000 e8s
        private let MIN_MEMBERS_FOR_CONTRIBUTION : Nat = 2;
        private var lastPayoutTime : Int = 0;

        private var chamaStates = HashMap.HashMap<Nat, ChamaState>(10, Nat.equal, Hash.hash);
        private var currentReceivers = HashMap.HashMap<Nat, Principal>(10, Nat.equal, Hash.hash);
        private var chamaRounds = HashMap.HashMap<Nat, RoundInfo>(10, Nat.equal, Hash.hash);

        // Centralized Chama validation
        private func validateChama(chamaId : Nat) : Types.Result<Types.Chama, Text> {
            switch(storage.getChama(chamaId)) {
                case(null) { #err("Chama not found") };
                case(?chama) {
                    if (Array.size(chama.members) < MIN_MEMBERS_FOR_CONTRIBUTION) {
                        #err("Minimum " # Nat.toText(MIN_MEMBERS_FOR_CONTRIBUTION) # " members required")
                    } else {
                        #ok(chama)
                    };
                };
            };
        };

        // Helper function for Int to Nat conversion
        private func intToNat(x : Int) : Nat {
            if (x < 0) { 0 } else { Int.abs(x) };
        };

        // Time conversion helper
        private func timestampToDateInfo(timestamp : Int) : DateInfo {
            let seconds = timestamp / 1_000_000_000;
            let secondsPerDay = 86_400;
            let secondsPerHour = 3_600;
            let secondsPerMinute = 60;

            let days = seconds / secondsPerDay;
            let years = 1970 + (days / 365);
            let month = ((days % 365) / 30) + 1;
            let day = ((days % 365) % 30) + 1;

            let remainingSeconds = seconds % secondsPerDay;
            let hour = remainingSeconds / secondsPerHour;
            let minute = (remainingSeconds % secondsPerHour) / secondsPerMinute;
            let second = remainingSeconds % secondsPerMinute;

            {
                year = intToNat(years);
                month = intToNat(month);
                day = intToNat(day);
                hour = intToNat(hour);
                minute = intToNat(minute);
                second = intToNat(second);
            }
        };
        // Unified receiver selection logic
        private func selectReceiver(chamaId : Nat, transition : StateTransition) : Types.Result<Principal, Text> {
            switch(validateChama(chamaId)) {
                case(#err(e)) { #err(e) };
                case(#ok(chama)) {
                    let state = switch(chamaStates.get(chamaId)) {
                        case(null) {
                            if (transition != #Initialize) {
                                return #err("Invalid state transition");
                            };
                            {
                                currentRound = {
                                    roundNumber = 1;
                                    receiver = chama.members[0].id;
                                    expectedContributions = Array.size(chama.members) - 1;
                                    currentContributions = 0;
                                    startTime = Time.now();
                                    endTime = null;
                                    status = #Active;
                                };
                                receiverHistory = [chama.members[0].id];
                            };
                        };
                        case(?existingState) {
                            switch(transition) {
                                case(#Complete) {
                                    let eligibleMembers = Array.filter<Types.Member>(
                                        chama.members,
                                        func(m : Types.Member) : Bool {
                                            // Using find to check if principal is NOT in receiverHistory
                                            Array.find<Principal>(
                                                existingState.receiverHistory,
                                                func(p : Principal) : Bool { Principal.equal(p, m.id) }
                                            ) == null  // If find returns null, the principal wasn't found
                                        }
                                    );
                                    if (Array.size(eligibleMembers) == 0) {
                                        // Reset cycle when all members have been receivers
                                        let newReceiver = Array.find<Types.Member>(
                                            chama.members,
                                            func(m : Types.Member) : Bool {
                                                not Principal.equal(m.id, existingState.currentRound.receiver)
                                            }
                                        );

                                        switch(newReceiver) {
                                            case(null) { return #err("No eligible receiver found") };
                                            case(?member) {
                                                {
                                                    currentRound = {
                                                        roundNumber = existingState.currentRound.roundNumber + 1;
                                                        receiver = member.id;
                                                        expectedContributions = Array.size(chama.members) - 1;
                                                        currentContributions = 0;
                                                        startTime = Time.now();
                                                        endTime = null;
                                                        status = #Active;
                                                    };
                                                    receiverHistory = [member.id];
                                                };
                                            };
                                        };
                                    } else {
                                        let newReceiver = eligibleMembers[0].id;
                                        {
                                            currentRound = {
                                                roundNumber = existingState.currentRound.roundNumber + 1;
                                                receiver = newReceiver;
                                                expectedContributions = Array.size(chama.members) - 1;
                                                currentContributions = 0;
                                                startTime = Time.now();
                                                endTime = null;
                                                status = #Active;
                                            };
                                            receiverHistory = Array.append(existingState.receiverHistory, [newReceiver]);
                                        };
                                    };
                                };
                                case(_) { existingState };
                            };
                        };
                    };

                    chamaStates.put(chamaId, state);
                    currentReceivers.put(chamaId, state.currentRound.receiver);
                    chamaRounds.put(chamaId, state.currentRound);
                    #ok(state.currentRound.receiver)
                };
            };
        };

        // Core contribution processing
        public func processContribution(chamaId : Nat, caller : Principal) : async* Types.Result<ContributionResult, Text> {
            switch(validateChama(chamaId)) {
                case(#err(e)) { #err(e) };
                case(#ok(chama)) {
                    // Verify membership
                    let isMember = Array.find<Types.Member>(
                        chama.members,
                        func(m : Types.Member) : Bool { Principal.equal(m.id, caller) }
                    );

                    switch(isMember) {
                        case(null) { #err("Not a member of this Chama") };
                        case(?member) {
                            let state = switch(chamaStates.get(chamaId)) {
                                case(null) {
                                    // Initialize first round
                                    switch(selectReceiver(chamaId, #Initialize)) {
                                        case(#err(e)) { return #err(e) };
                                        case(#ok(_)) {
                                            switch(chamaStates.get(chamaId)) {
                                                case(null) { return #err("Failed to initialize round") };
                                                case(?s) { s };
                                            };
                                        };
                                    };
                                };
                                case(?s) { s };
                            };

                            if (Principal.equal(caller, state.currentRound.receiver)) {
                                return #err("Current receiver cannot contribute");
                            };

                            if (state.currentRound.status != #Active) {
                                return #err("Round is not active");
                            };

                            // Process contribution
                            let contributionResult = await* handleContribution(chamaId, caller, state.currentRound.receiver);
                            switch(contributionResult) {
                                case(#err(e)) { #err(e) };
                                case(#ok(txId)) {
                                    let newContributions = state.currentRound.currentContributions + 1;
                                    let isComplete = newContributions >= state.currentRound.expectedContributions;

                                    let updatedState = {
                                        currentRound = {
                                            roundNumber = state.currentRound.roundNumber;
                                            receiver = state.currentRound.receiver;
                                            expectedContributions = state.currentRound.expectedContributions;
                                            currentContributions = newContributions;
                                            startTime = state.currentRound.startTime;
                                            endTime = if (isComplete) ?Time.now() else null;
                                            status = if (isComplete) #Complete else #Active;
                                        };
                                        receiverHistory = state.receiverHistory;
                                    };

                                    chamaStates.put(chamaId, updatedState);
                                    chamaRounds.put(chamaId, updatedState.currentRound);

                                    if (isComplete) {
                                        ignore completeRoundAndSelectNext(chamaId);
                                    };

                                    #ok({
                                        status = "Contribution successful";
                                        contributionAmount = CONTRIBUTION_AMOUNT;
                                        receiver = ?state.currentRound.receiver;
                                        nextPayoutDate = getNextPayoutDate(chamaId);
                                        transactionId = ?txId;
                                    });
                                };
                            };
                        };
                    };
                };
            };
        };
                // Handle actual contribution/transfer
        private func handleContribution(chamaId : Nat, contributor : Principal, receiver : Principal) : async* Types.Result<Text, Text> {
            // Update member status first
            switch(updateMemberStatus(chamaId, contributor, receiver)) {
                case(#err(e)) { #err(e) };
                case(#ok(_)) {
                    // TODO: Implement actual token transfer here
                    // For now, simulate a successful transfer
                    let txId = "tx_" # Int.toText(Time.now()) # "_" # 
                              Principal.toText(contributor) # "_to_" # 
                              Principal.toText(receiver);
                    #ok(txId)
                };
            };
        };

        // Update member status after contribution
        private func updateMemberStatus(chamaId : Nat, contributor : Principal, receiver : Principal) : Types.Result<(), Text> {
            switch(storage.getChama(chamaId)) {
                case(null) { #err("Chama not found") };
                case(?chama) {
                    let updatedMembers = Array.map<Types.Member, Types.Member>(
                        chama.members,
                        func(member : Types.Member) : Types.Member {
                            if (Principal.equal(member.id, contributor)) {
                                {
                                    id = member.id;
                                    name = member.name;
                                    contributed = member.contributed + CONTRIBUTION_AMOUNT;
                                    receivedPayout = member.receivedPayout;
                                }
                            } else if (Principal.equal(member.id, receiver)) {
                                {
                                    id = member.id;
                                    name = member.name;
                                    contributed = member.contributed;
                                    receivedPayout = true;
                                }
                            } else {
                                member
                            }
                        }
                    );

                    let updatedChama : Types.Chama = {
                        id = chama.id;
                        name = chama.name;
                        owner = chama.owner;
                        ownerName = chama.ownerName;
                        members = updatedMembers;
                    };

                    storage.putChama(chamaId, updatedChama);
                    lastPayoutTime := Time.now();
                    #ok(())
                };
            };
        };

        // Round completion and next receiver selection
        public func completeRoundAndSelectNext(chamaId : Nat) : Types.Result<Principal, Text> {
            Debug.print("Starting round completion for Chama: " # debug_show(chamaId));
            
            switch(chamaRounds.get(chamaId)) {
                case(null) { #err("No active round found") };
                case(?round) {
                    if (round.status != #Complete) {
                        return #err("Round is not complete. Expected " # 
                            Nat.toText(round.expectedContributions) # 
                            " contributions, received " # 
                            Nat.toText(round.currentContributions));
                    };

                    Debug.print("Round is complete, selecting next receiver");

                    // Select next receiver
                    switch(selectReceiver(chamaId, #Complete)) {
                        case(#err(e)) { 
                            Debug.print("Error selecting next receiver: " # e);
                            #err(e) 
                        };
                        case(#ok(nextReceiver)) {
                            Debug.print("Selected next receiver: " # debug_show(nextReceiver));
                            #ok(nextReceiver)
                        };
                    };
                };
            };
        };

        // Get next payout date
        private func getNextPayoutDate(chamaId : Nat) : ?Int {
            switch(storage.getChama(chamaId)) {
                case(null) { null };
                case(?_) {
                    ?(lastPayoutTime + 2_592_000_000_000_000) // 30 days in nanoseconds
                };
            };
        };

        // Query Functions
        public func getCurrentRoundInfo(chamaId : Nat) : ?RoundInfo {
            chamaRounds.get(chamaId)
        };

        public func getRoundProgress(chamaId : Nat) : Types.Result<Text, Text> {
            switch(chamaRounds.get(chamaId)) {
                case(null) { #err("No active round") };
                case(?round) {
                    #ok("Round " # Nat.toText(round.roundNumber) # 
                        ": " # Nat.toText(round.currentContributions) # 
                        "/" # Nat.toText(round.expectedContributions) # 
                        " contributions received")
                };
            };
        };
                // Public query functions
        public func getCurrentReceiverForChama(chamaId : Nat) : Types.Result<Principal, Text> {
            switch(chamaStates.get(chamaId)) {
                case(null) { #err("No active state found") };
                case(?state) { #ok(state.currentRound.receiver) };
            };
        };

        public func getContributionAmount() : Nat {
            CONTRIBUTION_AMOUNT
        };

        public func getNextPayoutInfo(chamaId : Nat) : Types.Result<ReceiverInfo, Text> {
            switch(validateChama(chamaId)) {
                case(#err(e)) { #err(e) };
                case(#ok(chama)) {
                    switch(getCurrentReceiverForChama(chamaId)) {
                        case(#err(e)) { #err(e) };
                        case(#ok(receiver)) {
                            // Find receiver's name from members
                            let receiverMember = Array.find<Types.Member>(
                                chama.members,
                                func(m : Types.Member) : Bool { 
                                    Principal.equal(m.id, receiver) 
                                }
                            );
                            
                            switch(receiverMember) {
                                case(null) { #err("Receiver not found in members") };
                                case(?member) {
                                    let nextPayoutTime = switch(getNextPayoutDate(chamaId)) {
                                        case(null) { Time.now() + 2_592_000_000_000_000 }; // Default to 30 days
                                        case(?time) { time };
                                    };

                                    let dateInfo = timestampToDateInfo(nextPayoutTime);
                                    let expectedAmount = (Array.size(chama.members) - 1) * CONTRIBUTION_AMOUNT;

                                    #ok({
                                        principal = receiver;
                                        name = member.name;  // Include receiver's name
                                        expectedAmount = expectedAmount;
                                        dueDate = dateInfo;
                                        status = switch(chamaRounds.get(chamaId)) {
                                            case(null) { "Not Started" };
                                            case(?round) {
                                                if (round.currentContributions >= round.expectedContributions) {
                                                    "Complete"
                                                } else {
                                                    "In Progress (" # 
                                                    Nat.toText(round.currentContributions) # 
                                                    "/" # 
                                                    Nat.toText(round.expectedContributions) # 
                                                    " contributions)"
                                                };
                                            };
                                        };
                                    })
                                };
                            };
                        };
                    };
                };
            };
        };
       public func getCurrentReceiverDetails(chamaId : Nat) : Types.Result<ReceiverInfo, Text> {
                switch(chamaRounds.get(chamaId)) {
                    case(null) { #err("No active round found") };
                    case(?round) {
                        switch(storage.getChama(chamaId)) {
                            case(null) { #err("Chama not found") };
                            case(?chama) {
                                // Find the receiver's name from members
                                let receiverMember = Array.find<Types.Member>(
                                    chama.members,
                                    func(m : Types.Member) : Bool { 
                                        Principal.equal(m.id, round.receiver) 
                                    }
                                );
                                
                                let dateInfo = timestampToDateInfo(round.startTime + 2_592_000_000_000_000);
                                
                                switch(receiverMember) {
                                    case(null) { #err("Receiver not found in members") };
                                    case(?member) {
                                        #ok({
                                            principal = round.receiver;
                                            name = member.name;  // Include receiver's name
                                            expectedAmount = round.expectedContributions * CONTRIBUTION_AMOUNT;
                                            dueDate = dateInfo;
                                            status = if (round.status == #Complete) {
                                                "Complete"
                                            } else {
                                                "Awaiting " # 
                                                Nat.toText(round.expectedContributions - round.currentContributions) # 
                                                " more contributions"
                                            };
                                        })
                                    };
                                };
                            };
                        };
                    };
                };
            };

        public func getRoundStatus(chamaId : Nat) : Types.Result<{
            currentRound : Nat;
            totalContributions : Nat;
            expectedContributions : Nat;
            roundStartDate : DateInfo;
            daysRemaining : Int;
        }, Text> {
            switch(chamaRounds.get(chamaId)) {
                case(null) { #err("No active round found") };
                case(?round) {
                    let now = Time.now();
                    let daysInNanos = 86_400_000_000_000;
                    let daysRemaining = ((round.startTime + 2_592_000_000_000_000) - now) / daysInNanos;

                    #ok({
                        currentRound = round.roundNumber;
                        totalContributions = round.currentContributions;
                        expectedContributions = round.expectedContributions;
                        roundStartDate = timestampToDateInfo(round.startTime);
                        daysRemaining = daysRemaining;
                    })
                };
            };
        };

        public func getContributionStatus(chamaId : Nat, memberId : Principal) : Types.Result<ContributionStatus, Text> {
            switch(validateChama(chamaId)) {
                case(#err(e)) { #err(e) };
                case(#ok(chama)) {
                    switch(Array.find<Types.Member>(chama.members, func(m) = Principal.equal(m.id, memberId))) {
                        case(null) { #err("Member not found") };
                        case(?member) {
                            #ok(if (member.contributed >= CONTRIBUTION_AMOUNT) {
                                #Paid
                            } else {
                                #Unpaid
                            })
                        };
                    };
                };
            };
        };
        public func getAllUserChamas(caller : Principal) : [ChamaSummary] {
        var userChamas : [ChamaSummary] = [];
        
        // Get all Chamas from storage
        for ((chamaId, chama) in storage.getAllChamas()) {
            // Check if user is a member
            switch(Array.find<Types.Member>(chama.members, func(m) = Principal.equal(m.id, caller))) {
                case(null) { /* User is not a member of this chama */ };
                case(?member) {
                    // Get current round info
                    let currentRound = switch(chamaRounds.get(chamaId)) {
                        case(null) { null };
                        case(?round) {
                            // Get receiver name
                            let receiverName = switch(Array.find<Types.Member>(
                                chama.members,
                                func(m) = Principal.equal(m.id, round.receiver)
                            )) {
                                case(null) { "Unknown" };
                                case(?receiverMember) { receiverMember.name };
                            };
                            
                            ?{
                                roundNumber = round.roundNumber;
                                receiver = round.receiver;
                                receiverName = receiverName;
                                expectedContributions = round.expectedContributions;
                                currentContributions = round.currentContributions;
                                startTime = round.startTime;
                                status = round.status;
                            };
                        };
                    };

                    // Create summary
                    let summary : ChamaSummary = {
                        id = chamaId;
                        name = chama.name;
                        owner = chama.owner;
                        ownerName = chama.ownerName;
                        memberCount = Array.size(chama.members);
                        isCurrentUserOwner = Principal.equal(caller, chama.owner);
                        joinedDate = Time.now(); // In a production system, you'd want to store and track the actual join date
                        totalContributed = member.contributed;
                        currentRound = currentRound;
                    };
                    
                    userChamas := Array.append(userChamas, [summary]);
                        };
                    };
                };
            
            userChamas
        };

        // Debug helper function
        public func getReceiverHistory(chamaId : Nat) : [Principal] {
            switch(chamaStates.get(chamaId)) {
                case(null) { [] };
                case(?state) { state.receiverHistory };
            };
        };

        // Helper function to get member name
        public func getMemberName(chamaId : Nat, memberId : Principal) : ?Text {
            switch(storage.getChama(chamaId)) {
                case(null) { null };
                case(?chama) {
                    switch(Array.find<Types.Member>(chama.members, func(m) = Principal.equal(m.id, memberId))) {
                        case(null) { null };
                        case(?member) { ?member.name };
                    };
                };
            };
        };

        public func getMemberDetails(chamaId : Nat, memberId : Principal) : Types.Result<MemberDetails, Text> {
            switch(storage.getChama(chamaId)) {
                case(null) { #err("Chama not found") };
                case(?chama) {
                    switch(Array.find<Types.Member>(chama.members, func(m) = Principal.equal(m.id, memberId))) {
                        case(null) { #err("Member not found") };
                        case(?member) {
                            #ok({
                                id = member.id;
                                name = member.name;
                                contributed = member.contributed;
                                receivedPayout = member.receivedPayout;
                            })
                        };
                    };
                };
            };
        };
    };
};