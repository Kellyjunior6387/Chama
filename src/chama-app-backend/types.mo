import Principal "mo:base/Principal";

module {
    public type Member = {
        id : Principal;
        contributed : Nat;
        receivedPayout : Bool;
    };

    public type Chama = {
        id : Nat;
        name : Text;
        owner : Principal;
        members : [Member];
    };

    // Add any additional type definitions here
    public type Result<Ok, Err> = {
        #ok : Ok;
        #err : Err;
    };

    // New types for contribution system
    public type ContributionStatus = {
        #Paid;
        #Unpaid;
        #PendingVerification;
    };

    public type PayoutSchedule = {
        memberId : Principal;
        scheduledTime : Int;
        amount : Nat;
    };
}