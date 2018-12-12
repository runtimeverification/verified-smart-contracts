module ABSTRACT-SEMANTICS
  imports EVM
  imports EVM-SYMBOLIC

  // to avoid unnecessary case analyses
  rule <k> LT W0 W1 => bool2Word(W0  <Int W1) ~> #push ... </k> [trusted]
  rule <k> GT W0 W1 => bool2Word(W0  >Int W1) ~> #push ... </k> [trusted]
  rule <k> EQ W0 W1 => bool2Word(W0 ==Int W1) ~> #push ... </k> [trusted]
  rule <k> ISZERO W => bool2Word(W  ==Int 0 ) ~> #push ... </k> [trusted]

  rule <k> MU':Int ~> #deductMemory => #symCmem(Cmem(SCHED, MU') -Int Cmem(SCHED, MU)) ~> #deductGas ... </k>
       <memoryUsed> MU => MU' </memoryUsed> <schedule> SCHED </schedule>
    requires MU' <Int pow256 [trusted]

endmodule
