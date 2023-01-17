import MigrationTypes "./migrations/types";
import Migrations "./migrations";
import Types "./types";

import Map "mo:map/Map";

import AccountIdentifier "mo:principal/AccountIdentifier";

import httpparser "mo:httpparser/lib";

import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";

import json "mo:json/JSON";

shared (deployer) actor class QuickList() = this {

  stable var migration_state: MigrationTypes.State = #v0_0_0(#data);

  stable var admin = deployer.caller;

  // Do not forget to change #v0_1_0 when you are adding a new migration
  // If you use one previous state in place of #v0_1_0 it will run downgrade methods instead
  migration_state := Migrations.migrate(migration_state, #v0_0_1(#id), {owner = deployer.caller;});

  let #v0_0_1(#data(state_current)) = migration_state;

  let { ihash; nhash; thash; phash; calcHash } = Map;


  public shared(msg) func setAxon(request: Principal, axonId: Nat) : async Bool{
    assert(msg.caller == state_current.axon);
    state_current.axon := request;
    state_current.axonId := axonId;
    return true;
  };

  public shared(msg) func setAdmin(request: Principal) : async Bool{
    assert(msg.caller == admin);
    admin := request;
    return true;
  };

  public shared(msg) func addData(request: {dev_principal: Principal; dev_text: Text}) : async Result.Result<Bool, Text>{
    assert(msg.caller == admin);

    switch(Map.get(state_current.data, phash, request.dev_principal)){
      case(null){
        Map.set(state_current.data, phash, request.dev_principal, (request.dev_text, Time.now()));
        let axon : Types.AxonService = actor(Principal.toText(state_current.axon));
        switch(await axon.mint(state_current.axonId, request.dev_principal, 1)){
          case(#err(_)){
            Map.delete(state_current.data, phash, request.dev_principal);
            return #err("could not mint");
          };
          case(#ok(#SupplyChanged(val))){

          };
          case(_){
            Map.delete(state_current.data, phash, request.dev_principal);
          };
        };

      };
      case(?val){
        //already added...don't mint...just updating
        Map.set(state_current.data, phash, request.dev_principal, (request.dev_text, val.1));
      };
    };
    
    return #ok(true);
  };

  public shared(msg) func removeData(request: Principal) : async Result.Result<Bool, Text>{
    assert(msg.caller == admin);
    let current_val = switch(Map.get(state_current.data, phash, request)){

      case(null){
        return #err("not a member");
      };
      case(?val) val;
    };
    Map.delete(state_current.data, phash, request);
    let axon : Types.AxonService = actor(Principal.toText(state_current.axon));
    let mint_action = await axon.burn(state_current.axonId, request, 1);

    switch(mint_action){
      case(#err(_)){
      Map.set(state_current.data, phash, request, (current_val.0, current_val.1));
      return #err("could not mint");
    };
    case(#ok(#SupplyChanged(val))){

    };
    case(_){
      Map.set(state_current.data, phash, request, (current_val.0, current_val.1));
    };
  };

    return #ok(true);
  };

  public query(msg) func getList() : async [(Principal, (Text, Int))]{
    Iter.toArray<(Principal,(Text, Int))>(Map.entries(state_current.data));
  };

  public query(msg) func onList(request: Principal) : async ?Int{
    switch(Map.get(state_current.data, phash, request)){
      case(null) null;
      case(?val) ?val.1;
    };
  };

  // Handles http request
  public query(msg) func http_request(rawReq: Types.HttpRequest): async (Types.HTTPResponse) {


    let req = httpparser.parse(rawReq);
    let {host; port; protocol; path; queryObj; anchor; original = url} = req.url;

    let path_size = req.url.path.array.size();
    let path_array = req.url.path.array;


      if(path_size == 0) {
        let main_text = Buffer.Buffer<Text>(1);
        main_text.add("\"Builders Too Busy to Pay Attention to Your Allow-List But Will Support You When its Time\" DAO\n\nThis canister provides Internet Computer Community Builders a place to capture the principal address of key Ecosystem builders that may be too busy to pay attention to your new/cool airdrop and/or whitelist.  \n\nDevelopers love freebies and would love to help you out with your project, but may not spend much time on twitter, discord, etc. You can find a list of these principals at /list on this site.");
        main_text.add("\n\nVisit https://icdevs.org/BuilderDAO.html");
        main_text.add("\n\nThis list is available programaticaly via the candid signature: \nquery getList: () -> [(Principal, (Text,Int))];\nquery onList: (Principal) -> async ?Int;  //timestamp of date added");
        main_text.add("\n\nPrincipal - Default Account - Member Since - Description\n\n");
        for(thisItem in Map.entries(state_current.data)){
          main_text.add(Principal.toText(thisItem.0) # "     " # AccountIdentifier.toText(AccountIdentifier.fromPrincipal(thisItem.0,null)) # "     " # Int.toText(thisItem.1.1) # "     " # thisItem.1.0 # "\n\n");
        };
       

        return {
          body = Text.encodeUtf8(Text.join("", main_text.vals()));
          headers = [("Content-Type", "text/plain")];
          status_code = 200;
          streaming_strategy = null;
        };
      } else if(path_size == 1 and path_array[0] == "list") {
        let main_text = Buffer.Buffer<Text>(1);
       
        for(thisItem in Map.entries(state_current.data)){
          main_text.add(Principal.toText(thisItem.0) # "," # Int.toText(thisItem.1.1) # "\n");
        };
      

        return {
          body = Text.encodeUtf8(Text.join("", main_text.vals()));
          headers = [("Content-Type", "text/csv")];
          status_code = 200;
          streaming_strategy = null;
        };

      } else {
        return {
          body = Text.encodeUtf8("404 not found");
          headers = [("Content-Type", "text/plain")];
          status_code = 404;
          streaming_strategy = null;
        };
      };
  };

 

}