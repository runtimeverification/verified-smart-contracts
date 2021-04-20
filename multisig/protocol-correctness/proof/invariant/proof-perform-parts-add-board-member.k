//@ proof
require "trusted-perform-parts-add-board-member-BoardMember-eq.k"  //@ Bazel remove
require "trusted-perform-parts-add-board-member-BoardMember.k"  //@ Bazel remove
require "trusted-perform-parts-add-board-member-New.k"  //@ Bazel remove
require "trusted-perform-parts-add-board-member-None.k"  //@ Bazel remove
require "trusted-perform-parts-add-board-member-Proposer-eq.k"  //@ Bazel remove
require "trusted-perform-parts-add-board-member-Proposer.k"  //@ Bazel remove

module PROOF-PERFORM-PARTS-ADD-BOARD-MEMBER
  imports INVARIANT-EXECUTION

  imports TRUSTED-PERFORM-PARTS-ADD-BOARD-MEMBER-BOARDMEMBER-EQ
  imports TRUSTED-PERFORM-PARTS-ADD-BOARD-MEMBER-BOARDMEMBER
  imports TRUSTED-PERFORM-PARTS-ADD-BOARD-MEMBER-NEW
  imports TRUSTED-PERFORM-PARTS-ADD-BOARD-MEMBER-NONE
  imports TRUSTED-PERFORM-PARTS-ADD-BOARD-MEMBER-PROPOSER-EQ
  imports TRUSTED-PERFORM-PARTS-ADD-BOARD-MEMBER-PROPOSER
//@ trusted
// module TRUSTED-PERFORM-PARTS-ADD-BOARD-MEMBER
//@ end
  imports PERFORM-ACTION-ENDPOINT-INSTRUMENTATION

  claim <T><TT>
          <k> splitPerformActionEndpoint4(AddBoardMember(_UserAddress:Address) #as Action:Action)
              ~> call(performActionEndpoint(ActionId:Usize))
              ~> popContext
              ~> evaluateReturnValue
              ~> clearExternalCallEnv
              ~> splitActionSigners(ActionId:Usize, ActionSigners:Map)
              ~> runExternalCalls(EC:ExternalCommands)
          </k>
          invariantStateStack(
              NumUsers:Usize,
              UserIdToAddress:Map,
              (CallerAddress |-> CallerId:Usize _AddressToUserId:Map) #as AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              UserIdToRole:Map,
              u(Quorum:Int),
              ActionLastIndex0:Usize,
              (ActionId |-> Action ActionData0:Map) #as ActionData:Map,
              ActionSigners:Map,
              CallerAddress:Address,
              stack(
                  invariantMultisigState(
                      NumUsers,
                      UserIdToAddress,
                      AddressToUserId,
                      NumBoardMembers,
                      NumProposers,
                      UserIdToRole,
                      u(Quorum),
                      ActionLastIndex0,
                      ActionData,
                      ActionSigners),
                  .Map,
                  PerformedActions,
                  .stack),
              PerformedActions:List)
        </TT></T>
      =>
        <T><TT>
          <k> runExternalCalls(EC) </k>
          invariantState(
              ?NumUsers1:Usize,
              ?UserIdToAddress1:Map,
              ?AddressToUserId1:Map,
              ?NumBoardMembers1:Usize,
              ?NumProposers1:Usize,
              ?UserIdToRole1:Map,
              ?Quorum1:Usize,
              ?ActionLastIndex1:Usize,
              ?ActionData1:Map,
              ?ActionSigners1:Map,
              ?_PerformedActions:List):StateCell
        </TT></T>
    requires true
        andBool invariant(
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            NumBoardMembers,
            NumProposers,
            UserIdToRole,
            u(Quorum),
            ActionLastIndex0,
            ActionData0,
            ActionSigners,
            expand(expanded))
        andBool CallerId in_keys(UserIdToRole)
        andBool Quorum <=Int countCanSignFunction({ActionSigners[ActionId] orDefault [.]}:>ExpressionList, opaque(UserIdToRole))
    ensures invariant(
        ?NumUsers1,
        ?UserIdToAddress1,
        ?AddressToUserId1,
        ?NumBoardMembers1,
        ?NumProposers1,
        ?UserIdToRole1,
        ?Quorum1,
        ?ActionLastIndex1,
        ?ActionData1,
        ?ActionSigners1,
        usesExpanded)
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
