//@ proof
require "trusted-perform-action-endpoint-fragment-performs.k"  //@ Bazel remove
require "trusted-perform-action-endpoint-id-remove-user-BoardMember.k"  //@ Bazel remove

module PROOF-PERFORM-ACTION-ENDPOINT-REMOVE-USER-BOARDMEMBER-EQ
  imports TRUSTED-PERFORM-ACTION-ENDPOINT-FRAGMENT-PERFORMS
  imports TRUSTED-PERFORM-ACTION-ID-REMOVE-USER-BOARDMEMBER
//@ trusted
// module TRUSTED-PERFORM-ACTION-ENDPOINT-REMOVE-USER-BOARDMEMBER-EQ
//@ end
  imports FUNCTIONS-EXECUTE

  claim <T><TT>
          <k> call(performActionEndpoint(ActionId:Usize)) ~> K:K </k>
          invariantStateFull(
              NumUsers:Usize,
              UserIdToAddress:Map,
              (CallerAddress |-> CallerId:Usize
                  _AddressToUserId:Map
              ) #as AddressToUserId:Map,
              u(NumBoardMembers:Int),
              u(NumProposers:Int),
              CallerId |-> BoardMember
                  UserIdToRole:Map,
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
              u(NumBoardMembers -Int 1),
              u(NumProposers),
              UserIdToRole,
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
        andBool NumBoardMembers +Int NumProposers -Int 1 >Int 0
        andBool Quorum <=Int NumBoardMembers -Int 1

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
