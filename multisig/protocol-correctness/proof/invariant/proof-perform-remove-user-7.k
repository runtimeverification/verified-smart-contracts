module TRUSTED-PERFORM-REMOVE-USER-7
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
            (UserId |-> UserRole:KItem _UserIdToRole:Map) #as UserIdToRole:Map,
            u(Quorum:Int),
            ActionState:ActionStateCell,
            Stack:List,
            CallerAddress:Address)
      </T>
      =>
      <T>
        performRhs(
            error,
            K,
            ?_NumUsers,
            ?_UserIdToAddress,
            ?_AddressToUserId,
            ?_NumBoardMembers,
            ?_NumProposers,
            ?_UserIdToRole,
            u(Quorum:Int),
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
        andBool notBool (UserRole ==K BoardMember)
        andBool notBool (
            Quorum <=Int NumBoardMembers
            andBool (NumBoardMembers +Int (NumProposers -Int 1) >Int 0))
    [trusted]
endmodule

module PROOF-PERFORM-REMOVE-USER-7
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
            (UserId |-> UserRole:KItem _UserIdToRole:Map) #as UserIdToRole:Map,
            u(Quorum:Int),
            ActionState:ActionStateCell,
            .List, // TODO: Stack:List,
            CallerAddress:Address)
      </T>
      =>
      <T>
        performRhs(
            error,
            K,
            ?_NumUsers,
            ?_UserIdToAddress,
            ?_AddressToUserId,
            ?_NumBoardMembers,
            ?_NumProposers,
            ?_UserIdToRole,
            u(Quorum:Int),
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
        andBool notBool (UserRole ==K BoardMember)
        andBool notBool (
            Quorum <=Int NumBoardMembers
            andBool (NumBoardMembers +Int (NumProposers -Int 1) >Int 0))
endmodule
