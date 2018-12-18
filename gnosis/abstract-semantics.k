module ABSTRACT-SEMANTICS
  imports EVM
  imports EVM-SYMBOLIC

  // to avoid unnecessary case analyses
  rule <k> LT W0 W1 => bool2Word(W0  <Int W1) ~> #push ... </k> [trusted]
  rule <k> GT W0 W1 => bool2Word(W0  >Int W1) ~> #push ... </k> [trusted]
  rule <k> EQ W0 W1 => bool2Word(W0 ==Int W1) ~> #push ... </k> [trusted]
  rule <k> ISZERO W => bool2Word(W  ==Int 0 ) ~> #push ... </k> [trusted]

  // accumulate the gas cost and never run out of gas
  rule <k> G ~> #deductGas => . ... </k>
       <gas> #gas(STARTGAS, NONMEM, MEM) => #gas(STARTGAS, NONMEM +Int G, MEM) </gas>
       <previousGas> _ => #gas(STARTGAS, NONMEM, MEM) </previousGas>
    requires #getKLabelString(G) =/=String "#symCmem"
    [trusted, matching(#gas)]

  rule <k> #symCmem(MEM') ~> #deductGas => . ... </k>
       <gas> #gas(STARTGAS, NONMEM, MEM) => #gas(STARTGAS, NONMEM, MEM +Int MEM') </gas>
       <previousGas> _ => #gas(STARTGAS, NONMEM, MEM) </previousGas>
    [trusted, matching(#symCmem,#gas)]

  rule <k> MU':Int ~> #deductMemory => #symCmem(Cmem(SCHED, MU') -Int Cmem(SCHED, MU)) ~> #deductGas ... </k>
       <memoryUsed> MU => MU' </memoryUsed> <schedule> SCHED </schedule>
    [trusted]

   // abstract call gas
   // normal functiona call GCAP == GAVAIL
   // call chain == 1
   rule <k> Ccallgas(SCHED, ISEMPTY:Bool, GCAP, GAVAIL, VALUE)
          => #gas(Cgascap(SCHED, GCAP, GAVAIL, Cextra(SCHED, VALUE, ISEMPTY)), 0, 0) ... </k>
     requires VALUE ==Int 0
      andBool #getKLabelString(GCAP) ==String "#gas"
      andBool GCAP ==Int GAVAIL
     [trusted]

   rule <k> Ccallgas(SCHED, ISEMPTY:Bool, GCAP, GAVAIL, VALUE)
          => #gas(Cgascap(SCHED, GCAP, GAVAIL, Cextra(SCHED, VALUE, ISEMPTY)) +Int Gcallstipend < SCHED >, 0, 0) ... </k>
     requires VALUE =/=Int 0
      andBool #getKLabelString(GCAP) ==String "#gas"
      andBool GCAP ==Int GAVAIL
     [trusted]

   rule <k> #refund #gas(CALLEESTARTGAS, CALLEENONMEM, CALLEEMEM) => . ... </k>
        <gas> #gas(CALLERSTARTGAS, CALLERNONMEM, CALLERMEM) => #gas(CALLERSTARTGAS, CALLERNONMEM -Int CALLEESTARTGAS +Int CALLEENONMEM, CALLERMEM +Int CALLEEMEM)  </gas>
     requires #getKLabelString(CALLEESTARTGAS) ==String "Cgascap"
     [trusted, matching(#gas)]

endmodule
