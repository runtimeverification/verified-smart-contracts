//@ proof
require "../functions/trusted-perform-action-endpoint-remove-user-Proposer-eq.k"  //@ Bazel remove

module PROOF-PERFORM-PARTS-REMOVE-USER-PROPOSER-EQ
  imports TRUSTED-PERFORM-ACTION-ENDPOINT-REMOVE-USER-PROPOSER-EQ
//@ trusted
// module TRUSTED-PERFORM-PARTS-REMOVE-USER-PROPOSER-EQ
//@ end

  imports PERFORM-ACTION-ENDPOINT-INSTRUMENTATION

  claim <T><TT>
          <k> remove-user-Proposer-eq.k ~> call(performActionEndpoint(ActionId:Usize)) ~> K:K </k>
          invariantStateFull(
              NumUsers:Usize,
              UserIdToAddress:Map,
              (CallerAddress |-> CallerId:Usize
                  _AddressToUserId:Map
              ) #as AddressToUserId:Map,
              u(NumBoardMembers:Int),
              u(NumProposers:Int),
              (CallerId |-> Proposer
                  UserIdToRoleInner:Map
              ) #as UserIdToRole,
              u(Quorum:Int),
              ActionLastIndex:Usize,
              ActionId |-> RemoveUser(CallerAddress:Address) #as Action:Action
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
          <k> evaluate(void) ~> K:K </k>
          invariantStateFull(
              NumUsers,
              UserIdToAddress,
              AddressToUserId,
              u(NumBoardMembers),
              u(NumProposers -Int 1),
              UserIdToRoleInner,
              u(Quorum),
              ActionLastIndex,
              ActionData,
              ActionSigners[ActionId <- undef],
              CallerAddress,
              Stack,
              ?_Variables:Map,
              ListItem(Action) PerformedActions
              )
        </TT></T>
    requires true
        // perform-from-id
        andBool isKResult(Action)
        andBool addressToUserIdInvariant(AddressToUserId)
        andBool Quorum <=Int NumBoardMembers
        andBool NumBoardMembers +Int NumProposers -Int 1 >Int 0

        // perform-fragment
        andBool actionSignersInvariant(ActionSigners)
        andBool userIdToRoleInvariant(UserIdToRole)
        andBool Quorum <=Int countCanSignFunction({ActionSigners[ActionId] orDefault [.]}:>ExpressionList, opaque(UserIdToRole))
    ensures true
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
