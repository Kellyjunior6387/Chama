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
        expectedAmount : Nat;
        dueDate : DateInfo;
        status : Text;
    };

        


    public class ContributionLogic(storage : Storage.Storage) {
        private let CONTRIBUTION_AMOUNT : Nat = 100_000_000; // 1 ICP = 100_000_000 e8s
        private var lastPayoutTime : Int = 0;
        private let MIN_MEMBERS_FOR_CONTRIBUTION : Nat = 2;

        //Store current receiver for each chama
        private var currentReceivers = HashMap.HashMap<Nat, Principal>(10, Nat.equal, Hash.hash);

        // Track rounds for each Chama
        private var chamaRounds = HashMap.HashMap<Nat, RoundInfo>(10, Nat.equal, Hash.hash);
        
         // Initialize a new round
        private func initializeRound(chamaId : Nat, receiver : Principal, totalMembers : Nat) {
            let roundInfo : RoundInfo = {
                roundNumber = getRoundNumber(chamaId);
                receiver = receiver;
                expectedContributions = totalMembers - 1; // Exclude receiver
                currentContributions = 0;
                startTime = Time.now();
                endTime = null;
                status = #Active;
            };
            chamaRounds.put(chamaId, roundInfo);
        };

        // Get current round number
        private func getRoundNumber(chamaId : Nat) : Nat {
            switch(chamaRounds.get(chamaId)) {
                case(null) { 1 };
                case(?round) { round.roundNumber + 1 };
            };
        };

        // Main contribution flow function
        public func processContribution(chamaId : Nat, caller : Principal) : async* Types.Result<ContributionResult, Text> {
                // 1. Verify Chama exists and caller is a member
                switch(storage.getChama(chamaId)) {
                    case(null) {
                        return #err("Chama not found");
                    };
                    case(?chama) {
                        //1. Check minimum members requirement
                        if (Array.size(chama.members) < MIN_MEMBERS_FOR_CONTRIBUTION){
                            return #err("Cannot contribute: Chama needs at least " # Nat.toText(MIN_MEMBERS_FOR_CONTRIBUTION) # "members");
                        };

                        // 2. Check membership
                        var isMember = false;
                        for (member in chama.members.vals()) {
                            if (Principal.equal(member.id, caller)) {
                                isMember := true;
                            };
                        };

                        if (not isMember) {
                            return #err("Not a member of this Chama");
                        };

                       // Get or initialize round info
                        let roundInfo = switch(chamaRounds.get(chamaId)) {
                                case(null) {
                                    // Initialize first round
                                    let receiver = switch(getCurrentReceiver(chamaId)) {
                                        case(#err(e)) { return #err(e) };
                                        case(#ok(r)) { r };
                                    };
                                    initializeRound(chamaId, receiver, Array.size(chama.members));
                                    switch(chamaRounds.get(chamaId)) {
                                        case(null) { return #err("Failed to initialize round") };
                                        case(?info) { info };
                                    };
                                };
                                case(?info) {
                                    if (info.status != #Active) {
                                        return #err("Current round is not active");
                                    };
                                    info;
                                };
                            };

                        // Verify caller is not receiver
                        if (Principal.equal(caller, roundInfo.receiver)) {
                            return #err("Current receiver cannot contribute");
                        };
                        
                      // Process contribution
                    let contributionResult = await* handleContribution(chamaId, caller, roundInfo.receiver);
                    switch(contributionResult) {
                        case(#err(e)) { return #err(e) };
                        case(#ok(txId)) {
                            // Update round info
                            let updatedRoundInfo : RoundInfo = {
                                roundNumber = roundInfo.roundNumber;
                                receiver = roundInfo.receiver;
                                expectedContributions = roundInfo.expectedContributions;
                                currentContributions = roundInfo.currentContributions + 1;
                                startTime = roundInfo.startTime;
                                endTime = roundInfo.endTime;
                                status = if (roundInfo.currentContributions + 1 >= roundInfo.expectedContributions) {
                                    #Complete
                                } else {
                                    #Active
                                };
                            };
                            chamaRounds.put(chamaId, updatedRoundInfo);

                            // Check if round is complete
                            if (updatedRoundInfo.status == #Complete) {
                                // Auto-trigger round completion
                                ignore completeRoundAndSelectNext(chamaId);
                            };

                            return #ok({
                                status = "Contribution successful";
                                contributionAmount = CONTRIBUTION_AMOUNT;
                                receiver = ?roundInfo.receiver;
                                nextPayoutDate = getNextPayoutDate(chamaId);
                                transactionId = ?txId;
                            });
                        };
                    };
                };
            };
        };
    
        

        // Helper function to handle the actual contribution/transfer
        private func handleContribution(chamaId : Nat, contributor : Principal, receiver : Principal) : async* Types.Result<Text, Text> {
            // TODO: Implement actual token transfer here
            // For now, we'll simulate a successful transfer
            let txId = "mock_tx_" # Int.toText(Time.now());
            #ok(txId)
        };

        // Helper function to update member status after contribution
        private func updateMemberStatus(chamaId : Nat, contributor : Principal, receiver : Principal) : Types.Result<(), Text> {
            switch(storage.getChama(chamaId)) {
                case(null) {
                    #err("Chama not found");
                };
                case(?chama) {
                    let updatedMembers = Array.map<Types.Member, Types.Member>(
                        chama.members,
                        func (member : Types.Member) : Types.Member {
                            if (Principal.equal(member.id, contributor)) {
                                {
                                    id = member.id;
                                    contributed = member.contributed + CONTRIBUTION_AMOUNT;
                                    receivedPayout = member.receivedPayout;
                                }
                            } else if (Principal.equal(member.id, receiver)) {
                                {
                                    id = member.id;
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
                        members = updatedMembers;
                    };

                    storage.putChama(chamaId, updatedChama);
                    lastPayoutTime := Time.now();
                    #ok(())
                };
            };
        };

        // Get current receiver (internal helper)
         private func getCurrentReceiver(chamaId : Nat) : Types.Result<Principal, Text> {
            // First check if we have a stored current receiver
            switch(currentReceivers.get(chamaId)) {
                case(?receiver) { return #ok(receiver) };
                case(null) {
                    // If no current receiver, select new one
                    switch(storage.getChama(chamaId)) {
                        case(null) {
                            return #err("Chama not found");
                        };
                        case(?chama) {
                            if (Array.size(chama.members) < MIN_MEMBERS_FOR_CONTRIBUTION) {
                                return #err("Not enough members for contribution");
                            };

                            // Get eligible members (those who haven't received payout)
                            let eligibleMembers = Array.filter<Types.Member>(
                                chama.members,
                                func (member : Types.Member) : Bool {
                                    not member.receivedPayout
                                }
                            );

                            if (Array.size(eligibleMembers) == 0) {
                                // Reset all members' payout status if everyone has received
                                let resetMembers = Array.map<Types.Member, Types.Member>(
                                    chama.members,
                                    func (member : Types.Member) : Types.Member {
                                        {
                                            id = member.id;
                                            contributed = member.contributed;
                                            receivedPayout = false;
                                        }
                                    }
                                );

                                let updatedChama : Types.Chama = {
                                    id = chama.id;
                                    name = chama.name;
                                    owner = chama.owner;
                                    members = resetMembers;
                                };

                                storage.putChama(chamaId, updatedChama);
                                
                                // Select first member as new receiver
                                let newReceiver = chama.members[0].id;
                                currentReceivers.put(chamaId, newReceiver);
                                return #ok(newReceiver);
                            };

                            // Select first eligible member as receiver
                            let newReceiver = eligibleMembers[0].id;
                            currentReceivers.put(chamaId, newReceiver);
                            return #ok(newReceiver);
                        };
                    };
                };
            };
        };

        // Get next payout date
        private func getNextPayoutDate(chamaId : Nat) : ?Int {
            switch(storage.getChama(chamaId)) {
                case(null) {
                    null
                };
                case(?chama) {
                    ?((lastPayoutTime + 2_592_000_000_000_000)) // 30 days in nanoseconds
                };
            };
        };
        // Modified completeRoundAndSelectNext to check round completion
        public func completeRoundAndSelectNext(chamaId : Nat) : Types.Result<Principal, Text> {
            switch(chamaRounds.get(chamaId)) {
                case(null) { #err("No active round found") };
                case(?roundInfo) {
                    if (roundInfo.status != #Complete) {
                        return #err("Round is not complete. Expected " # 
                            Nat.toText(roundInfo.expectedContributions) # 
                            " contributions, received " # 
                            Nat.toText(roundInfo.currentContributions));
                    };

                    // Update round end time
                    let finalizedRound : RoundInfo = {
                        roundNumber = roundInfo.roundNumber;
                        receiver = roundInfo.receiver;
                        expectedContributions = roundInfo.expectedContributions;
                        currentContributions = roundInfo.currentContributions;
                        startTime = roundInfo.startTime;
                        endTime = ?Time.now();
                        status = #Complete;
                    };
                    chamaRounds.put(chamaId, finalizedRound);

                    // Select next receiver and initialize new round
                    switch(selectNextReceiver(chamaId)) {
                        case(#err(e)) { #err(e) };
                        case(#ok(nextReceiver)) {
                            switch(storage.getChama(chamaId)) {
                                case(null) { #err("Chama not found") };
                                case(?chama) {
                                    initializeRound(chamaId, nextReceiver, Array.size(chama.members));
                                    #ok(nextReceiver)
                                };
                            };
                        };
                    };
                };
            };
        };
         private func selectNextReceiver(chamaId : Nat) : Types.Result<Principal, Text> {
            switch(storage.getChama(chamaId)) {
                case(null) { #err("Chama not found") };
                case(?chama) {
                    if (Array.size(chama.members) < MIN_MEMBERS_FOR_CONTRIBUTION) {
                        return #err("Not enough members");
                    };

                    // Get eligible members (those who haven't received payout)
                    let eligibleMembers = Array.filter<Types.Member>(
                        chama.members,
                        func (member : Types.Member) : Bool {
                            not member.receivedPayout
                        }
                    );

                    if (Array.size(eligibleMembers) == 0) {
                        // Reset all members' payout status if everyone has received
                        let resetMembers = Array.map<Types.Member, Types.Member>(
                            chama.members,
                            func (member : Types.Member) : Types.Member {
                                {
                                    id = member.id;
                                    contributed = member.contributed;
                                    receivedPayout = false;
                                }
                            }
                        );

                        let updatedChama : Types.Chama = {
                            id = chama.id;
                            name = chama.name;
                            owner = chama.owner;
                            members = resetMembers;
                        };

                        storage.putChama(chamaId, updatedChama);
                        
                        // After reset, select first member as new receiver
                        let newReceiver = chama.members[0].id;
                        currentReceivers.put(chamaId, newReceiver);
                        return #ok(newReceiver);
                    };

                    // Select first eligible member as new receiver
                    let newReceiver = eligibleMembers[0].id;
                    currentReceivers.put(chamaId, newReceiver);
                    return #ok(newReceiver);
                };
            };
        };

        // Query functions for round information
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

        // Public query to get current receiver
        public func getCurrentReceiverForChama(chamaId : Nat) : Types.Result<Principal, Text> {
            switch(currentReceivers.get(chamaId)) {
                case(?receiver) { #ok(receiver) };
                case(null) { getCurrentReceiver(chamaId) };
            };
        };


        // Public query functions to get contribution amount for UI
        public func getContributionAmount() : Nat {
            CONTRIBUTION_AMOUNT
        };
        private func intToNat(x : Int) : Nat {
            if (x < 0) {
                return 0;
            };
            let nat : Nat = Int.abs(x);
            return nat;
        };

        // Convert nanoseconds to DateInfo
        private func timestampToDateInfo(timestamp : Int) : DateInfo {
            let seconds = timestamp / 1_000_000_000;
            let secondsPerDay = 86_400;
            let secondsPerHour = 3_600;
            let secondsPerMinute = 60;

            let days = seconds / secondsPerDay;
            let years = 1970 + (days / 365); // Simplified calculation
            let month = ((days % 365) / 30) + 1; // Simplified calculation
            let day = ((days % 365) % 30) + 1; // Simplified calculation

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

        // Public function to get next payout date and receiver information
        public func getNextPayoutInfo(chamaId : Nat) : Types.Result<ReceiverInfo, Text> {
            switch(storage.getChama(chamaId)) {
                case(null) { #err("Chama not found") };
                case(?chama) {
                    switch(getCurrentReceiverForChama(chamaId)) {
                        case(#err(e)) { #err(e) };
                        case(#ok(receiver)) {
                            let nextPayoutTime = switch(getNextPayoutDate(chamaId)) {
                                case(null) { Time.now() + 2_592_000_000_000_000 }; // Default to 30 days if no date set
                                case(?time) { time };
                            };

                            let dateInfo = timestampToDateInfo(nextPayoutTime);
                            let expectedAmount = (Array.size(chama.members) - 1) * CONTRIBUTION_AMOUNT;

                            #ok({
                                principal = receiver;
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

        // Public function to get current receiver details
        public func getCurrentReceiverDetails(chamaId : Nat) : Types.Result<ReceiverInfo, Text> {
            switch(chamaRounds.get(chamaId)) {
                case(null) { #err("No active round found") };
                case(?round) {
                    let dateInfo = timestampToDateInfo(round.startTime + 2_592_000_000_000_000); // 30 days from start
                    #ok({
                        principal = round.receiver;
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

        // Public function to get contribution round status
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
            switch(storage.getChama(chamaId)) {
                case(null) {
                    #err("Chama not found");
                };
                case(?chama) {
                    for (member in chama.members.vals()) {
                        if (Principal.equal(member.id, memberId)) {
                            if (member.contributed >= CONTRIBUTION_AMOUNT) {
                                return #ok(#Paid);
                            } else {
                                return #ok(#Unpaid);
                            };
                        };
                    };
                    #err("Member not found");
                };
            };
        };
    };
};