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
        invariantStateStack(
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
            CallerAddress:Address,
            ListItem(stackEntry(_:MultisigStateCell, _:Map))
              ListItem(stackEntry(_:MultisigStateCell, _:Map))
              ListItem(stackEntry(
                invariantMultisigState(
                    NumUsersS:Usize,
                    UserIdToAddressS:Map,
                    AddressToUserIdS:Map,
                    NumBoardMembersS:Usize,
                    NumProposersS:Usize,
                    UserRolesS:Map,
                    QuorumS:Usize,
                    ActionLastIndexS:Usize,
                    ActionDataS:Map,
                    ActionSignersS:Map):MultisigStateCell,
                .Map)),
            _PerformedActions:List)
      </TT></T>
    =>
      <T><TT>
        <k> clearExternalCallEnv
            ~> runExternalCalls(EC) </k>
        invariantStateStack(
            u(?NumUsers1:Int),
            ?UserIdToAddress1:Map,
            ?AddressToUserId1:Map,
            u(?NumBoardMembers1:Int),
            u(?NumProposers1:Int),
            ?UserRoles1:Map,
            u(?Quorum1:Int),
            u(?ActionLastIndex1:Int),
            ?ActionData1:Map,
            ?ActionSigners1:Map,
            CallerAddress:Address,
            .List,
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
        invariantStateStack(
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
            CallerAddress:Address,
            ListItem(stackEntry(_:MultisigStateCell, _:Map, _:List))
              ListItem(stackEntry(_:MultisigStateCell, _:Map, _:List))
              ListItem(stackEntry(
                invariantMultisigState(
                    NumUsersS:Usize,
                    UserIdToAddressS:Map,
                    AddressToUserIdS:Map,
                    NumBoardMembersS:Usize,
                    NumProposersS:Usize,
                    UserRolesS:Map,
                    QuorumS:Usize,
                    ActionLastIndexS:Usize,
                    ActionDataS:Map,
                    ActionSignersS:Map):MultisigStateCell,
                .Map,
                _PerformedActionsS:List)),
            _PerformedActions:List)
      </TT></T>
    =>
      <T><TT>
        <k> clearExternalCallEnv
            ~> runExternalCalls(EC) </k>
        invariantStateStack(
            u(?NumUsers1:Int),
            ?UserIdToAddress1:Map,
            ?AddressToUserId1:Map,
            u(?NumBoardMembers1:Int),
            u(?NumProposers1:Int),
            ?UserRoles1:Map,
            u(?Quorum1:Int),
            u(?ActionLastIndex1:Int),
            ?ActionData1:Map,
            ?ActionSigners1:Map,
            CallerAddress:Address,
            .List,
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
