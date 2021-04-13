require "../functions/functions-execute.k"

require "../functions/trusted-change-user-role-New.k"
require "../functions/trusted-change-user-role-BoardMember.k"
require "../functions/trusted-change-user-role-Proposer.k"
require "../functions/trusted-change-user-role-None.k"

module TRUSTED-PERFORM-ADD-BOARD-MEMBER
  imports INVARIANT-EXECUTION

  claim
      <T>
        performLhs(
            AddBoardMember(_BoardMemberAddress:Address) #as Action:Action,
            K:K,
            NumUsers:Usize,
            UserIdToAddress:Map,
            AddressToUserId:Map,
            NumBoardMembers:Usize,
            NumProposers:Usize,
            UserIdToRole:Map,
            Quorum:Usize,
            ActionState:ActionStateCell,
            Stack:Stack,
            CallerAddress:Address,
            PerformedActions:List)
      </T>
      =>
      <T>
        performRhs(
            evaluate(void),
            K,
            u(?NumUsersFinal:Int),
            ?UserIdToAddressFinal:Map,
            ?AddressToUserIdFinal:Map,
            u(?NumBoardMembersFinal:Int),
            u(?NumProposersFinal:Int),
            ?UserIdToRoleFinal:Map,
            Quorum,
            ActionState,
            ?_Variables:Map,
            Stack:Stack,
            CallerAddress,
            ListItem(Action) PerformedActions:List)
      </T>
    requires performRequires(
            Action,
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            NumBoardMembers,
            NumProposers,
            UserIdToRole,
            Quorum)
    ensures performEnsures(
            u(?NumUsersFinal),
            ?UserIdToAddressFinal,
            ?AddressToUserIdFinal,
            u(?NumBoardMembersFinal),
            u(?NumProposersFinal),
            ?UserIdToRoleFinal,
            Quorum)
    [trusted]
endmodule

module PROOF-PERFORM-ADD-BOARD-MEMBER
  imports INVARIANT-EXECUTION

  imports TRUSTED-CHANGE-USER-ROLE-NEW
  imports TRUSTED-CHANGE-USER-ROLE-NONE
  imports TRUSTED-CHANGE-USER-ROLE-BOARDMEMBER
  imports TRUSTED-CHANGE-USER-ROLE-PROPOSER

  claim
      <T>
        performLhs(
            AddBoardMember(_BoardMemberAddress:Address) #as Action:Action,
            K:K,
            NumUsers:Usize,
            UserIdToAddress:Map,
            AddressToUserId:Map,
            NumBoardMembers:Usize,
            NumProposers:Usize,
            UserIdToRole:Map,
            Quorum:Usize,
            ActionState:ActionStateCell,
            Stack:Stack,
            CallerAddress:Address,
            PerformedActions:List)
      </T>
      =>
      <T>
        performRhs(
            evaluate(void),
            K,
            u(?NumUsersFinal:Int),
            ?UserIdToAddressFinal:Map,
            ?AddressToUserIdFinal:Map,
            u(?NumBoardMembersFinal:Int),
            u(?NumProposersFinal:Int),
            ?UserIdToRoleFinal:Map,
            Quorum,
            ActionState,
            ?_Variables:Map,
            Stack:Stack,
            CallerAddress,
            ListItem(Action) PerformedActions:List)
      </T>
    requires performRequires(
            Action,
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            NumBoardMembers,
            NumProposers,
            UserIdToRole,
            Quorum)
    ensures performEnsures(
            u(?NumUsersFinal),
            ?UserIdToAddressFinal,
            ?AddressToUserIdFinal,
            u(?NumBoardMembersFinal),
            u(?NumProposersFinal),
            ?UserIdToRoleFinal,
            Quorum)
endmodule
