module PROOF-CONFIGURATION
  imports CONFIGURATION

  syntax ActionLogEntry ::= logPropose(usize) | logPerform(usize) | logDiscard(usize)
  syntax ActionLog ::= actionLog(List)  // list of ActionLogEntry

  syntax VoteLogEntry ::= logSign(usize) | logUnsign(usize)
  syntax VoteLog ::= actionLog(List)  // list of ActionLogEntry

  syntax UserLogEntry ::= logAddBoardMember(Address?)
                      |   logAddProposer(Address?)
                      |   logRemoveUser(Address?)
  syntax UserLog ::= List(UserLogEntry)

  syntax ProofState ::= proofState(ActionLog, VoteLog, UserLog)

  syntax KItem ::= log(Command)

  rule start(Command) => run(Command) ~> log(Command)  [priority(??25)]
  rule error ~> log(Command) => .K  [priority(25)]

  configuration <T>
    <proof-state> proofState(actionLog(.List), voteLog(.List), ...) </proof-state>
  </T>

endmodule