require "../functions/functions-execute.k"

require "../functions/trusted-change-user-role-New.k"
require "../functions/trusted-change-user-role-None.k"
require "../functions/trusted-change-user-role-BoardMember.k"
require "../functions/trusted-change-user-role-Proposer.k"

module TRUSTED-PERFORM-REMOVE-USER-10
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
            CallerAddress:Address)
      </T>
      =>
      <T>
        performRhs(
            evaluate(void),
            K,
            NumUsers:Usize,
            UserIdToAddress:Map,
            AddressToUserId:Map,
            NumBoardMembers:Usize,
            NumProposers:Usize,
            UserIdToRole:Map,
            Quorum,
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
            NumBoardMembers,
            NumProposers,
            UserIdToRole,
            Quorum,
            usesExpanded)
        andBool notBool (UserAddress in_keys(AddressToUserId))
    ensures performEnsuresHandling(
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            NumBoardMembers,
            NumProposers,
            UserIdToRole,
            Quorum,
            expanded)
    [trusted]
endmodule

module PROOF-PERFORM-REMOVE-USER-10
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
            CallerAddress:Address)
      </T>
      =>
      <T>
        performRhs(
            evaluate(void),
            K,
            ?NumUsers:Usize,
            ?UserIdToAddress:Map,
            ?AddressToUserId:Map,
            NumBoardMembers:Usize,
            NumProposers:Usize,
            UserIdToRole:Map,
            Quorum,
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
            NumBoardMembers,
            NumProposers,
            UserIdToRole,
            Quorum)
        andBool notBool (UserAddress in_keys(AddressToUserId))
    ensures performEnsures(
            ?NumUsers,
            ?UserIdToAddress,
            ?AddressToUserId,
            NumBoardMembers,
            NumProposers,
            UserIdToRole,
            Quorum)
endmodule
