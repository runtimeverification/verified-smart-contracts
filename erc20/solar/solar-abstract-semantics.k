requires "specs.k"

module SOLAR-ABSTRACT-SEMANTICS
  imports EVM-SPECS

  rule #assume R:Bool => .
    ensures R
    [trusted]

endmodule
