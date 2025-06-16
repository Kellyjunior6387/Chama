import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import Int "mo:base/Int";
import Nat32 "mo:base/Nat32";

module {
    public type TransactionType = {
        #Contribution;
        #Payout;
        #RoundComplete;
        #NewMember;
    };

    public type Transaction = {
        id : Text;
        transactionType : TransactionType;
        from : Principal;
        to : ?Principal;
        amount : ?Nat;
        timestamp : Int;
        status : Text;
        chamaId : Nat;
        roundNumber : ?Nat;
        details : Text;
    };

    public class TransactionLog() {
        private var transactions = HashMap.HashMap<Text, Transaction>(50, Text.equal, Text.hash);
        // Changed from Hash.hash to Nat32.hash
        private var transactionsByChama = HashMap.HashMap<Nat, [Text]>(10, Nat.equal, func(n : Nat) : Nat32 { 
            Nat32.fromNat(n)
        });

        public func logTransaction(
            txType : TransactionType,
            from : Principal,
            to : ?Principal,
            amount : ?Nat,
            chamaId : Nat,
            roundNumber : ?Nat,
            details : Text
        ) : Text {
            let timestamp = Time.now();
            let txId = generateTransactionId(timestamp, from);
            
            let transaction : Transaction = {
                id = txId;
                transactionType = txType;
                from = from;
                to = to;
                amount = amount;
                timestamp = timestamp;
                status = "Completed";
                chamaId = chamaId;
                roundNumber = roundNumber;
                details = details;
            };

            transactions.put(txId, transaction);
            
            // Update transactions by Chama
            switch(transactionsByChama.get(chamaId)) {
                case(null) {
                    transactionsByChama.put(chamaId, [txId]);
                };
                case(?txIds) {
                    transactionsByChama.put(chamaId, Array.append(txIds, [txId]));
                };
            };

            txId
        };

        public func getTransaction(txId : Text) : ?Transaction {
            transactions.get(txId)
        };

        public func getChamaTransactions(chamaId : Nat) : [Transaction] {
            switch(transactionsByChama.get(chamaId)) {
                case(null) { [] };
                case(?txIds) {
                    Array.mapFilter<Text, Transaction>(
                        txIds,
                        func(txId : Text) : ?Transaction {
                            transactions.get(txId)
                        }
                    );
                };
            };
        };

        public func getAllTransactions() : [Transaction] {
            var allTx : [Transaction] = [];
            for ((_, tx) in transactions.entries()) {
                allTx := Array.append(allTx, [tx]);
            };
            allTx
        };

        private func generateTransactionId(timestamp : Int, user : Principal) : Text {
            "TX" # Int.toText(timestamp) # "_" # Principal.toText(user)
        };

        // Corrected formatTransactionForLLM function
        public func formatTransactionForLLM(tx : Transaction) : Text {
            let txType = switch(tx.transactionType) {
                case(#Contribution) { "Contribution" };
                case(#Payout) { "Payout" };
                case(#RoundComplete) { "Round Complete" };
                case(#NewMember) { "New Member" };
            };

            let amountText = switch(tx.amount) {
                case(null) { "N/A" };
                case(?amt) { Nat.toText(amt) # " e8s" };
            };

            let toText = switch(tx.to) {
                case(null) { "N/A" };
                case(?principal) { Principal.toText(principal) };
            };

            let timestamp = Int.abs(tx.timestamp / 1_000_000_000); // Convert nano to seconds

            return "Transaction ID: " # tx.id # "\n" #
                    "Type: " # txType # "\n" #
                    "From: " # Principal.toText(tx.from) # "\n" #
                    "To: " # toText # "\n" #
                    "Amount: " # amountText # "\n" #
                    "Timestamp: " # Int.toText(timestamp) # "\n" #
                    "Status: " # tx.status # "\n" #
                    "Chama ID: " # Nat.toText(tx.chamaId) # "\n" #
                    "Details: " # tx.details
        };
    };
};