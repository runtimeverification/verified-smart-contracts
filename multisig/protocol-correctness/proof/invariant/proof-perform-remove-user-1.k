require "../functions/functions-execute.k"

require "../functions/proof-change-user-role-New.k"
require "../functions/proof-change-user-role-None.k"
require "../functions/proof-change-user-role-BoardMember.k"
require "../functions/proof-change-user-role-Proposer.k"

module TRUSTED-PERFORM-REMOVE-USER-1
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
            (UserId |-> BoardMember UserIdToRoleFinal:Map) #as UserIdToRole:Map,
            u(Quorum:Int),
            ActionState:ActionStateCell,
            Stack:List,
            CallerAddress:Address)
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
            u(Quorum),
            ActionState,
            ?_Variables:Map,
            Stack:List,
            CallerAddress)
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
        andBool Quorum <=Int NumBoardMembers -Int 1
        andBool (NumBoardMembers -Int 1 +Int NumProposers >Int 0)
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

module PROOF-PERFORM-REMOVE-USER-1
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
                _AddressToUserId:Map
            ) #as AddressToUserId:Map,
            u(NumBoardMembers:Int),
            u(NumProposers:Int),
            (UserId |-> BoardMember UserIdToRoleFinal:Map) #as UserIdToRole:Map,
            u(Quorum:Int),
            ActionState:ActionStateCell,
            .List, // TODO: Stack:List,
            CallerAddress:Address)
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
            u(Quorum),
            ActionState,
            ?_Variables:Map,
            .List, // TODO: Stack:List,
            CallerAddress)
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
        andBool Quorum <=Int NumBoardMembers -Int 1
        andBool (NumBoardMembers -Int 1 +Int NumProposers >Int 0)
    ensures performEnsures(
            u(?NumUsersFinal),
            ?UserIdToAddressFinal,
            ?AddressToUserIdFinal,
            u(?NumBoardMembersFinal),
            u(?NumProposersFinal),
            UserIdToRoleFinal,
            u(Quorum))

endmodule
