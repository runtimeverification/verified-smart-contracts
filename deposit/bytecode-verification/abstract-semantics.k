requires "verification.k"

module ABSTRACT-SEMANTICS
  imports VERIFICATION

  // to avoid unnecessary case analyses
  rule <k> LT W0 W1 => bool2Word(W0  <Int W1) ~> #push ... </k> [trusted]
  rule <k> GT W0 W1 => bool2Word(W0  >Int W1) ~> #push ... </k> [trusted]
  rule <k> EQ W0 W1 => bool2Word(W0 ==Int W1) ~> #push ... </k> [trusted]
  rule <k> ISZERO W => bool2Word(W  ==Int 0 ) ~> #push ... </k> [trusted]

  rule <k> SHA256 => #end EVMC_SUCCESS ... </k>
       <callData> DATA </callData>
       <output> _ => #buf(32, #sha256(DATA)) </output>
    requires notBool #isConcrete(DATA)
    [trusted]

  // gas abstraction

  // see also verification.k

rule <k> #assert(true) => . ... </k>
    [trusted]

//rule <k> G':Int ~> #deductGas => #assert(G >=Int G') ... </k>
rule <k> G':Int ~> #deductGas => . ... </k>
     <gas> G => G -Gas G' </gas>
     requires #getKLabelString(G) ==String "#symGas"
    [trusted]

//rule <k> MU':Int ~> #deductMemory => . ... </k>
//     <gas> #symGas(_, _, MU => MU') </gas>
//     <memoryUsed> MU => MU' </memoryUsed>
//    [trusted, matching(#symGas)]

rule <k> GCALL:Int ~> #allocateCallGas => . ... </k>
     <callGas> _ => #symGas(SCHED, GCALL, 0, 0, 0, #symMem(0)) </callGas>
     <schedule> SCHED </schedule>
    [trusted]

rule <k> #refund G:Int => . ... </k>
     <gas> GAVAIL => GAVAIL +Gas G </gas>
    [trusted]

/*
  rule <k> G':Int ~> #deductGas => . ... </k>
       <gas> G => G -Gas G' </gas>
       requires notBool (#isConcrete(G) andBool #isConcrete(G'))
      [trusted]

  rule <k> MU':Int ~> #deductMemory => . ... </k>
       <gas> #symGas(_, _, _, _, CMEM => Cmem(SCHED, MU')) </gas>
       <memoryUsed> MU => MU' </memoryUsed>
       <schedule> SCHED </schedule>
       requires CMEM ==Int Cmem(SCHED, MU)
      [trusted, matching(#symGas)]

  rule <k> GCALL:Int ~> #allocateCallGas => . ... </k>
       <callGas> _ => #symGas(GCALL, 0, 0, .List, 0) </callGas>
      [trusted]

  rule <k> #refund G:Int => . ... </k>
       <gas> GAVAIL => GAVAIL +Gas G </gas>
      [trusted]
*/

/* NOTE:
   These abstractions are over-approximation, except that out-of-gas exceptions are ignored.
   The out-of-gas exception is not harmful when it comes to safety properties, and it can be avoided by simply providing enough gas.
   The only problematic case is to call sub-functions with a specific amount of gas (instead of all available gas at that point).
   In this case, additional analyses need to be made to ensure that the specific amount of gas is sufficient, for liveness properties.
   See the lemmas over `+Gas` for the analysis, which checks the remaining (i.e., refuned) gas is positive when returning to the caller.

   In particular, the deposit contract involves precompiled contract calls (i.e., SHA256 and ID), where ID calls are fed a specific amount of gas.
   That is, the amount of gas provided to ID calls is "18 + floor(CALLDATASIZE / 10)",
   which is greater than the actual gas cost of ID calls, "15 + 3 * ceil(CALLDATASIZE / 32)".
   Indeed, the sufficiency is not trivial to show, but the former is simpler (thus more gas-efficient) to compute at runtime than the latter.
   Other calls are either private calls or calls with all available gas.
*/

endmodule
