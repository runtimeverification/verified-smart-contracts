//@ proof
require "trusted-perform-action-endpoint-fragment-no-quorum-has-signers.k"  //@ Bazel remove

module PROOF-PERFORM-ACTION-ENDPOINT-NO-QUORUM
  imports TRUSTED-PERFORM-ACTION-ENDPOINT-FRAGMENT-NO-QUORUM
//@ trusted
// module TRUSTED-PERFORM-ACTION-ENDPOINT-NO-QUORUM
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
        andBool userIdToRoleInvariant(UserIdToRole)
        andBool actionSignersInvariant(ActionSigners)
        andBool (Role ==K BoardMember orBool Role ==K Proposer)
        andBool Quorum >Int countCanSignFunction({ActionSigners[ActionId] orDefault [.]}:>ExpressionList, opaque(UserIdToRole))
    ensures true
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
