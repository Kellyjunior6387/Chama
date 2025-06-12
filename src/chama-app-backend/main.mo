import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Types "./types";
import Storage "./storage";
import ChamaLogic "./chama_logic";

actor {
    let storage = Storage.Storage();
    let chamaLogic = ChamaLogic.ChamaLogic(storage);

    public shared({ caller }) func createChama(name : Text) : async Types.Result<Nat, Text> {
        chamaLogic.createChama(name, caller)
    };

    public shared({ caller }) func joinChama(chamaId : Nat) : async Types.Result<Text, Text> {
        chamaLogic.joinChama(chamaId, caller)
    };

    public query func getChama(chamaId : Nat) : async ?Types.Chama {
        chamaLogic.getChama(chamaId)
    };

    system func preupgrade() {
        storage.preupgrade();
    };

    system func postupgrade() {
        storage.postupgrade();
    };
}