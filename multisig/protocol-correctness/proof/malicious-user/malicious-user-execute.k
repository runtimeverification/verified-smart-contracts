require "../execution-proof.k"
require "../invariant/invariant-execution.k"

module MALICIOUS-USER-EXECUTE-SYNTAX
  imports EXECUTION-PROOF-SYNTAX
endmodule

module MALICIOUS-USER-HELPERS

  syntax KItem ::= runExternalCallsFromUser(Address, steps:Int)

  rule runExternalCallsFromUser(A:Address, Steps:Int) => .K
    requires Steps <=Int 0
  rule runExternalCallsFromUser(A:Address, Steps:Int)
      => runExternalCallFromUser(A) ~> runExternalCallsFromUser(A, Steps -Int 1)
    requires Steps >Int 0

  syntax KItem ::= runExternalCallFromUser(Address)

  rule runExternalCallFromUser(A:Address) => runExternalCall(from A run proposeAddBoardMember(U:Usize))
  rule runExternalCallFromUser(A:Address) => runExternalCall(from A run proposeAddProposer(U:Usize))
  rule runExternalCallFromUser(A:Address) => runExternalCall(from A run proposeRemoveUser(U:Usize))
  rule runExternalCallFromUser(A:Address) => runExternalCall(from A run proposeChangeQuorum(Quorum:Usize))
  rule runExternalCallFromUser(A:Address) => runExternalCall(from A run proposeSendEgld(To:Address, Amount:BigUint, Data:BoxedBytes))
  rule runExternalCallFromUser(A:Address) => runExternalCall(from A run proposeSCDeploy(
          Amount:BigUint,
          Code:BoxedBytes,
          Upgradeable:Bool,
          Payable:Bool,
          Readable:Bool,
          Args:ExpressionList))
  rule runExternalCallFromUser(A:Address) => runExternalCall(from A run proposeSCCall(
          To:Address,
          Amount:BigUint,
          Function:BoxedBytes,
          Args:ExpressionList))
  rule runExternalCallFromUser(A:Address) => runExternalCall(from A run sign(A:ActionId))
  rule runExternalCallFromUser(A:Address) => runExternalCall(from A run unsign(A:ActionId))
  rule runExternalCallFromUser(A:Address) => runExternalCall(from A run performActionEndpoint(A:ActionId))
  rule runExternalCallFromUser(A:Address) => runExternalCall(from A run discardAction(A:ActionId))
endmodule

module MALICIOUS-USER-EXECUTE
  imports EXECUTION-PROOF
  imports INVARIANT-EXECUTION
endmodule