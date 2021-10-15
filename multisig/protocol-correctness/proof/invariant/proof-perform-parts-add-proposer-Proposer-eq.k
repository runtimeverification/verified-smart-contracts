//@ proof
require "../functions/trusted-perform-action-endpoint-add-proposer-Proposer-eq.k"  //@ Bazel remove

module PROOF-PERFORM-PARTS-ADD-PROPOSER-PROPOSER-EQ
  imports TRUSTED-PERFORM-ACTION-ENDPOINT-ADD-PROPOSER-PROPOSER-EQ
//@ trusted
// module TRUSTED-PERFORM-PARTS-ADD-PROPOSER-PROPOSER-EQ
//@ end

  imports PERFORM-ACTION-ENDPOINT-INSTRUMENTATION

  claim <T><TT>
          <k> add-proposer-Proposer-eq.k ~> call(performActionEndpoint(ActionId:Usize)) ~> K:K </k>
          invariantStateFull(
              NumUsers:Usize,
              UserIdToAddress:Map,
              (CallerAddress |-> CallerId:Usize
                  _AddressToUserId:Map
              ) #as AddressToUserId:Map,
              u(NumBoardMembers:Int),
              NumProposers:Usize,
              (CallerId |-> Proposer
                  _UserIdToRole:Map
              ) #as UserIdToRole:Map,
              u(Quorum:Int),
              ActionLastIndex:Usize,
              ActionId |-> AddProposer(CallerAddress:Address) #as Action:Action
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
              NumProposers,
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
        andBool Quorum <=Int NumBoardMembers

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
