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
                CallerAddress |-> _:Usize
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
    [trusted]

endmodule

module PROOF-PERFORM-REMOVE-USER-1
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
        andBool notBool (UserAddress ==K CallerAddress)
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
