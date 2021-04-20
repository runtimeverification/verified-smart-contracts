//@ proof
require "trusted-perform-parts-add-proposer-BoardMember-eq.k"  //@ Bazel remove
require "trusted-perform-parts-add-proposer-BoardMember-no-quorum-eq.k"  //@ Bazel remove
require "trusted-perform-parts-add-proposer-BoardMember-no-quorum.k"  //@ Bazel remove
require "trusted-perform-parts-add-proposer-BoardMember.k"  //@ Bazel remove
require "trusted-perform-parts-add-proposer-New.k"  //@ Bazel remove
require "trusted-perform-parts-add-proposer-None.k"  //@ Bazel remove
require "trusted-perform-parts-add-proposer-Proposer-eq.k"  //@ Bazel remove
require "trusted-perform-parts-add-proposer-Proposer.k"  //@ Bazel remove

module PROOF-PERFORM-PARTS-ADD-PROPOSER
  imports INVARIANT-EXECUTION

  imports TRUSTED-PERFORM-PARTS-ADD-PROPOSER-BOARDMEMBER-EQ
  imports TRUSTED-PERFORM-PARTS-ADD-PROPOSER-BOARDMEMBER-NO-QUORUM-EQ
  imports TRUSTED-PERFORM-PARTS-ADD-PROPOSER-BOARDMEMBER-NO-QUORUM
  imports TRUSTED-PERFORM-PARTS-ADD-PROPOSER-BOARDMEMBER
  imports TRUSTED-PERFORM-PARTS-ADD-PROPOSER-NEW
  imports TRUSTED-PERFORM-PARTS-ADD-PROPOSER-NONE
  imports TRUSTED-PERFORM-PARTS-ADD-PROPOSER-PROPOSER-EQ
  imports TRUSTED-PERFORM-PARTS-ADD-PROPOSER-PROPOSER
//@ trusted
// module TRUSTED-PERFORM-PARTS-ADD-PROPOSER
//@ end

  claim <T><TT>
          <k> action-splitted
              ~> call(performActionEndpoint(ActionId:Usize))
              ~> popContext
              ~> evaluateReturnValue
              ~> clearExternalCallEnv
              ~> runExternalCalls(EC:ExternalCommands)
          </k>
          invariantState(
              NumUsers:Usize,
              UserIdToAddress:Map,
              AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              UserRoles:Map,
              Quorum:Usize,
              ActionLastIndex0:Usize,
              ActionData0:Map,
              ActionSigners0:Map,
              _PerformedActions:List)
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
              ?UserRoles1:Map,
              ?Quorum1:Usize,
              ?ActionLastIndex1:Usize,
              ?ActionData1:Map,
              ?ActionSigners1:Map,
              ?_PerformedActions:List):StateCell
        </TT></T>
    requires true
        andBool invariant(
            NumUsers:Usize,
            UserIdToAddress:Map,
            AddressToUserId:Map,
            NumBoardMembers:Usize,
            NumProposers:Usize,
            UserRoles:Map,
            Quorum:Usize,
            ActionLastIndex0:Usize,
            ActionData0:Map,
            ActionSigners0:Map,
            expand(expanded))
        andBool ActionId in_keys(ActionData)
        andBool isAddProposer({ActionData[ActionId]}:>Action)
    ensures invariant(
        ?NumUsers1:Usize,
        ?UserIdToAddress1:Map,
        ?AddressToUserId1:Map,
        ?NumBoardMembers1:Usize,
        ?NumProposers1:Usize,
        ?UserRoles1:Map,
        ?Quorum1:Usize,
        ?ActionLastIndex1:Usize,
        ?ActionData1:Map,
        ?ActionSigners1:Map,
        usesExpanded)
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
