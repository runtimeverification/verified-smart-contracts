requires "evm-symbolic.k"

module ABSTRACT-SEMANTICS-SEGMENTED-GAS
  imports EVM
  imports EVM-SYMBOLIC

  // to avoid unnecessary case analyses
  rule <k> LT W0 W1 => bool2Word(W0  <Int W1) ~> #push ... </k> [trusted]
  rule <k> GT W0 W1 => bool2Word(W0  >Int W1) ~> #push ... </k> [trusted]
  rule <k> EQ W0 W1 => bool2Word(W0 ==Int W1) ~> #push ... </k> [trusted]
  rule <k> ISZERO W => bool2Word(W  ==Int 0 ) ~> #push ... </k> [trusted]


/*
  // tmp gas model

  rule <k> G ~> #deductGas => . ... </k>
       <gas> #gas(INITGAS, NONMEM, MEM) => #gas(INITGAS, NONMEM +Int 1, MEM) </gas>
       <previousGas> _ => #gas(INITGAS, NONMEM, MEM) </previousGas>
    requires #notKLabel(G, "#symCmem")
    [trusted, matching(#gas)]

  rule <k> #symCmem(MEM') ~> #deductGas => . ... </k>
    [trusted, matching(#symCmem,#gas)]

  rule <k> G:KItem ~> #deductGas ... </k>
       <gas> INITGAS => #gas(INITGAS, 0, 0) </gas>
    requires #notKLabel(INITGAS, "#gas")
    [trusted]

  rule <k> MU':Int ~> #deductMemory => #symCmem(0) ~> #deductGas ... </k>
    [trusted]

  rule <k> #refund G:Int => . ... </k>
    [trusted]
*/

/* TODO: more simplification needed, e.g., using interval abstraction
  // ########################
  // Segmented gas representatioon - #gas construct
  // ########################

  // accumulate the gas cost and never run out of gas
  rule <k> G ~> #deductGas => . ... </k>
       <gas> #gas(INITGAS, NONMEM, MEM) => #gas(INITGAS, NONMEM +Int G, MEM) </gas>
       <previousGas> _ => #gas(INITGAS, NONMEM, MEM) </previousGas>
    requires #notKLabel(G, "#symCmem")
    [trusted, matching(#gas)]

  rule <k> #symCmem(MEM') ~> #deductGas => . ... </k>
       <gas> #gas(INITGAS, NONMEM, MEM) => #gas(INITGAS, NONMEM, MEM +Int MEM') </gas>
       <previousGas> _ => #gas(INITGAS, NONMEM, MEM) </previousGas>
    [trusted, matching(#symCmem,#gas)]

  //If G is not explicitly typed, it will be typed as G:K. This leads to intermittent SPEC ERROR below,
  // in multi-threaded environment, on appliation of this rule.
  // `java.lang.AssertionError: disjunctions are not supported by SMT translation`
  // Issue cause: <k> contains 2 terms `#deductGas`, so for G:K, the rule can match in 2 ways. Observed with in hkg-erc20.
  rule <k> G:KItem ~> #deductGas ... </k>
       <gas> INITGAS => #gas(INITGAS, 0, 0) </gas>
    requires #notKLabel(INITGAS, "#gas")
    [trusted]

  rule <k> MU':Int ~> #deductMemory => #symCmem(Cmem(SCHED, MU') -Int Cmem(SCHED, MU)) ~> #deductGas ... </k>
       <memoryUsed> MU => MU' </memoryUsed> <schedule> SCHED </schedule>
    [trusted]
*/

endmodule
