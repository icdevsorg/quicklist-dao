import Map_lib "mo:map_7_0_0/Map"; 

module {
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  

  public let Map = Map_lib;

  public type State = {
    // this is the data you previously had as stable variables inside your actor class
    var data : Map.Map<Principal,(Text,Int)>;
    var axon : Principal;
    var axonId : Nat;
  };
};
