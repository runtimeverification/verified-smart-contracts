//@ proof
require "../functions/trusted-perform-action-endpoint-None.k"  //@ Bazel remove

module PROOF-PERFORM-PARTS-NONE
  imports TRUSTED-PERFORM-ACTION-ENDPOINT-NONE
//@ trusted
// module TRUSTED-PERFORM-PARTS-NONE
//@ end

  imports PERFORM-ACTION-ENDPOINT-INSTRUMENTATION

  claim <T><TT>
          <k> none.k ~> call(performActionEndpoint(_ActionId:Usize)) ~> K:K </k>
          invariantStateFull(
              NumUsers:Usize,
              UserIdToAddress:Map,
              (CallerAddress |-> UserId:Usize _AddressToUserId:Map) #as AddressToUserId:Map,
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
                caller_id |-> UserId
                caller_role |-> None,
              PerformedActions
              )
        </TT></T>
    requires true
        andBool notBool UserId in_keys(UserIdToRole)
    ensures true
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
