module TRUSTED-PERFORM-ADD-PROPOSER-1
  imports INVARIANT-EXECUTION

  claim
      <T>
        performLhs(
            AddProposer(ProposerAddress:Address) #as Action:Action,
            K:K,
            NumUsers:Usize,
            UserIdToAddress:Map,
            (
                ProposerAddress |-> ProposerId:Usize
                _:Map
            ) #as AddressToUserId:Map,
            NumBoardMembers:Usize,
            NumProposers:Usize,
            (ProposerId |-> BoardMember _:Map) #as UserIdToRole:Map,
            Quorum:Usize,
            ActionState:ActionStateCell,
            Stack:List,
            CallerAddress:Address,
            _PerformedActions:List)
      </T>
      =>
      <T>
        performRhs(
            error,
            K,
            u(?_NumUsersFinal:Int),
            ?_UserIdToAddressFinal:Map,
            ?_AddressToUserIdFinal:Map,
            u(?_NumBoardMembersFinal:Int),
            u(?_NumProposersFinal:Int),
            ?_UserIdToRoleFinal:Map,
            Quorum,
            ActionState,
            ?_Variables:Map,
            Stack,
            CallerAddress,
            ?_PerformedActions:List)
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
        andBool Quorum ==K NumBoardMembers
    [trusted]

endmodule

module PROOF-PERFORM-ADD-PROPOSER-1
  imports INVARIANT-EXECUTION

  claim
      <T>
        performLhs(
            AddProposer(ProposerAddress:Address) #as Action:Action,
            K:K,
            NumUsers:Usize,
            UserIdToAddress:Map,
            (
                ProposerAddress |-> ProposerId:Usize
                _:Map
            ) #as AddressToUserId:Map,
            NumBoardMembers:Usize,
            NumProposers:Usize,
            (ProposerId |-> BoardMember _:Map) #as UserIdToRole:Map,
            Quorum:Usize,
            ActionState:ActionStateCell,
            .List, // TODO: Stack:List,
            CallerAddress:Address,
            _PerformedActions:List)
      </T>
      =>
      <T>
        performRhs(
            error,
            K,
            u(?_NumUsersFinal:Int),
            ?_UserIdToAddressFinal:Map,
            ?_AddressToUserIdFinal:Map,
            u(?_NumBoardMembersFinal:Int),
            u(?_NumProposersFinal:Int),
            ?_UserIdToRoleFinal:Map,
            Quorum,
            ActionState,
            ?_Variables:Map,
            .List, // TODO: Stack:List,
            CallerAddress,
            ?_PerformedActions:List)
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
        andBool Quorum ==K NumBoardMembers

endmodule
