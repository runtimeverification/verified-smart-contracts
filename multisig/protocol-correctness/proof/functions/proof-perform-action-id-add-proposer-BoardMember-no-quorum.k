//@ proof
require "trusted-perform-action-add-proposer-boardmember-no-quorum.k"  //@ Bazel remove

module PROOF-PERFORM-ACTION-ID-ADD-PROPOSER-BOARDMEMBER-NO-QUORUM
  imports TRUSTED-PERFORM-ACTION-ADD-PROPOSER-BOARDMEMBER-NO-QUORUM
//@ trusted
// module TRUSTED-PERFORM-ACTION-ID-ADD-PROPOSER-BOARDMEMBER-NO-QUORUM
//@ end

  imports INVARIANT-HELPERS
  imports PSEUDOCODE

  claim
      <T> <TT>
          <k> call(performActionFromId(ActionId:Usize)) ~> K:K </k>
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
                <user-roles>(UserId |-> BoardMember _UserIdToRole:Map) #as UserIdToRole:Map</user-roles>
                <quorum>u(Quorum:Int)</quorum>
              </board-state>
              <action-state>
                <action-last-index>ActionLastIndex:Usize</action-last-index>
                <actions>
                  <action-data>
                      ActionId |-> AddProposer(UserAddress:Address) #as Action:Action
                      ActionData:Map
                  </action-data>
                  <action-signers>ActionSigners:Map</action-signers>
                </actions>
              </action-state>
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
                <num-board-members>u(NumBoardMembers)</num-board-members>
                <num-proposers>u(NumProposers)</num-proposers>
                <user-roles>UserIdToRole:Map</user-roles>
                <quorum>u(Quorum)</quorum>
              </board-state>
              <action-state>
                <action-last-index>ActionLastIndex</action-last-index>
                <actions>
                  <action-data>ActionData</action-data>
                  <action-signers>ActionSigners[ActionId <- undef]</action-signers>
                </actions>
              </action-state>
            </multisig-state>
            <pseudocode-state>
              <variables>?_Variables:Map</variables>
              <stack>Stack</stack>
            </pseudocode-state>
            <external-call-env>
              <caller-address>CallerAddress</caller-address>
            </external-call-env>
            <log>
              <performed-actions>PerformedActions</performed-actions>
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
