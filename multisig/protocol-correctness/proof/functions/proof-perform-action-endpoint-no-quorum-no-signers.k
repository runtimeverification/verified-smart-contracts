//@ proof
require "trusted-perform-action-endpoint-fragment-no-quorum-no-signers.k"  //@ Bazel remove

module PROOF-PERFORM-ACTION-ENDPOINT-NO-QUORUM-NO-SIGNERS
  imports TRUSTED-PERFORM-ACTION-ENDPOINT-FRAGMENT-NO-QUORUM-NO-SIGNERS
//@ trusted
// module TRUSTED-PERFORM-ACTION-ENDPOINT-NO-QUORUM-NO-SIGNERS
//@ end
  imports FUNCTIONS-EXECUTE

  claim <T><TT>
          <k> call(performActionEndpoint(ActionId:Usize)) ~> K:K </k>
          invariantStateFull(
              NumUsers:Usize,
              UserIdToAddress:Map,
              (CallerAddress |-> UserId:Usize _AddressToUserId:Map) #as AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              (UserId |-> Role:UserRole _UserIdToRole:Map) #as UserIdToRole:Map,
              u(Quorum:Int),
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
              u(Quorum),
              ActionLastIndex,
              ActionData,
              ActionSigners,
              CallerAddress,
              Stack,
              caller_address |-> CallerAddress
                caller_id |-> UserId
                caller_role |-> Role,
              PerformedActions
              )
        </TT></T>
    requires true
        andBool (Role ==K BoardMember orBool Role ==K Proposer)
        andBool notBool ActionId in_keys(ActionSigners)
        andBool Quorum >Int 0
    ensures true
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
