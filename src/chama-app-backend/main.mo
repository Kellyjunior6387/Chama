import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Types "./types";
import Storage "./storage";
import ChamaLogic "./chama_logic";
import ContributionLogic "./contributions";

actor {
    let storage = Storage.Storage();
    let chamaLogic = ChamaLogic.ChamaLogic(storage);
    let contributionLogic = ContributionLogic.ContributionLogic(storage);

    public shared({ caller }) func createChama(name : Text) : async Types.Result<Nat, Text> {
        chamaLogic.createChama(name, caller)
    };

    public shared({ caller }) func joinChama(chamaId : Nat) : async Types.Result<Text, Text> {
        chamaLogic.joinChama(chamaId, caller)
    };

    public query func getChama(chamaId : Nat) : async ?Types.Chama {
        chamaLogic.getChama(chamaId)
    };

    public shared({ caller }) func contribute(chamaId : Nat) : async Types.Result<ContributionLogic.ContributionResult, Text> {
        await* contributionLogic.processContribution(chamaId, caller)
    };

    // Query functions for UI
    public query func getContributionAmount() : async Nat {
        contributionLogic.getContributionAmount()
    };

    public query func getContributionStatus(chamaId : Nat, memberId : Principal) : async Types.Result<ContributionLogic.ContributionStatus, Text> {
        contributionLogic.getContributionStatus(chamaId, memberId)
    };

    system func preupgrade() {
        storage.preupgrade();
    };

    system func postupgrade() {
        storage.postupgrade();
    };
}