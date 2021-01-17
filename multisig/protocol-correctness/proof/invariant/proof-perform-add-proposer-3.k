module TRUSTED-PERFORM-ADD-PROPOSER-3
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
                CallerAddress |-> _:Usize
                _:Map
            ) #as AddressToUserId:Map,
            NumBoardMembers:Usize,
            NumProposers:Usize,
            (ProposerId |-> BoardMember _:Map) #as UserIdToRole:Map,
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
        andBool notBool (ProposerAddress ==K CallerAddress)
        andBool notBool (Quorum ==K NumBoardMembers)
    ensures performEnsures(
            u(?NumUsersFinal),
            ?UserIdToAddressFinal,
            ?AddressToUserIdFinal,
            u(?NumBoardMembersFinal),
            u(?NumProposersFinal),
            ?UserIdToRoleFinal,
            Quorum)
    [trusted]

endmodule

module PROOF-PERFORM-ADD-PROPOSER-3
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
                CallerAddress |-> _:Usize
                _:Map
            ) #as AddressToUserId:Map,
            NumBoardMembers:Usize,
            NumProposers:Usize,
            (ProposerId |-> BoardMember _:Map) #as UserIdToRole:Map,
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
        andBool notBool (ProposerAddress ==K CallerAddress)
        andBool notBool (Quorum ==K NumBoardMembers)
    ensures performEnsures(
            u(?NumUsersFinal),
            ?UserIdToAddressFinal,
            ?AddressToUserIdFinal,
            u(?NumBoardMembersFinal),
            u(?NumProposersFinal),
            ?UserIdToRoleFinal,
            Quorum)

endmodule
