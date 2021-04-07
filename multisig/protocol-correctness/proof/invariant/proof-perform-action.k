require "proof-perform-add-board-member.k"
require "proof-perform-add-proposer-1.k"
require "proof-perform-add-proposer-3.k"
require "proof-perform-add-proposer-5.k"
require "proof-perform-add-proposer-7.k"
require "proof-perform-add-proposer-8.k"
require "proof-perform-add-proposer-9.k"
require "proof-perform-change-quorum.k"
require "proof-perform-nothing.k"
require "proof-perform-remove-user-1.k"
require "proof-perform-remove-user-3.k"
require "proof-perform-remove-user-5.k"
require "proof-perform-remove-user-7.k"
require "proof-perform-remove-user-9.k"
require "proof-perform-remove-user-10.k"
require "proof-perform-s-c-call.k"
require "proof-perform-s-c-deploy.k"
require "proof-perform-send-egld.k"

module TRUSTED-PERFORM-ACTION
  imports INVARIANT-EXECUTION

  claim
      <T><TT>
        <k>
          splitAction ( A:Action )
          ~> splitting-action
          ~> call ( performAction ( A ) )
          ~> popContext
          ~> evaluateReturnValue
          ~> popContext
          ~> evaluateReturnValue
          ~> popContext
          ~> evaluateReturnValue
          ~> clearExternalCallEnv
          ~> runExternalCalls ( EC )
        </k>
        <state>
          <multisig-state>
            <users>
              <num-users>NumUsers:Usize</num-users>
              <user-id-to-address>UserIdToAddress:Map</user-id-to-address>
              <address-to-user-id>AddressToUserId:Map</address-to-user-id>
            </users>
            <board-state>
              <num-board-members>NumBoardMembers:Usize</num-board-members>
              <num-proposers>NumProposers:Usize</num-proposers>
              <user-roles>UserRoles:Map</user-roles>
              <quorum>Quorum:Usize</quorum>
            </board-state>
            <action-state>
              <action-last-index>ActionLastIndex0:Usize</action-last-index>
              <actions>
                <action-data>ActionData0:Map</action-data>
                <action-signers>ActionSigners0:Map</action-signers>
              </actions>
            </action-state>
          </multisig-state>
          <pseudocode-state>
            <variables>.Map</variables>
            <stack>
              ListItem(stackEntry(
                <multisig-state>
                  <users>
                    <num-users>_:Usize</num-users>
                    <user-id-to-address>_:Map</user-id-to-address>
                    <address-to-user-id>_:Map</address-to-user-id>
                  </users>
                  <board-state>
                    <num-board-members>_:Usize</num-board-members>
                    <num-proposers>_:Usize</num-proposers>
                    <user-roles>_:Map</user-roles>
                    <quorum>_:Usize</quorum>
                  </board-state>
                  <action-state>
                    <action-last-index>_:Usize</action-last-index>
                    <actions>
                      <action-data>_:Map</action-data>
                      <action-signers>_:Map</action-signers>
                    </actions>
                  </action-state>
                </multisig-state>,
                _:Map))
              ListItem(stackEntry(
                <multisig-state>
                  <users>
                    <num-users>_:Usize</num-users>
                    <user-id-to-address>_:Map</user-id-to-address>
                    <address-to-user-id>_:Map</address-to-user-id>
                  </users>
                  <board-state>
                    <num-board-members>_:Usize</num-board-members>
                    <num-proposers>_:Usize</num-proposers>
                    <user-roles>_:Map</user-roles>
                    <quorum>_:Usize</quorum>
                  </board-state>
                  <action-state>
                    <action-last-index>_:Usize</action-last-index>
                    <actions>
                      <action-data>_:Map</action-data>
                      <action-signers>_:Map</action-signers>
                    </actions>
                  </action-state>
                </multisig-state>,
                _:Map))
              ListItem(stackEntry(
                <multisig-state>
                  <users>
                    <num-users>NumUsersS:Usize</num-users>
                    <user-id-to-address>UserIdToAddressS:Map</user-id-to-address>
                    <address-to-user-id>AddressToUserIdS:Map</address-to-user-id>
                  </users>
                  <board-state>
                    <num-board-members>NumBoardMembersS:Usize</num-board-members>
                    <num-proposers>NumProposersS:Usize</num-proposers>
                    <user-roles>UserRolesS:Map</user-roles>
                    <quorum>QuorumS:Usize</quorum>
                  </board-state>
                  <action-state>
                    <action-last-index>ActionLastIndexS:Usize</action-last-index>
                    <actions>
                      <action-data>ActionDataS:Map</action-data>
                      <action-signers>ActionSignersS:Map</action-signers>
                    </actions>
                  </action-state>
                </multisig-state>,
                .Map))
            </stack>
          </pseudocode-state>
          <external-call-env>
            <caller-address>CallerAddress:Address</caller-address>
          </external-call-env>
        </state>
      </TT></T>
    =>
      <T><TT>
        <k> clearExternalCallEnv
            ~> runExternalCalls(EC)
        </k>
        <state>
          <multisig-state>
            <users>
              <num-users>u(?NumUsers1:Int)</num-users>
              <user-id-to-address>?UserIdToAddress1:Map</user-id-to-address>
              <address-to-user-id>?AddressToUserId1:Map</address-to-user-id>
            </users>
            <board-state>
              <num-board-members>u(?NumBoardMembers1:Int)</num-board-members>
              <num-proposers>u(?NumProposers1:Int)</num-proposers>
              <user-roles>?UserRoles1:Map</user-roles>
              <quorum>u(?Quorum1:Int)</quorum>
            </board-state>
            <action-state>
              <action-last-index>u(?ActionLastIndex1:Int)</action-last-index>
              <actions>
                <action-data>?ActionData1:Map</action-data>
                <action-signers>?ActionSigners1:Map</action-signers>
              </actions>
            </action-state>
          </multisig-state>
          <pseudocode-state>
            <variables>.Map</variables>
            <stack>.List</stack>
          </pseudocode-state>
          <external-call-env>
            <caller-address>CallerAddress:Address</caller-address>
          </external-call-env>
        </state>
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
          usesExpanded)
      andBool invariant(
          NumUsersS:Usize,
          UserIdToAddressS:Map,
          AddressToUserIdS:Map,
          NumBoardMembersS:Usize,
          NumProposersS:Usize,
          UserRolesS:Map,
          QuorumS:Usize,
          ActionLastIndexS:Usize,
          ActionDataS:Map,
          ActionSignersS:Map,
          usesExpanded)
      andBool isKResult(A)
    ensures true
      andBool invariant(
          u(?NumUsers1),
          ?UserIdToAddress1,
          ?AddressToUserId1,
          u(?NumBoardMembers1),
          u(?NumProposers1),
          ?UserRoles1,
          u(?Quorum1),
          u(?ActionLastIndex1),
          ?ActionData1,
          ?ActionSigners1,
          expanded)
  [trusted]
