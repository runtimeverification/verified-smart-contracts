module TRUSTED-PERFORM-CHANGE-QUORUM
  imports INVARIANT-EXECUTION

  claim
      <T>
        performLhs(
            ChangeQuorum(u(NewQuorum:Int)) #as Action:Action,
            K:K,
            NumUsers:Usize,
            UserIdToAddress:Map,
            AddressToUserId:Map,
            u(NumBoardMembers:Int),
            NumProposers:Usize,
            UserIdToRole:Map,
            OldQuorum:Usize,
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
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            u(NumBoardMembers),
            NumProposers,
            UserIdToRole,
            u(NewQuorum),
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
            u(NumBoardMembers),
            NumProposers,
            UserIdToRole,
            OldQuorum)
        andBool NewQuorum <=Int NumBoardMembers
    ensures performEnsures(
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            u(NumBoardMembers),
            NumProposers,
            UserIdToRole,
            u(NewQuorum))
    [trusted]

  claim
      <T>
        performLhs(
            ChangeQuorum(u(NewQuorum:Int)) #as Action:Action,
            K:K,
            NumUsers:Usize,
            UserIdToAddress:Map,
            AddressToUserId:Map,
            u(NumBoardMembers:Int),
            NumProposers:Usize,
            UserIdToRole:Map,
            OldQuorum:Usize,
            ActionState:ActionStateCell,
            Stack:Stack,
            CallerAddress:Address,
            _PerformedActions:List)
      </T>
      =>
      <T>
        performRhs(
            error,
            K,
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            u(NumBoardMembers),
            NumProposers,
            UserIdToRole,
            OldQuorum,
            ActionState,
            ?_Variables:Map,
            Stack:Stack,
            CallerAddress,
            ?_PerformedActions:List)
      </T>
    requires performRequires(
            Action,
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            u(NumBoardMembers),
            NumProposers,
            UserIdToRole,
            OldQuorum)
        andBool NewQuorum >Int NumBoardMembers
    ensures performEnsures(
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            u(NumBoardMembers),
            NumProposers,
            UserIdToRole,
            OldQuorum)
    [trusted]
endmodule

module PROOF-PERFORM-CHANGE-QUORUM
  imports INVARIANT-EXECUTION

  claim
      <T>
        performLhs(
            ChangeQuorum(u(NewQuorum:Int)) #as Action:Action,
            K:K,
            NumUsers:Usize,
            UserIdToAddress:Map,
            AddressToUserId:Map,
            u(NumBoardMembers:Int),
            NumProposers:Usize,
            UserIdToRole:Map,
            OldQuorum:Usize,
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
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            u(NumBoardMembers),
            NumProposers,
            UserIdToRole,
            u(NewQuorum),
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
            u(NumBoardMembers),
            NumProposers,
            UserIdToRole,
            OldQuorum)
        andBool NewQuorum <=Int NumBoardMembers
    ensures performEnsures(
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            u(NumBoardMembers),
            NumProposers,
            UserIdToRole,
            u(NewQuorum))

  claim
      <T>
        performLhs(
            ChangeQuorum(u(NewQuorum:Int)) #as Action:Action,
            K:K,
            NumUsers:Usize,
            UserIdToAddress:Map,
            AddressToUserId:Map,
            u(NumBoardMembers:Int),
            NumProposers:Usize,
            UserIdToRole:Map,
            OldQuorum:Usize,
            ActionState:ActionStateCell,
            Stack:Stack,
            CallerAddress:Address,
            _PerformedActions:List)
      </T>
      =>
      <T>
        performRhs(
            error,
            K,
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            u(NumBoardMembers),
            NumProposers,
            UserIdToRole,
            OldQuorum,
            ActionState,
            ?_Variables:Map,
            Stack:Stack,
            CallerAddress,
            ?_PerformedActions:List)
      </T>
    requires performRequires(
            Action,
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            u(NumBoardMembers),
            NumProposers,
            UserIdToRole,
            OldQuorum)
        andBool NewQuorum >Int NumBoardMembers
    ensures performEnsures(
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            u(NumBoardMembers),
            NumProposers,
            UserIdToRole,
            OldQuorum)
endmodule
