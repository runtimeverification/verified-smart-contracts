//@ proof
require "trusted-perform-parts-add-proposer-BoardMember.k"  //@ Bazel remove
require "trusted-perform-parts-add-proposer-BoardMember-no-quorum.k"  //@ Bazel remove
require "trusted-perform-parts-add-proposer-Proposer.k"  //@ Bazel remove

module PROOF-PERFORM-PARTS-ADD-PROPOSER-SIGNERS-NEQ
  imports INVARIANT-EXECUTION

  imports TRUSTED-PERFORM-PARTS-ADD-PROPOSER-BOARDMEMBER
  imports TRUSTED-PERFORM-PARTS-ADD-PROPOSER-BOARDMEMBER-NO-QUORUM
  imports TRUSTED-PERFORM-PARTS-ADD-PROPOSER-PROPOSER
//@ trusted
// module TRUSTED-PERFORM-PARTS-ADD-PROPOSER-SIGNERS-NEQ
//@ end

  imports PERFORM-ACTION-ENDPOINT-INSTRUMENTATION

  claim <T><TT>
          <k> splitAddProposer3(UserAddress)
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
              (CallerAddress |-> CallerId:Usize
                  UserAddress |-> UserId:Usize
                  _AddressToUserId:Map
              ) #as AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              (CallerId |-> CallerRole:UserRole _UserIdToRole:Map) #as UserIdToRole:Map,
              u(Quorum:Int),
              ActionLastIndex0:Usize,
              (ActionId |-> AddProposer(UserAddress) ActionData0:Map) #as ActionData:Map,
              (ActionId |-> _Signers:ExpressionList _ActionSigners:Map) #as ActionSigners:Map,
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
        andBool (CallerRole ==K BoardMember orBool CallerRole ==K Proposer)
        andBool Quorum <=Int countCanSignFunction({ActionSigners[ActionId] orDefault [.]}:>ExpressionList, opaque(UserIdToRole))
        andBool notBool UserAddress ==K CallerAddress
        andBool UserId in_keys(UserIdToRole)
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
