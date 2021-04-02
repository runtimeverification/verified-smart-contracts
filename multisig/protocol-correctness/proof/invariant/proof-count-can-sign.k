module TRUSTED-COUNT-CAN-SIGN
  imports COUNT-CAN-SIGN-PARTS

  claim <T> countCanSignLhs(
                SignerIds:ExpressionList,
                K:K,
                Users:UsersCell,
                NumBoardMembers:Usize,
                NumProposers:Usize,
                UserIdToRole:Map,
                Quorum:Usize,
                ActionState:ActionStateCell,
                Variables:Map,
                Stack:List,
                ExternalCallEnv:ExternalCallEnvCell,
                PerformedActions:List)
        </T>
      => <T> countCanSignRhs(
                u(countCanSignFunction(SignerIds, opaque(UserIdToRole))),
                K,
                Users,
                NumBoardMembers,
                NumProposers,
                UserIdToRole,
                Quorum,
                ActionState,
                ?Variables:Map,
                Stack,
                ExternalCallEnv,
                PerformedActions:List)
        </T>
    requires
        countCanSignRequires(
            SignerIds,
            Users,
            NumBoardMembers,
            NumProposers,
            UserIdToRole,
            Quorum,
            ActionState,
            Variables,
            Stack,
            ExternalCallEnv)
    ensures
        countCanSignEnsures(
            u(countCanSignFunction(SignerIds, opaque(UserIdToRole))),
            Users,
            NumBoardMembers,
            NumProposers,
            UserIdToRole,
            Quorum,
            ActionState,
            ?Variables,
            Stack,
            ExternalCallEnv)
    [trusted]

endmodule

module PROOF-COUNT-CAN-SIGN
  imports INVARIANT-EXECUTION

  claim <T> countCanSignLhs(
                SignerIds:ExpressionList,
                K:K,
                Users:UsersCell,
                NumBoardMembers:Usize,
                NumProposers:Usize,
                UserIdToRole:Map,
                Quorum:Usize,
                ActionState:ActionStateCell,
                Variables:Map,
                Stack:List,
                ExternalCallEnv:ExternalCallEnvCell)
        </T>
      => <T> countCanSignRhs(
                ?Count:Usize,
                K,
                Users,
                NumBoardMembers,
                NumProposers,
                UserIdToRole,
                Quorum,
                ActionState,
                ?Variables:Map,
                Stack,
                ExternalCallEnv)
        </T>
    requires
        countCanSignRequires(
            SignerIds,
            Users,
            NumBoardMembers,
            NumProposers,
            UserIdToRole,
            Quorum,
            ActionState,
            Variables,
            Stack,
            ExternalCallEnv)
    ensures
        countCanSignEnsures(
            ?Count,
            Users,
            NumBoardMembers,
            NumProposers,
            UserIdToRole,
            Quorum,
            ActionState,
            ?Variables,
            Stack,
            ExternalCallEnv)

endmodule
