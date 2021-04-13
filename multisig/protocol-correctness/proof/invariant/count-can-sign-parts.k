module COUNT-CAN-SIGN-PARTS
  imports EXECUTION-PROOF-HELPERS
  imports INVARIANT-HELPERS
  imports PSEUDOCODE

  syntax TTCell ::= countCanSignLhs(
            signerIds:ExpressionList,
            K,
            UsersCell,
            numBoardMembers:Usize,
            numProposers:Usize,
            userIdToRole:Map,
            quorum:Usize,
            ActionStateCell,
            variables:Map,
            stack:Stack,
            ExternalCallEnvCell,
            performedActions:List)
      [function, functional]

  rule Stack(
            SignerIds:ExpressionList,
            K:K,
            Users:UsersCell,
            NumBoardMembers:Usize,
            NumProposers:Usize,
            UserIdToRole:Map,
            Quorum:Usize,
            ActionState:ActionStateCell,
            Variables:Map,
            Stack:Stack,
            ExternalCallEnv:ExternalCallEnvCell,
            PerformedActions:List)
      => <TT>
          <k>
            call(countCanSign(SignerIds))
            ~> K
          </k>
          <state>
            <multisig-state>
              Users:UsersCell
              <board-state>
                <num-board-members>NumBoardMembers</num-board-members>
                <num-proposers>NumProposers</num-proposers>
                <user-roles>UserIdToRole</user-roles>
                <quorum>Quorum</quorum>
              </board-state>
              ActionState
            </multisig-state>
            <pseudocode-state>
              <variables>Variables</variables>
              <stack>Stack</stack>
            </pseudocode-state>
            ExternalCallEnv
            <log>
              <performed-actions>PerformedActions</performed-actions>
            </log>
          </state>
        </TT>

  syntax TTCell ::= countCanSignRhs(
            count:Usize,
            K,
            UsersCell,
            numBoardMembers:Usize,
            numProposers:Usize,
            userIdToRole:Map,
            quorum:Usize,
            ActionStateCell,
            variables:Map,
            stack:Stack,
            ExternalCallEnvCell,
            performedActions:List)
      [function, functional]

  rule countCanSignRhs(
            Count:Usize,
            K:K,
            Users:UsersCell,
            NumBoardMembers:Usize,
            NumProposers:Usize,
            UserIdToRole:Map,
            Quorum:Usize,
            ActionState:ActionStateCell,
            Variables:Map,
            Stack:Stack,
            ExternalCallEnv:ExternalCallEnvCell,
            PerformedActions:List)
      => <TT>
          <k>
            evaluate(Count) ~> K
          </k>
          <state>
            <multisig-state>
              Users
              <board-state>
                <num-board-members>NumBoardMembers</num-board-members>
                <num-proposers>NumProposers</num-proposers>
                <user-roles>UserIdToRole</user-roles>
                <quorum>Quorum</quorum>
              </board-state>
              ActionState
            </multisig-state>
            <pseudocode-state>
              <variables>Variables </variables>
              <stack>Stack</stack>
            </pseudocode-state>
            ExternalCallEnv
            <log>
              <performed-actions>PerformedActions</performed-actions>
            </log>
          </state>
        </TT>

  syntax Bool ::= countCanSignRequires(
            signerIds:ExpressionList,
            UsersCell,
            numBoardMembers:KItem,
            numProposers:Usize,
            userIdToRole:Map,
            quorum:KItem,
            ActionStateCell,
            variables:Map,
            stack:Stack,
            ExternalCallEnvCell)
      [function, functional]

  rule countCanSignRequires(
            SignerIds:ExpressionList,
            _Users:UsersCell,
            _NumBoardMembers:KItem,
            _NumProposers:Usize,
            UserIdToRole:Map,
            _Quorum:KItem,
            _ActionState:ActionStateCell,
            Variables:Map,
            _Stack:Stack,
            _ExternalCallEnv:ExternalCallEnvCell)
      =>
        isKResult(SignerIds)
        andBool listElementsAreUsize(SignerIds)
        andBool (notBool result in_keys(Variables))
        andBool (notBool user_role in_keys(Variables))
        andBool userIdToRoleInvariant(UserIdToRole)

  syntax Bool ::= countCanSignEnsures(
            count:Usize,
            UsersCell,
            numBoardMembers:KItem,
            numProposers:Usize,
            userIdToRole:Map,
            quorum:KItem,
            ActionStateCell,
            variables:Map,
            Stack:Stack,
            ExternalCallEnvCell)
      [function, functional]

  rule countCanSignEnsures(
            _Count:Usize,
            _Users:UsersCell,
            _NumBoardMembers:KItem,
            _NumProposers:Usize,
            _UserIdToRole:Map,
            _Quorum:KItem,
            _ActionState:ActionStateCell,
            _Variables:Map,
            _Stack:Stack,
            _ExternalCallEnv:ExternalCallEnvCell)
      => true

endmodule
