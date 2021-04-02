require "../execution-proof.k"

module FUNCTIONS-EXECUTE-SYNTAX
  imports EXECUTION-PROOF-SYNTAX
endmodule

module FUNCTIONS-INSTRUMENTATION
  imports PROOF-INSTRUMENTATION

  rule  preCall
      ~> (.K => concretizeValue(Role))
      ~> call(canSign(Role:UserRole))
  [priority(20)]
endmodule

module FUNCTIONS-EXECUTE
  imports EXECUTION-PROOF

  imports FUNCTIONS-INSTRUMENTATION
endmodule
