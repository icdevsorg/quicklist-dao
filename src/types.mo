import Error "mo:base/Error";
import Result "mo:base/Result";

module {

  public type HeaderField = (Text, Text);

  public type StreamingCallbackToken =  {
        content_encoding: Text;
        index: Nat;
        key: Text;
        //sha256: ?Blob;
    };

  public type StreamingStrategy = {
       #Callback: {
          callback: shared () -> async ();
          token: StreamingCallbackToken;
        };
    };

  public type HttpRequest = {
        body: Blob;
        headers: [HeaderField];
        method: Text;
        url: Text;
    };

  public type HTTPResponse = {
    body               : Blob;
    headers            : [HeaderField];
    status_code        : Nat16;
    streaming_strategy : ?StreamingStrategy;
  };

  public type GovernanceError = { error_message : Text; error_type : Int32 };

  public type Error = {
    #NotAllowedByPolicy;
    #Unauthorized;
    #InvalidProposal;
    #NotFound;
    #ProposalNotFound;
    #NoNeurons;
    #CannotExecute;
    #NotProposer;
    #InsufficientBalanceToPropose;
    #CannotVote;
    #AlreadyVoted;
    #InsufficientBalance;
    #GovernanceError: GovernanceError;
    #Error: { error_message : Text; error_type : Error.ErrorCode };
  };

  public type AxonCommandExecution = {
    #Ok;
    #SupplyChanged: { from: Nat; to: Nat };
    #Transfer: {
      receiver: Principal;
      amount: Nat;
      senderBalanceAfter: Nat;
    };
  };

  public type AxonService = actor {
    mint: (Nat, Principal, Nat) -> async Result.Result<AxonCommandExecution, Error>;
    burn: (Nat, Principal, Nat) -> async Result.Result<AxonCommandExecution, Error>;
  };


}