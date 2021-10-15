//@ proof
require "trusted-perform-action-remove-user-Proposer-nobody-left.k"  //@ Bazel remove

module PROOF-PERFORM-ACTION-ID-REMOVE-USER-PROPOSER-NOBODY-LEFT
  imports TRUSTED-PERFORM-ACTION-REMOVE-USER-PROPOSER-NOBODY-LEFT
//@ trusted
// module TRUSTED-PERFORM-ACTION-ID-REMOVE-USER-PROPOSER-NOBODY-LEFT
//@ end

  imports INVARIANT-HELPERS
  imports PSEUDOCODE

  claim
      <T> <TT>
          <k> call(performActionFromId(ActionId:Usize)) ~> K:K </k>
          <state>
            <multisig-state>
              <users>
                <num-users>u(NumUsers:Int)</num-users>
                <user-id-to-address>UserIdToAddress:Map</user-id-to-address>
                <address-to-user-id>(UserAddress |-> u(UserId:Int) _AddressToUserId:Map) #as AddressToUserId:Map</address-to-user-id>
              </users>
              <board-state>
                <num-board-members>u(NumBoardMembers:Int)</num-board-members>
                <num-proposers>u(NumProposers:Int)</num-proposers>
                <user-roles>(u(UserId:Int) |-> Proposer _UserIdToRole:Map) #as UserIdToRole:Map</user-roles>
                <quorum>u(Quorum:Int)</quorum>
              </board-state>
              <action-state>
                <action-last-index>ActionLastIndex:Usize</action-last-index>
                <actions>
                  <action-data>
                      ActionId |-> RemoveUser(UserAddress:Address) #as Action:Action
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
                <num-users>u(NumUsers)</num-users>
                <user-id-to-address>UserIdToAddress</user-id-to-address>
                <address-to-user-id>AddressToUserId</address-to-user-id>
              </users>
              <board-state>
                <num-board-members>u(NumBoardMembers)</num-board-members>
                <num-proposers>u(NumProposers)</num-proposers>
                <user-roles>UserIdToRole</user-roles>
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
      andBool Quorum <=Int NumBoardMembers

      andBool NumBoardMembers +Int NumProposers ==Int 1
    ensures true
    //@ proof
    //@ trusted
    // [trusted]
    //@ end

endmodule
