module TRUSTED-PERFORM-REMOVE-USER-3
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
                CallerAddress |-> _:Usize
                _AddressToUserId:Map
            ) #as AddressToUserId:Map,
            u(NumBoardMembers:Int),
            u(NumProposers:Int),
            (UserId |-> BoardMember _UserIdToRole:Map) #as UserIdToRole:Map,
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
            ?_NumUsersFinal,
            ?_UserIdToAddressFinal,
            ?_AddressToUserIdFinal,
            ?_NumBoardMembersFinal,
            ?_NumProposersFinal,
            ?_UserIdToRoleFinal,
            u(Quorum),
            ActionState,
            ?_Variables:Map,
            Stack:List,
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
        andBool notBool (UserAddress ==K CallerAddress)
        andBool notBool
            ((Quorum <=Int NumBoardMembers -Int 1)
            andBool (NumBoardMembers -Int 1 +Int NumProposers >Int 0)
            )
    [trusted]

endmodule

module PROOF-PERFORM-REMOVE-USER-3
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
                CallerAddress |-> _:Usize
                _AddressToUserId:Map
            ) #as AddressToUserId:Map,
            u(NumBoardMembers:Int),
            u(NumProposers:Int),
            (UserId |-> BoardMember _UserIdToRole:Map) #as UserIdToRole:Map,
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
            ?_NumUsersFinal,
            ?_UserIdToAddressFinal,
            ?_AddressToUserIdFinal,
            ?_NumBoardMembersFinal,
            ?_NumProposersFinal,
            ?_UserIdToRoleFinal,
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
        andBool notBool (UserAddress ==K CallerAddress)
        andBool notBool
            ((Quorum <=Int NumBoardMembers -Int 1)
            andBool (NumBoardMembers -Int 1 +Int NumProposers >Int 0)
            )

endmodule
