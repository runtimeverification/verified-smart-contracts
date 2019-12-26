requires "specs.k"

module SOLAR-ABSTRACT-SEMANTICS
  imports EVM-SPECS

  rule assumeEq V1:KResult V2:KResult => .
    ensures V1 ==K V2
    [trusted]

endmodule
