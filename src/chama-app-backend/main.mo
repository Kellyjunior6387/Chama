import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";

actor {
    type Member = {
        id : Principal;
        contributed : Nat;
        receivedPayout : Bool;
    };

    type Chama = {
        id : Nat;
        name : Text;
        owner : Principal;
        members : [Member];
    };

    private stable var chamaCounter : Nat = 0;
    private var chamas = HashMap.HashMap<Nat, Chama>(10, Nat.equal, Hash.hash);

    // Fixed: Get the actual caller's Principal
    public shared({ caller }) func createChama(name : Text) : async Nat {
        let newChama : Chama = {
            id = chamaCounter;
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

        chamas.put(chamaCounter, newChama);
        chamaCounter += 1;

        return newChama.id;
    };

    // Fixed: Get the actual caller's Principal and handle array immutability
    public shared({ caller }) func joinChama(chamaId : Nat) : async Text {
        switch (chamas.get(chamaId)) {
            case (null) {
                return "Chama not found.";
            };
            case (?chama) {
                // Check if already a member
                for (member in chama.members.vals()) {
                    if (Principal.equal(member.id, caller)) {
                        return "You are already a member.";
                    };
                };

                let newMember : Member = {
                    id = caller;
                    contributed = 0;
                    receivedPayout = false;
                };

                let updatedMembers = Array.append<Member>(chama.members, [newMember]);

                let updatedChama : Chama = {
                    id = chama.id;
                    name = chama.name;
                    owner = chama.owner;
                    members = updatedMembers;
                };

                chamas.put(chamaId, updatedChama);

                return "Successfully joined the Chama.";
            };
        };
    };

    // Query function to view Chama details
    public query func getChama(chamaId : Nat) : async ?Chama {
        chamas.get(chamaId)
    };

    // Added: Function to handle canister upgrades
    system func preupgrade() {
        // Add upgrade logic here if needed
    };

    system func postupgrade() {
        // Add post-upgrade logic here if needed
    };
}