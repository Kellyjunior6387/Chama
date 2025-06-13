import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Error "mo:base/Error";
import Types "../src/chama-app-backend/types";
import ContributionLogic "../src/chama-app-backend/contributions";

actor {
    let chamaCanister = actor "rrkah-fqaaa-aaaaa-aaaaq-cai" : actor {
        createChama : shared (name : Text) -> async Nat;
        joinChama : shared (chamaId : Nat) -> async Text;
        getChama : shared query (chamaId : Nat) -> async ?Types.Chama;
        contribute : shared (chamaId : Nat) -> async Types.Result<ContributionLogic.ContributionResult, Text>;
        getContributionStatus : shared query (chamaId : Nat, memberId : Principal) -> async Types.Result<ContributionLogic.ContributionStatus, Text>;
    };

    public func runTests() : async Text {
        try {
            // Test 1: Create Chama
            let chamaId = await chamaCanister.createChama("Test Chama");
            Debug.print("Created Chama with ID: " # debug_show(chamaId));

            // Test 2: Join Chama
            let joinResult = await chamaCanister.joinChama(chamaId);
            Debug.print("Join result: " # joinResult);

            // Test 3: Get Chama Details
            let chamaDetails = await chamaCanister.getChama(chamaId);
            switch(chamaDetails) {
                case(null) {
                    Debug.print("Error: Chama not found");
                    return "Tests failed at getting Chama details";
                };
                case(?chama) {
                    Debug.print("Chama details: " # debug_show(chama));
                };
            };

            // Test 4: Make Contribution
            let contributionResult = await chamaCanister.contribute(chamaId);
            switch(contributionResult) {
                case(#ok(result)) {
                    Debug.print("Contribution successful: " # debug_show(result));
                };
                case(#err(error)) {
                    Debug.print("Contribution failed: " # error);
                    return "Tests failed at contribution";
                };
            };

            "All tests passed successfully"
        } catch(e) {
            "Tests failed with error: " # Error.message(e)
        }
    };
}