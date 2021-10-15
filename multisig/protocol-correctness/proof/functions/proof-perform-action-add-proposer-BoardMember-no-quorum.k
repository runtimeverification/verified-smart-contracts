//@ proof
require "trusted-change-user-role-BoardMember.k"  //@ Bazel remove

module PROOF-PERFORM-ACTION-ADD-PROPOSER-BOARDMEMBER-NO-QUORUM
  imports TRUSTED-CHANGE-USER-ROLE-BOARDMEMBER
//@ trusted
// module TRUSTED-PERFORM-ACTION-ADD-PROPOSER-BOARDMEMBER-NO-QUORUM
//@ end

  imports INVARIANT-HELPERS
  imports PSEUDOCODE

  claim
      <T> <TT>
          <k> call(performAction(
                  AddProposer(UserAddress:Address) #as Action:Action
              )) ~> K:K
          </k>
          <state>
            <multisig-state>
              <users>
                <num-users>NumUsers:Usize</num-users>
                <user-id-to-address>UserIdToAddress:Map</user-id-to-address>
                <address-to-user-id>(UserAddress |-> UserId:Usize _AddressToUserId:Map) #as AddressToUserId:Map</address-to-user-id>
              </users>
              <board-state>
                <num-board-members>u(NumBoardMembers:Int)</num-board-members>
                <num-proposers>u(NumProposers:Int)</num-proposers>
                <user-roles>UserId |-> BoardMember UserIdToRole:Map</user-roles>
                <quorum>u(Quorum:Int)</quorum>
              </board-state>
              ActionState:ActionStateCell
            </multisig-state>
            <pseudocode-state>
              <variables>.Map</variables>
              <stack>Stack:Stack</stack>
            </pseudocode-state>
            <external-call-env>
              <caller-address>CallerAddress:Address</caller-address>
            </external-call-env>
            <log>
              <performed-actions>PerformedActions:List</performed-actions>
            </log>
          </state>
      </TT> </T>
      =>
      <T> <TT>
          <k> error ~> K </k>
          <state>
            <multisig-state>
              <users>
                <num-users>NumUsers</num-users>
                <user-id-to-address>UserIdToAddress</user-id-to-address>
                <address-to-user-id>AddressToUserId</address-to-user-id>
              </users>
              <board-state>
                <num-board-members>u(NumBoardMembers -Int 1)</num-board-members>
                <num-proposers>u(NumProposers +Int 1)</num-proposers>
                <user-roles>UserId |-> Proposer UserIdToRole:Map</user-roles>
                <quorum>u(Quorum)</quorum>
              </board-state>
              ActionState
            </multisig-state>
            <pseudocode-state>
              <variables>?_Variables:Map</variables>
              <stack>Stack</stack>
            </pseudocode-state>
            <external-call-env>
              <caller-address>CallerAddress</caller-address>
            </external-call-env>
            <log>
              <performed-actions>ListItem(Action) PerformedActions</performed-actions>
            </log>
          </state>
      </TT> </T>
    requires true
      andBool isKResult(Action)
      andBool addressToUserIdInvariant(AddressToUserId)

      andBool Quorum ==Int NumBoardMembers
    ensures true
    //@ proof
    //@ trusted
    // [trusted]
    //@ end

endmodule
