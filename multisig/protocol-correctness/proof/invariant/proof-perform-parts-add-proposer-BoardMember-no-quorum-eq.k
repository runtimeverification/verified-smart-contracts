//@ proof
require "../functions/trusted-perform-action-endpoint-add-proposer-BoardMember-no-quorum-eq.k"  //@ Bazel remove

module PROOF-PERFORM-PARTS-ADD-PROPOSER-BOARDMEMBER-NO-QUORUM-EQ
  imports TRUSTED-PERFORM-ACTION-ENDPOINT-ADD-PROPOSER-BOARDMEMBER-NO-QUORUM-EQ
//@ trusted
// module TRUSTED-PERFORM-PARTS-ADD-PROPOSER-BOARDMEMBER-NO-QUORUM-EQ
//@ end

  imports PERFORM-ACTION-ENDPOINT-INSTRUMENTATION

  claim <T><TT>
          <k> add-proposer-BoardMember-no-quorum-eq.k ~> call(performActionEndpoint(ActionId:Usize)) ~> K:K </k>
          invariantStateFull(
              NumUsers:Usize,
              UserIdToAddress:Map,
              (CallerAddress |-> CallerId:Usize
                  _AddressToUserId:Map
              ) #as AddressToUserId:Map,
              u(NumBoardMembers:Int),
              u(NumProposers:Int),
              (CallerId |-> BoardMember
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
          <k> error ~> K:K </k>
          invariantStateFull(
              NumUsers,
              UserIdToAddress,
              AddressToUserId,
              u(NumBoardMembers),
              u(NumProposers),
              UserIdToRole,
              u(Quorum),
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
        andBool addressToUserIdInvariant(AddressToUserId)
        andBool Quorum ==Int NumBoardMembers

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

