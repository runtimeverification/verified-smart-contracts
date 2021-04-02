require "../functions/functions-execute.k"

require "../functions/trusted-change-user-role-New.k"
require "../functions/trusted-change-user-role-None.k"
require "../functions/trusted-change-user-role-BoardMember.k"
require "../functions/trusted-change-user-role-Proposer.k"

module TRUSTED-PERFORM-REMOVE-USER-9
  imports INVARIANT-EXECUTION

  claim
      <T>
        performLhs(
            RemoveUser(UserAddress:Address) #as Action:Action,
            K:K,
            NumUsers:Usize,
            UserIdToAddress:Map,
            AddressToUserId:Map,
            NumBoardMembers:Usize,
            NumProposers:Usize,
            UserIdToRole:Map,
            Quorum:Usize,
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
            ?UserIdToRoleFinal:Map,
            Quorum,
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
            NumBoardMembers,
            NumProposers,
            UserIdToRole,
            Quorum,
            usesExpanded)
        andBool notBool (UserId in_keys(UserIdToRole))
        andBool UserAddress in_keys(AddressToUserId)
        andBool AddressToUserId ==K (UserAddress |-> UserId:KItem _AddressToUserId:Map)
    ensures performEnsuresHandling(
            u(?NumUsersFinal),
            ?UserIdToAddressFinal,
            ?AddressToUserIdFinal,
            u(?NumBoardMembersFinal),
            u(?NumProposersFinal),
            ?UserIdToRoleFinal,
            Quorum,
            usesExpanded)
    [trusted]
endmodule

module PROOF-PERFORM-REMOVE-USER-9
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
            AddressToUserId:Map,
            NumBoardMembers:Usize,
            NumProposers:Usize,
            UserIdToRole:Map,
            Quorum:Usize,
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
            ?UserIdToRoleFinal:Map,
            Quorum,
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
            NumBoardMembers,
            NumProposers,
            UserIdToRole,
            Quorum)
        andBool notBool (UserId in_keys(UserIdToRole))
        andBool UserAddress in_keys(AddressToUserId)
        andBool AddressToUserId ==K (UserAddress |-> UserId:KItem _AddressToUserId:Map)
    ensures performEnsures(
            u(?NumUsersFinal),
            ?UserIdToAddressFinal,
            ?AddressToUserIdFinal,
            u(?NumBoardMembersFinal),
            u(?NumProposersFinal),
            ?UserIdToRoleFinal,
            Quorum)
endmodule
