import MigrationTypes "../types";
import v0_0_1_types = "types";

import Map_lib "mo:map_7_0_0/Map"; 

module {
  public func upgrade(prev_migration_state: MigrationTypes.State, args: MigrationTypes.Args): MigrationTypes.State {


    return #v0_0_1(#data(
      {
        var data : Map_lib.Map<Principal, (Text,Int)> = Map_lib.new<Principal, (Text,Int)>();
        var axon : Principal = args.owner;
        var axonId : Nat = 0;
      }));
  };

   public func downgrade(migration_state: MigrationTypes.State, args: MigrationTypes.Args): MigrationTypes.State {
    return #v0_0_0(#data);
  };

  
};