//@ proof
require "trusted-change-user-role-New.k"  //@ Bazel remove

module PROOF-PERFORM-ACTION-ADD-BOARD-MEMBER-NEW
  imports TRUSTED-CHANGE-USER-ROLE-NEW
//@ trusted
// module TRUSTED-PERFORM-ACTION-ADD-BOARD-MEMBER-NEW
//@ end

  imports EXECUTION-PROOF-HELPERS
  imports PSEUDOCODE

  claim
      <T> <TT>
          <k> call(performAction(
                  AddBoardMember(UserAddress:Address) #as Action:Action
              )) ~> K:K
          </k>
          <state>
            <multisig-state>
              <users>
                <num-users>u(NumUsers:Int)</num-users>
                <user-id-to-address>UserIdToAddress:Map</user-id-to-address>
                <address-to-user-id>AddressToUserId:Map</address-to-user-id>
              </users>
              <board-state>
                <num-board-members>u(NumBoardMembers:Int)</num-board-members>
                <num-proposers>NumProposers:Usize</num-proposers>
                <user-roles>UserIdToRole:Map</user-roles>
                <quorum>Quorum:Usize</quorum>
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
          <k> evaluate(void) ~> K </k>
          <state>
            <multisig-state>
              <users>
                <num-users>u(NumUsers +Int 1)</num-users>
                <user-id-to-address>u(NumUsers +Int 1) |-> UserAddress UserIdToAddress</user-id-to-address>
                <address-to-user-id>UserAddress |-> u(NumUsers +Int 1) AddressToUserId</address-to-user-id>
              </users>
              <board-state>
                <num-board-members>u(NumBoardMembers +Int 1)</num-board-members>
                <num-proposers>NumProposers</num-proposers>
                <user-roles>u(NumUsers +Int 1) |-> BoardMember UserIdToRole</user-roles>
                <quorum>Quorum</quorum>
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

      andBool NumUsers >=Int 0
      // TODO: Perhaps replace with unusedIdsInMapValues(AddressToUserId) +
      // someting to map values to keys.
      andBool unusedIdsInMapKeys(NumUsers +Int 1, keysMap(UserIdToAddress), expand(expanded))
      andBool unusedIdsInMapKeys(NumUsers +Int 1, keysMap(UserIdToRole), expand(expanded))

      andBool notBool UserAddress in_keys(AddressToUserId)
    ensures true
    //@ proof
    //@ trusted
    // [trusted]
    //@ end

endmodule
