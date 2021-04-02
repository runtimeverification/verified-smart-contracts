require "../functions/functions-execute.k"

require "../functions/trusted-change-user-role-New.k"
require "../functions/trusted-change-user-role-None.k"
require "../functions/trusted-change-user-role-BoardMember.k"
require "../functions/trusted-change-user-role-Proposer.k"

module TRUSTED-PERFORM-REMOVE-USER-5
  imports INVARIANT-EXECUTION

  claim
      <T>
        performLhs(
            RemoveUser(UserAddress:Address) #as Action:Action,
            K:K,
            NumUsers:Usize,
            UserIdToAddress:Map,
            (
                UserAddress |-> UserId:Usize
                _AddressToUserId:Map
            ) #as AddressToUserId:Map,
            u(NumBoardMembers:Int),
            u(NumProposers:Int),
            (UserId |-> UserRole:KItem UserIdToRoleFinal:Map) #as UserIdToRole:Map,
            u(Quorum:Int),
            ActionState:ActionStateCell,
            Stack:List,
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
            UserIdToRoleFinal,
            u(Quorum:Int),
            ActionState,
            ?_Variables:Map,
            Stack:List,
            CallerAddress,
            ListItem(Action) PerformedActions:List)
      </T>
    requires performRequiresHandling(
            Action,
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            u(NumBoardMembers),
            u(NumProposers),
            UserIdToRole,
            u(Quorum),
            usesExpanded)
        andBool notBool (UserRole ==K BoardMember)
        andBool Quorum <=Int NumBoardMembers
        andBool (NumBoardMembers +Int (NumProposers -Int 1) >Int 0)
    ensures performEnsuresHandling(
            u(?NumUsersFinal),
            ?UserIdToAddressFinal,
            ?AddressToUserIdFinal,
            u(?NumBoardMembersFinal),
            u(?NumProposersFinal),
            UserIdToRoleFinal,
            u(Quorum),
            expanded)
    [trusted]

endmodule

module PROOF-PERFORM-REMOVE-USER-5
  imports INVARIANT-EXECUTION

  imports TRUSTED-CHANGE-USER-ROLE-NEW
  imports TRUSTED-CHANGE-USER-ROLE-NONE
  imports TRUSTED-CHANGE-USER-ROLE-BOARDMEMBER
  imports TRUSTED-CHANGE-USER-ROLE-PROPOSER

  claim
      <T>
        performLhs(
            RemoveUser(UserAddress:Address) #as Action:Action,
            K:K,
            NumUsers:Usize,
            UserIdToAddress:Map,
            (
                UserAddress |-> UserId:Usize
                CallerAddress |-> _:Usize
                _AddressToUserId:Map
            ) #as AddressToUserId:Map,
            u(NumBoardMembers:Int),
            u(NumProposers:Int),
            (UserId |-> UserRole:KItem UserIdToRoleFinal:Map) #as UserIdToRole:Map,
            u(Quorum:Int),
            ActionState:ActionStateCell,
            .List, // TODO: Stack:List,
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
            UserIdToRoleFinal,
            u(Quorum:Int),
            ActionState,
            ?_Variables:Map,
            .List, // TODO: Stack:List,
            CallerAddress,
            ListItem(Action) PerformedActions:List)
      </T>
    requires performRequires(
            Action,
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            u(NumBoardMembers),
            u(NumProposers),
            UserIdToRole,
            u(Quorum))
        andBool notBool (UserAddress ==K CallerAddress)
        andBool notBool (UserRole ==K BoardMember)
        andBool Quorum <=Int NumBoardMembers
        andBool (NumBoardMembers +Int (NumProposers -Int 1) >Int 0)
    ensures performEnsures(
            u(?NumUsersFinal),
            ?UserIdToAddressFinal,
            ?AddressToUserIdFinal,
            u(?NumBoardMembersFinal),
            u(?NumProposersFinal),
            UserIdToRoleFinal,
            u(Quorum))

endmodule
