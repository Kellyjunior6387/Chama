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

    public class ContributionLogic(storage : Storage.Storage) {
        private let CONTRIBUTION_AMOUNT : Nat = 100_000_000; // 1 ICP = 100_000_000 e8s
        private var lastPayoutTime : Int = 0;

        
        // Main contribution flow function
        public func processContribution(chamaId : Nat, caller : Principal) : async* Types.Result<ContributionResult, Text> {
            try {
                // 1. Verify Chama exists and caller is a member
                switch(storage.getChama(chamaId)) {
                    case(null) {
                        return #err("Chama not found");
                    };
                    case(?chama) {
                        // Check membership
                        var isMember = false;
                        for (member in chama.members.vals()) {
                            if (Principal.equal(member.id, caller)) {
                                isMember := true;
                            };
                        };

                        if (not isMember) {
                            return #err("Not a member of this Chama");
                        };

                        // 2. Get current receiver
                        let receiverResult = getCurrentReceiver(chamaId);
                        switch(receiverResult) {
                            case(#err(e)) {
                                return #err(e);
                            };
                            case(#ok(receiver)) {
                                // 3. Process the contribution
                                let contributionResult = await* handleContribution(chamaId, caller, receiver);
                                switch(contributionResult) {
                                    case(#err(e)) {
                                        return #err(e);
                                    };
                                    case(#ok(txId)) {
                                        // 4. Update member status and records
                                        switch(updateMemberStatus(chamaId, caller, receiver)) {
                                            case(#err(e)) {
                                                return #err(e);
                                            };
                                            case(#ok(_)) {
                                                // 5. Return success result with all relevant information
                                                return #ok({
                                                    status = "Contribution successful";
                                                    contributionAmount = CONTRIBUTION_AMOUNT;
                                                    receiver = ?receiver;
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
                };
            } catch(e) {
                return #err("An error occurred during contribution processing: " # Error.message(e));
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
            switch(storage.getChama(chamaId)) {
                case(null) {
                    #err("Chama not found");
                };
                case(?chama) {
                    if (Array.size(chama.members) == 0) {
                        return #err("No members in Chama");
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
                        return #ok(chama.members[0].id);
                    };

                    #ok(eligibleMembers[0].id)
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

        // Public query functions for UI
        public func getContributionAmount() : Nat {
            CONTRIBUTION_AMOUNT
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
}