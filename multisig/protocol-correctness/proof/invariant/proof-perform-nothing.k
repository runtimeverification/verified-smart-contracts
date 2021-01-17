module TRUSTED-PERFORM-NOTHING
  imports INVARIANT-EXECUTION

  claim
      <T>
        performLhs(
            Nothing #as Action:Action,
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
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            NumBoardMembers,
            NumProposers,
            UserIdToRole,
            Quorum,
            ActionState,
            ?_Variables:Map,
            Stack,
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
    ensures performEnsures(
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            NumBoardMembers,
            NumProposers,
            UserIdToRole,
            Quorum)
    [trusted]
endmodule

module PROOF-PERFORM-NOTHING
  imports INVARIANT-EXECUTION

  claim
      <T>
        performLhs(
            Nothing #as Action:Action,
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
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            NumBoardMembers,
            NumProposers,
            UserIdToRole,
            Quorum,
            ActionState,
            ?_Variables:Map,
            Stack,
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
    ensures performEnsures(
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            NumBoardMembers,
            NumProposers,
            UserIdToRole,
            Quorum)
endmodule
