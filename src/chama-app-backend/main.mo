import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Types "./chama_logic/types";
import Storage "./chama_logic/storage";
import ChamaLogic "./chama_logic/chama_logic";
import ContributionLogic "./chama_logic/contributions";
import Transactions "./transactions_history/transactions";
import LLM "mo:llm";
import LLMHelper "./llm/llm";

actor {
    let storage = Storage.Storage();
    let chamaLogic = ChamaLogic.ChamaLogic(storage);
    let contributionLogic = ContributionLogic.ContributionLogic(storage);
    private let transactionLog = Transactions.TransactionLog();


    //Core functions of the app
    public shared({ caller }) func createChama(name : Text, ownerName: Text) : async Types.Result<Nat, Text> {
        chamaLogic.createChama(name, ownerName, caller)
    };

    public shared({ caller }) func joinChama(chamaId : Nat, memberName: Text) : async Types.Result<Text, Text> {
        chamaLogic.joinChama(chamaId, memberName, caller)
    };

    public query func getChama(chamaId : Nat) : async ?Types.Chama {
        chamaLogic.getChama(chamaId)
    };

   public shared({ caller }) func contribute(chamaId : Nat) : async Types.Result<ContributionLogic.ContributionResult, Text> {
       let result = await* contributionLogic.processContribution(chamaId, caller);
        
        switch(result) {
            case(#ok(contributionResult)) {
                // Get contributor's name
                let contributorName = switch(contributionLogic.getMemberName(chamaId, caller)) {
                    case(null) { "Unknown Member" };
                    case(?name) { name };
                };

                // Get receiver's name if there is a receiver
                let receiverName = switch(contributionResult.receiver) {
                    case(null) { null };
                    case(?receiverPrincipal) {
                        contributionLogic.getMemberName(chamaId, receiverPrincipal);
                    };
                };

                // Log successful contribution with names
                ignore transactionLog.logTransaction(
                    #Contribution,
                    caller,
                    contributorName,  // Add contributor's name
                    contributionResult.receiver,
                    receiverName,     // Add receiver's name
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

    public query func getMemberDetails(chamaId : Nat, memberId : Principal) : async Types.Result<ContributionLogic.MemberDetails, Text> {
            contributionLogic.getMemberDetails(chamaId, memberId)
    };

    public shared query({ caller }) func getAllChamas() : async [ContributionLogic.ChamaSummary] {
            contributionLogic.getAllUserChamas(caller)
    };

   //Functions to get previous transcations to be used by LLM
   public shared query func getAllTransactions() : async [Transactions.Transaction] {
        transactionLog.getAllTransactions()
    };

    public query func getFormattedTransactionsForLLM(chamaId : Nat) : async Text {
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
    
    //TODO organise files, add chat with system roles, setup AI functions
    let llmHelper = LLMHelper.LLMHelper();

    public shared func chatWithAI(message : Text) : async LLMHelper.AIResponse {
        await llmHelper.chat(message)
    };

    //public shared func chamaChat(message : Text, userName : Text) : async LLMHelper.AIResponse {
        //await llmHelper.chamaSpecificChat(message, userName)
    //};


    system func preupgrade() {
        storage.preupgrade();
    };

    system func postupgrade() {
        storage.postupgrade();
    };
}