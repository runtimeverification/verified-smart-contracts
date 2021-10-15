//@ proof
require "trusted-perform-action-endpoint-fragment-new.k"  //@ Bazel remove

module PROOF-PERFORM-ACTION-ENDPOINT-NEW
  imports TRUSTED-PERFORM-ACTION-ENDPOINT-FRAGMENT-NEW
//@ trusted
// module TRUSTED-PERFORM-ACTION-ENDPOINT-NEW
//@ end
  imports FUNCTIONS-EXECUTE

  claim <T><TT>
          <k> call(performActionEndpoint(_ActionId:Usize)) ~> K:K </k>
          invariantStateFull(
              NumUsers:Usize,
              UserIdToAddress:Map,
              AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              UserIdToRole:Map,
              Quorum:Usize,
              ActionLastIndex:Usize,
              ActionData:Map,
              ActionSigners:Map,
              CallerAddress:Address,
              Stack:Stack,
              .Map,
              PerformedActions:List
              )
        </TT></T>
      =>
        <T><TT>
          <k> error ~> K:K </k>
          invariantStateFull(
              NumUsers,
              UserIdToAddress,
              AddressToUserId,
              NumBoardMembers,
              NumProposers,
              UserIdToRole,
              Quorum,
              ActionLastIndex,
              ActionData,
              ActionSigners,
              CallerAddress,
              Stack,
              caller_address |-> CallerAddress
                caller_id |-> u(0)
                caller_role |-> None,
              PerformedActions
              )
        </TT></T>
    requires true
        andBool notBool CallerAddress in_keys(AddressToUserId)
        andBool notBool u(0) in_keys(UserIdToRole)
    ensures true
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
