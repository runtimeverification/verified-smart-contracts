//@ proof
require "../functions/trusted-perform-action-endpoint-add-proposer-None.k"  //@ Bazel remove

module PROOF-PERFORM-PARTS-ADD-PROPOSER-NONE
  imports TRUSTED-PERFORM-ACTION-ENDPOINT-ADD-PROPOSER-NONE
//@ trusted
// module TRUSTED-PERFORM-PARTS-ADD-PROPOSER-NONE
//@ end

  imports PERFORM-ACTION-ENDPOINT-INSTRUMENTATION

  claim <T><TT>
          <k> add-proposer-None.k ~> call(performActionEndpoint(ActionId:Usize)) ~> K:K </k>
          invariantStateFull(
              NumUsers:Usize,
              UserIdToAddress:Map,
              (CallerAddress |-> CallerId:Usize
                  UserAddress |-> UserId:Usize
                  _AddressToUserId:Map
              ) #as AddressToUserId:Map,
              u(NumBoardMembers:Int),
              u(NumProposers:Int),
              (CallerId |-> Role:UserRole
                  _UserIdToRole:Map
              ) #as UserIdToRole:Map,
              u(Quorum:Int),
              ActionLastIndex:Usize,
              ActionId |-> AddProposer(UserAddress:Address) #as Action:Action
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
              u(NumProposers +Int 1),
              UserId |-> Proposer UserIdToRole,
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
        andBool notBool UserId in_keys(UserIdToRole)

        // perform-fragment
        andBool actionSignersInvariant(ActionSigners)
        andBool userIdToRoleInvariant(UserIdToRole)
        andBool (Role ==K BoardMember orBool Role ==K Proposer)
        andBool Quorum <=Int countCanSignFunction({ActionSigners[ActionId] orDefault [.]}:>ExpressionList, opaque(UserIdToRole))
    ensures true
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
