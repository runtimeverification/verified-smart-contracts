//@ proof
require "../functions/trusted-perform-action-endpoint-change-quorum-no-quorum.k"  //@ Bazel remove

module PROOF-PERFORM-PARTS-CHANGE-QUORUM-NO-QUORUM
  imports TRUSTED-PERFORM-ACTION-ENDPOINT-CHANGE-QUORUM-NO-QUORUM
//@ trusted
// module TRUSTED-PERFORM-PARTS-CHANGE-QUORUM-NO-QUORUM
//@ end

  imports PERFORM-ACTION-ENDPOINT-INSTRUMENTATION

  claim <T><TT>
          <k> change-quorum-no-quorum.k ~> call(performActionEndpoint(ActionId:Usize)) ~> K:K </k>
          invariantStateFull(
              NumUsers:Usize,
              UserIdToAddress:Map,
              (CallerAddress |-> CallerId:Usize
                  _AddressToUserId:Map
              ) #as AddressToUserId:Map,
              u(NumBoardMembers:Int),
              NumProposers:Usize,
              (CallerId |-> Role:UserRole
                  _UserIdToRole:Map
              ) #as UserIdToRole:Map,
              u(OldQuorum:Int),
              ActionLastIndex:Usize,
              ActionId |-> ChangeQuorum(u(NewQuorum:Int)) #as Action:Action
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
              u(NumBoardMembers),
              NumProposers,
              UserIdToRole,
              u(OldQuorum),
              ActionLastIndex,
              ActionId |-> Action ActionData,
              ActionSigners,
              CallerAddress,
              Stack,
              ?_Variables:Map,
              PerformedActions
              )
        </TT></T>
    requires true
        // perform-from-id
        andBool isKResult(Action)
        andBool NewQuorum >Int NumBoardMembers

        // perform-fragment
        andBool actionSignersInvariant(ActionSigners)
        andBool userIdToRoleInvariant(UserIdToRole)
        andBool (Role ==K BoardMember orBool Role ==K Proposer)
        andBool OldQuorum <=Int countCanSignFunction({ActionSigners[ActionId] orDefault [.]}:>ExpressionList, opaque(UserIdToRole))
    ensures true
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
