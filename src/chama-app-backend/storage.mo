import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Types "./types";

module {
    public class Storage() {
        private var chamaCounter : Nat = 0;
        private var chamas = HashMap.HashMap<Nat, Types.Chama>(10, Nat.equal, Hash.hash);

        public func getChamaCounter() : Nat {
            chamaCounter
        };

        public func incrementChamaCounter() {
            chamaCounter += 1;
        };

        public func getChamas() : HashMap.HashMap<Nat, Types.Chama> {
            chamas
        };

        public func putChama(id : Nat, chama : Types.Chama) {
            chamas.put(id, chama);
        };

        public func getChama(id : Nat) : ?Types.Chama {
            chamas.get(id)
        };

        public func preupgrade() : () {
            // Add upgrade logic here
        };

        public func postupgrade() : () {
            // Add post-upgrade logic here
        };
    }
}