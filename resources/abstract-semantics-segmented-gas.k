requires "evm-symbolic.k"

module ABSTRACT-SEMANTICS-SEGMENTED-GAS
  imports EVM
  imports EVM-SYMBOLIC

  // to avoid unnecessary case analyses
  rule <k> LT W0 W1 => bool2Word(W0  <Int W1) ~> #push ... </k> [trusted]
  rule <k> GT W0 W1 => bool2Word(W0  >Int W1) ~> #push ... </k> [trusted]
  rule <k> EQ W0 W1 => bool2Word(W0 ==Int W1) ~> #push ... </k> [trusted]
  rule <k> ISZERO W => bool2Word(W  ==Int 0 ) ~> #push ... </k> [trusted]

  // ########################
  // Segmented gas representatioon - #gas construct
  // ########################

  // accumulate the gas cost and never run out of gas
  rule <k> G ~> #deductGas => . ... </k>
       <gas> #gas(INITGAS, NONMEM, MEM) => #gas(INITGAS, NONMEM +Int G, MEM) </gas>
       <callGas> _ => #gas(INITGAS, NONMEM, MEM) </callGas>
    requires #notKLabel(G, "#symCmem")
    [trusted, matching(#gas)]

  rule <k> #symCmem(MEM') ~> #deductGas => . ... </k>
       <gas> #gas(INITGAS, NONMEM, MEM) => #gas(INITGAS, NONMEM, MEM +Int MEM') </gas>
       <callGas> _ => #gas(INITGAS, NONMEM, MEM) </callGas>
    [trusted, matching(#symCmem,#gas)]

  rule <k> G ~> #deductGas ... </k>
       <gas> INITGAS => #gas(INITGAS, 0, 0) </gas>
    requires #notKLabel(INITGAS, "#gas")
    [trusted]

  rule <k> MU':Int ~> #deductMemory => #symCmem(Cmem(SCHED, MU') -Int Cmem(SCHED, MU)) ~> #deductGas ... </k>
       <memoryUsed> MU => MU' </memoryUsed> <schedule> SCHED </schedule>
    [trusted]
endmodule
