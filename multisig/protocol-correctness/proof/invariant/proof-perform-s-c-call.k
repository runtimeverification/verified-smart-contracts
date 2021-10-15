module TRUSTED-PERFORM-S-C-CALL
  imports INVARIANT-EXECUTION

  claim
      <T>
        performLhs(
            SCCall(
                _To:Address,
                _Amount:BigUint,
                _Function:BoxedBytes,
                _Arguments:ExpressionList) #as Action:Action,
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
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            NumBoardMembers,
            NumProposers,
            UserIdToRole,
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
    [trusted]
endmodule

module PROOF-PERFORM-S-C-CALL
  imports INVARIANT-EXECUTION

  claim
      <T>
        performLhs(
            SCCall(
                _To:Address,
                _Amount:BigUint,
                _Function:BoxedBytes,
                _Arguments:ExpressionList) #as Action:Action,
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
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            NumBoardMembers,
            NumProposers,
            UserIdToRole,
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
endmodule
