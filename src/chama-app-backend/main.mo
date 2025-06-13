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


    public query func getCurrentRoundInfo(chamaId : Nat) : async ?ContributionLogic.RoundInfo {
        contributionLogic.getCurrentRoundInfo(chamaId)
    };

    public query func getRoundProgress(chamaId : Nat) : async Types.Result<Text, Text> {
        contributionLogic.getRoundProgress(chamaId)
    };

    // Get next payout information
    public query func getNextPayoutInfo(chamaId : Nat) : async Types.Result<ContributionLogic.ReceiverInfo, Text> {
        contributionLogic.getNextPayoutInfo(chamaId)
    };

    // Get current receiver details
    public query func getCurrentReceiverDetails(chamaId : Nat) : async Types.Result<ContributionLogic.ReceiverInfo, Text> {
        contributionLogic.getCurrentReceiverDetails(chamaId)
    };
    // Get round status
    public query func getRoundStatus(chamaId : Nat) : async Types.Result<{
        currentRound : Nat;
        totalContributions : Nat;
        expectedContributions : Nat;
        roundStartDate : ContributionLogic.DateInfo;
        daysRemaining : Int;
    }, Text> {
        contributionLogic.getRoundStatus(chamaId)
    };
    system func preupgrade() {
        storage.preupgrade();
    };

    system func postupgrade() {
        storage.postupgrade();
    };
}