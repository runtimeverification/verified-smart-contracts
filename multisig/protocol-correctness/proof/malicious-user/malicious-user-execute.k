require "../execution-proof.k"
require "../invariant/invariant-execution.k"

module MALICIOUS-USER-EXECUTE-SYNTAX
  imports EXECUTION-PROOF-SYNTAX
endmodule

module MALICIOUS-USER-EXECUTE
  imports EXECUTION-PROOF
  imports INVARIANT-EXECUTION
endmodule