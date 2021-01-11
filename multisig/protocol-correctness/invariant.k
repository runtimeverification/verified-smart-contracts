module INVARIANT-SYNTAX
  imports PROOF-CONFIGURATION

  syntax Bool ::= invariant(MultisigState, ProofState)  [function]
endmodule

module INVARIANT
  imports PROOF-CONFIGURATION

  rule invariant(NoState) => true
  rule invariant(
          multisigState(
              U:Users,
              B:BoardState,
              actionState(ActionLastIndex:usize, Actions:Actions)),
          proofState(AL:ActionLog, VL:VoteLog, UL:UserLog))
      => true
        // non-empty board, board members >= quorum
        andBool canVote(U, B)
        andBool canPropose()
        // at execution time, an action was signed by at least 'quorum'
        // board members.
        // TODO: If a user votes, is removed, is re-added, should the vote count?
        // TODO: There is a weird thing about removing an action by removing the
        // last signature, which, practically, performs an action without votes.
        andBool allExecutedActionsWereAddedThenSigned()
        // TODO: Do I need these?
        andBool eachProposedActionGetsNewId()
        andBool eachNewUserGetsANewId()
        andBool stateReflectsActions()
        // consistency checks - TODO: Which of them do I need?
        andBool realVotesCorrespondToLog(RealVotes, AL, VL, UL)
        // cineva nu poate bloca
        // gazul creste liniar cu nr de board_memberi
        // ultima persoana sa nu poata pleca.

  syntax Bool ::= canVote(MasterLog)  [function]
  // Normally I should also check that the board users are valid users.
  // Also, I should not use the cached quorum, but the actual one.
  rule canVote(MasterLog)
      => true
        andBool computeQuorum(MasterLog) <=Int computeBoardSize(MasterLog)
        andBool 0 <Int computeBoardSize(MasterLog)

  syntax Bool ::= canPropose(MasterLog)  [function]
  rule canPropose(MasterLog)
      => false
        orBool 0 <Int computeProposerCount(MasterLog)
        orBool 0 <Int computeBoardSize(MasterLog)

  syntax Bool ::= allExecutedActionsWereAddedThenSigned(MasterLog)  [function]
  rule allExecutedActionsWereAddedThenSigned(.List) => true
  rule allExecutedActionsWereAddedThenSigned(MasterLog:List A:Action)
      => allExecutedActionsWereAddedThenSigned(MasterLog:List)
    requires notBool isExecution(A)
  rule allExecutedActionsWereAddedThenSigned(MasterLog:List Execute(ActionId))
      => true
        andBool allExecutedActionsWereAddedThenSigned(MasterLog:List)
        andBool computeQuorum(MasterLog) <=Int computeValidVotesCount(ActionId, MasterLog)

  syntax Int ::= computeBoardSize(MasterLog)  [function]
  rule computeBoardSize(MasterLog Execute(AddBoardMember(X)))
      => computeBoardSize(MasterLog)
    requires boardAlreadyContains(MasterLog, X)
  rule computeBoardSize(MasterLog Execute(AddBoardMember(X)))
      => computeBoardSize(MasterLog) + 1
    requires notBool boardAlreadyContains(MasterLog, X)
  rule computeBoardSize(MasterLog Execute(AddProposer(X)))
      => computeBoardSize(MasterLog) -Int 1
    requires boardAlreadyContains(MasterLog, X)
  rule computeBoardSize(MasterLog Execute(AddProposer(X)))
      => computeBoardSize(MasterLog)
    requires notBool boardAlreadyContains(MasterLog, X)
  rule computeBoardSize(MasterLog Execute(RemoveUser(X)))
      => computeBoardSize(MasterLog) -Int 1
    requires boardAlreadyContains(MasterLog, X)
  rule computeBoardSize(MasterLog Execute(RemoveUser(X)))
      => computeBoardSize(MasterLog)
    requires notBool boardAlreadyContains(MasterLog, X)
  rule computeQuorum(MasterLog A) => computeQuorum(MasterLog)  [owise]

  syntax Bool ::= boardAlreadyContains(MasterLog, UserId)  [function]
  rule boardAlreadyContains(MasterLog Execute(RemoveUser(UserId)), UserId) => false
  rule boardAlreadyContains(MasterLog Execute(AddProposer(UserId)), UserId) => false
  rule boardAlreadyContains(MasterLog Execute(AddBoardMember(UserId)), UserId) => true
  rule boardAlreadyContains(MasterLog _, UserId) => boardAlreadyContains(MasterLog, UserId)

  syntax Int ::= computeQuorum(MasterLog)  [function]
  rule computeQuorum(MasterLog Execute(ChangeQuorum(X))) => X
  rule computeQuorum(MasterLog A) => computeQuorum(MasterLog)
    requires notBool isChangeQuorum(MasterLog, A)

  syntax Int ::= computeProposerCount(MasterLog)  [function]
  rule computeProposerCount(MasterLog Execute(AddProposer(X)))
      => computeProposerCount(MasterLog)
    requires isAlreadyProposer(MasterLog, X)
  rule computeProposerCount(MasterLog Execute(AddProposer(X)))
      => computeProposerCount(MasterLog) + 1
    requires notBool isAlreadyProposer(MasterLog, X)
  rule computeProposerCount(MasterLog Execute(RemoveUser(X)))
      => computeProposerCount(MasterLog) - 1
    requires isAlreadyProposer(MasterLog, X)
  rule computeProposerCount(MasterLog Execute(RemoveUser(X)))
      => computeProposerCount(MasterLog)
    requires notBool isAlreadyProposer(MasterLog, X)


  syntax Bool ::= isAlreadyProposer(MasterLog, UserId)  [function]
  rule isAlreadyProposer(MasterLog Execute(RemoveUser(UserId)), UserId) => false
  rule isAlreadyProposer(MasterLog Execute(AddProposer(UserId)), UserId) => true
  rule isAlreadyProposer(MasterLog Execute(AddBoardMember(UserId)), UserId) => false
  rule isAlreadyProposer(MasterLog _, UserId) => isAlreadyProposer(MasterLog, UserId)

  // What I really want is card({x | x is a board member & last_vote_action(x, A) = "vote(A)"})
  syntax Int ::= computeValidVotesCount(ActionId, MasterLog)  [function]
  rule computeValidVotesCount(Action, MasterLog Execute(RemoveUser(X)))
      => computeValidVotesCount(Action, MasterLog) - 1
    requires userHasSigned(X, Action, MasterLog) andBool actionExists(Action, MasterLog)
  rule computeValidVotesCount(Action, MasterLog Execute(RemoveUser(X)))
      => computeValidVotesCount(Action, MasterLog)
    requires notBool userHasSigned(X, Action, MasterLog) andBool actionExists(Action, MasterLog)
  rule computeValidVotesCount(Action, MasterLog Execute(AddProposer(X)))
      => computeValidVotesCount(Action, MasterLog) - 1
    requires userHasSigned(X, Action, MasterLog)
  rule computeValidVotesCount(Action, MasterLog Execute(AddProposer(X)))
      => computeValidVotesCount(Action, MasterLog)
    requires notBool userHasSigned(X, Action, MasterLog)
  rule computeValidVotesCount(Action, MasterLog Execute(AddBoardMember(X)))
      => computeValidVotesCount(Action, MasterLog) + 1
    requires userHasSignature(X, Action, MasterLog)
  rule computeValidVotesCount(Action, MasterLog Execute(AddBoardMember(X)))
      => computeValidVotesCount(Action, MasterLog)
    requires notBool userHasSignature(X, Action, MasterLog)
  rule computeValidVotesCount(Action, MasterLog Execute(unsign(X, Action)))
      => computeValidVotesCount(Action, MasterLog) - 1
    requires userHasSigned(X, Action, MasterLog)
  rule computeValidVotesCount(Action, MasterLog Execute(unsign(X, Action)))
      => computeValidVotesCount(Action, MasterLog)
    requires notBool userHasSigned(X, Action, MasterLog)
  rule computeValidVotesCount(Action, MasterLog Execute(sign(X, Action)))
      => computeValidVotesCount(Action, MasterLog) + 1
    requires boardAlreadyContains(X, MasterLog)
      andBool notBool userHasSigned(X, Action, MasterLog)
  rule computeValidVotesCount(Action, MasterLog Execute(sign(X, Action)))
      => computeValidVotesCount(Action, MasterLog)
    requires boardAlreadyContains(X, MasterLog)
      andBool userHasSigned(X, Action, MasterLog)
  rule computeValidVotesCount(Action, MasterLog Execute(sign(X, Action)))
      => stuck
    requires notBool boardAlreadyContains(X, MasterLog)
  rule computeValidVotesCount(Action, MasterLog _) => computeValidVotesCount(Action, MasterLog)

  syntax Bool ::= userHasSigned(UserId, ActionId, MasterLog)
  rule userHasSigned(UserId, ActionId, MasterLog)
      =>  boardAlreadyContains(UserId, MasterLog)  // TODO: Use "userCanVote"
          andBool userHasSignature(UserId, ActionId, MasterLog)

  syntax Bool ::= userHasSignature(UserId, ActionId, MasterLog)
  rule userHasSignature(UserId, ActionId, MasterLog Execute(unsign(UserId, ActionId)))
      => false
  rule userHasSignature(UserId, ActionId, MasterLog Execute(sign(UserId, ActionId)))
      => true
  rule userHasSignature(UserId, ActionId, MasterLog _)
      => userHasSignature(UserId, ActionId, MasterLog)  [owise]

  /*
  syntax Bool ::= eachProposedActionGetsNewId(MasterLog)  [owise]
  rule eachProposedActionGetsNewId(MasterLog Execute(AddAction(X)))
  */

  syntax Bool ::= stateReflectsActions(State, MasterLog)  [function]
  rule stateReflectsActions() => true
        // consistency checks - TODO: Which of them do I need?
        andBool userRoleReflectsActions()
        andBool quorumReflectsActions()
        // both the board and the board size
        andBool boardReflectsActions()
        andBool proposerCountReflectsActions()
        andBool usersReflectActions()
        andBool votesAreValid()

        andBool lastIndexIsMaxUsed(ActionLastIndex, AL)
        andBool actionsCorrespondToLog(Actions, AL)
        andBool votesCorrespondToLog(Actions, VL)
        andBool usersCorrespondToLog(Users, UL)
endmodule