endmodule

module PROOF-PERFORM-ACTION
  imports INVARIANT-EXECUTION

  imports TRUSTED-PERFORM-ADD-BOARD-MEMBER
  imports TRUSTED-PERFORM-ADD-PROPOSER-1
  imports TRUSTED-PERFORM-ADD-PROPOSER-3
  imports TRUSTED-PERFORM-ADD-PROPOSER-5
  imports TRUSTED-PERFORM-ADD-PROPOSER-7
  imports TRUSTED-PERFORM-ADD-PROPOSER-8
  imports TRUSTED-PERFORM-ADD-PROPOSER-9
  imports TRUSTED-PERFORM-CHANGE-QUORUM
  imports TRUSTED-PERFORM-NOTHING
  imports TRUSTED-PERFORM-REMOVE-USER-1
  imports TRUSTED-PERFORM-REMOVE-USER-3
  imports TRUSTED-PERFORM-REMOVE-USER-5
  imports TRUSTED-PERFORM-REMOVE-USER-7
  imports TRUSTED-PERFORM-REMOVE-USER-9
  imports TRUSTED-PERFORM-REMOVE-USER-10
  imports TRUSTED-PERFORM-S-C-CALL
  imports TRUSTED-PERFORM-S-C-DEPLOY
  imports TRUSTED-PERFORM-SEND-EGLD

  claim
      <T><TT>
        <k>
          splitAction ( A:Action )
          ~> splitting-action
          ~> call ( performAction ( A ) )
          ~> popContext
          ~> evaluateReturnValue
          ~> popContext
          ~> evaluateReturnValue
          ~> popContext
          ~> evaluateReturnValue
          ~> clearExternalCallEnv
          ~> runExternalCalls ( EC )
        </k>
        <state>
          <multisig-state>
            <users>
              <num-users>NumUsers:Usize</num-users>
              <user-id-to-address>UserIdToAddress:Map</user-id-to-address>
              <address-to-user-id>AddressToUserId:Map</address-to-user-id>
            </users>
            <board-state>
              <num-board-members>NumBoardMembers:Usize</num-board-members>
              <num-proposers>NumProposers:Usize</num-proposers>
              <user-roles>UserRoles:Map</user-roles>
              <quorum>Quorum:Usize</quorum>
            </board-state>
            <action-state>
              <action-last-index>ActionLastIndex0:Usize</action-last-index>
              <actions>
                <action-data>ActionData0:Map</action-data>
                <action-signers>ActionSigners0:Map</action-signers>
              </actions>
            </action-state>
          </multisig-state>
          <pseudocode-state>
            <variables>.Map</variables>
            <stack>
              ListItem(stackEntry(
                <multisig-state>
                  <users>
                    <num-users>_:Usize</num-users>
                    <user-id-to-address>_:Map</user-id-to-address>
                    <address-to-user-id>_:Map</address-to-user-id>
                  </users>
                  <board-state>
                    <num-board-members>_:Usize</num-board-members>
                    <num-proposers>_:Usize</num-proposers>
                    <user-roles>_:Map</user-roles>
                    <quorum>_:Usize</quorum>
                  </board-state>
                  <action-state>
                    <action-last-index>_:Usize</action-last-index>
                    <actions>
                      <action-data>_:Map</action-data>
                      <action-signers>_:Map</action-signers>
                    </actions>
                  </action-state>
                </multisig-state>,
                _:Map))
              ListItem(stackEntry(
                <multisig-state>
                  <users>
                    <num-users>_:Usize</num-users>
                    <user-id-to-address>_:Map</user-id-to-address>
                    <address-to-user-id>_:Map</address-to-user-id>
                  </users>
                  <board-state>
                    <num-board-members>_:Usize</num-board-members>
                    <num-proposers>_:Usize</num-proposers>
                    <user-roles>_:Map</user-roles>
                    <quorum>_:Usize</quorum>
                  </board-state>
                  <action-state>
                    <action-last-index>_:Usize</action-last-index>
                    <actions>
                      <action-data>_:Map</action-data>
                      <action-signers>_:Map</action-signers>
                    </actions>
                  </action-state>
                </multisig-state>,
                _:Map))
              ListItem(stackEntry(
                <multisig-state>
                  <users>
                    <num-users>NumUsersS:Usize</num-users>
                    <user-id-to-address>UserIdToAddressS:Map</user-id-to-address>
                    <address-to-user-id>AddressToUserIdS:Map</address-to-user-id>
                  </users>
                  <board-state>
                    <num-board-members>NumBoardMembersS:Usize</num-board-members>
                    <num-proposers>NumProposersS:Usize</num-proposers>
                    <user-roles>UserRolesS:Map</user-roles>
                    <quorum>QuorumS:Usize</quorum>
                  </board-state>
                  <action-state>
                    <action-last-index>ActionLastIndexS:Usize</action-last-index>
                    <actions>
                      <action-data>ActionDataS:Map</action-data>
                      <action-signers>ActionSignersS:Map</action-signers>
                    </actions>
                  </action-state>
                </multisig-state>,
                .Map))
            </stack>
          </pseudocode-state>
          <external-call-env>
            <caller-address>CallerAddress:Address</caller-address>
          </external-call-env>
        </state>
      </TT></T>
    =>
      <T><TT>
        <k> clearExternalCallEnv
            ~> runExternalCalls(EC)
        </k>
        <state>
          <multisig-state>
            <users>
              <num-users>u(?NumUsers1:Int)</num-users>
              <user-id-to-address>?UserIdToAddress1:Map</user-id-to-address>
              <address-to-user-id>?AddressToUserId1:Map</address-to-user-id>
            </users>
            <board-state>
              <num-board-members>u(?NumBoardMembers1:Int)</num-board-members>
              <num-proposers>u(?NumProposers1:Int)</num-proposers>
              <user-roles>?UserRoles1:Map</user-roles>
              <quorum>u(?Quorum1:Int)</quorum>
            </board-state>
            <action-state>
              <action-last-index>u(?ActionLastIndex1:Int)</action-last-index>
              <actions>
                <action-data>?ActionData1:Map</action-data>
                <action-signers>?ActionSigners1:Map</action-signers>
              </actions>
            </action-state>
          </multisig-state>
          <pseudocode-state>
            <variables>.Map</variables>
            <stack>.List</stack>
          </pseudocode-state>
          <external-call-env>
            <caller-address>CallerAddress:Address</caller-address>
          </external-call-env>
        </state>
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
      andBool invariant(
          NumUsersS:Usize,
          UserIdToAddressS:Map,
          AddressToUserIdS:Map,
          NumBoardMembersS:Usize,
          NumProposersS:Usize,
          UserRolesS:Map,
          QuorumS:Usize,
          ActionLastIndexS:Usize,
          ActionDataS:Map,
          ActionSignersS:Map,
          expanded)
      andBool isKResult(A)
    ensures true
      andBool invariant(
          u(?NumUsers1),
          ?UserIdToAddress1,
          ?AddressToUserId1,
          u(?NumBoardMembers1),
          u(?NumProposers1),
          ?UserRoles1,
          u(?Quorum1),
          u(?ActionLastIndex1),
          ?ActionData1,
          ?ActionSigners1,
          usesExpanded)
endmodule
