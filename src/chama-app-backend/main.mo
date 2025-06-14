import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Types "./types";
import Storage "./storage";
import ChamaLogic "./chama_logic";
//import ContributionLogic "./contributions";
import ContributionLogic "./contributions_v2";
import Transactions "./transactions";

actor {
    let storage = Storage.Storage();
    let chamaLogic = ChamaLogic.ChamaLogic(storage);
    let contributionLogic = ContributionLogic.ContributionLogic(storage);
    private let transactionLog = Transactions.TransactionLog();

    //Core functions of the app
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
       let result = await* contributionLogic.processContribution(chamaId, caller);
        
        switch(result) {
            case(#ok(contributionResult)) {
                // Log successful contribution
                ignore transactionLog.logTransaction(
                    #Contribution,
                    caller,
                    contributionResult.receiver,
                    ?contributionResult.contributionAmount,
                    chamaId,
                    switch(contributionLogic.getCurrentRoundInfo(chamaId)) {
                        case(null) { null };
                        case(?round) { ?round.roundNumber };
                    },
                    "Contribution processed successfully"
                );
            };
            case(_) {};
        };
        result
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

    public query func getNextPayoutInfo(chamaId : Nat) : async Types.Result<ContributionLogic.ReceiverInfo, Text> {
        contributionLogic.getNextPayoutInfo(chamaId)
    };

    public query func getCurrentReceiverDetails(chamaId : Nat) : async Types.Result<ContributionLogic.ReceiverInfo, Text> {
        contributionLogic.getCurrentReceiverDetails(chamaId)
    };

    public query func getRoundStatus(chamaId : Nat) : async Types.Result<{
        currentRound : Nat;
        totalContributions : Nat;
        expectedContributions : Nat;
        roundStartDate : ContributionLogic.DateInfo;
        daysRemaining : Int;
    }, Text> {
        contributionLogic.getRoundStatus(chamaId)
    };

   //Functions to get previous transcations to be used by LLM
   public shared query func getAllTransactions() : async [Transactions.Transaction] {
        transactionLog.getAllTransactions()
    };

    public shared query func getFormattedTransactionsForLLM(chamaId : Nat) : async Text {
        let transactions = transactionLog.getChamaTransactions(chamaId);
        var formattedText = "Chama ID: " # Nat.toText(chamaId) # "\n\n";
        formattedText := formattedText # "Transaction History:\n\n";

        for (tx in transactions.vals()) {
            formattedText := formattedText # transactionLog.formatTransactionForLLM(tx) # "\n---\n";
        };

        formattedText
    };

    public shared query func getRecentActivitySummary(chamaId : Nat) : async Text {
        let transactions = transactionLog.getChamaTransactions(chamaId);
        let recentTransactions = Array.filter<Transactions.Transaction>(
            transactions,
            func(tx) : Bool {
                // Get transactions from last 24 hours
                (Time.now() - tx.timestamp) < (24 * 3600 * 1000000000)
            }
        );

        var summary = "Recent Activity Summary:\n\n";
        for (tx in recentTransactions.vals()) {
            summary := summary # transactionLog.formatTransactionForLLM(tx) # "\n";
        };

        summary
    };

    system func preupgrade() {
        storage.preupgrade();
    };

    system func postupgrade() {
        storage.postupgrade();
    };
}