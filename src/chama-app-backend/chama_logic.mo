import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Types "./types";
import Storage "./storage";

module {
    public class ChamaLogic(storage : Storage.Storage) {
        public func createChama(name : Text, caller : Principal) : Types.Result<Nat, Text> {
            let chamaId = storage.getChamaCounter();

            let newChama : Types.Chama = {
                id = chamaId;
                name = name;
                owner = caller;
                members = [
                    {
                        id = caller;
                        contributed = 0;
                        receivedPayout = false;
                    }
                ];
            };

            storage.putChama(chamaId, newChama);
            storage.incrementChamaCounter();

            #ok(chamaId)
        };

        public func joinChama(chamaId : Nat, caller : Principal) : Types.Result<Text, Text> {
            switch (storage.getChama(chamaId)) {
                case (null) {
                    #err("Chama not found.")
                };
                case (?chama) {
                    // Check if already a member
                    for (member in chama.members.vals()) {
                        if (Principal.equal(member.id, caller)) {
                            return #err("You are already a member.");
                        };
                    };

                    let newMember : Types.Member = {
                        id = caller;
                        contributed = 0;
                        receivedPayout = false;
                    };

                    let updatedMembers = Array.append<Types.Member>(chama.members, [newMember]);

                    let updatedChama : Types.Chama = {
                        id = chama.id;
                        name = chama.name;
                        owner = chama.owner;
                        members = updatedMembers;
                    };

                    storage.putChama(chamaId, updatedChama);

                    #ok("Successfully joined the Chama.")
                };
            };
        };

        public func getChama(chamaId : Nat) : ?Types.Chama {
            storage.getChama(chamaId)
        };
    }
}