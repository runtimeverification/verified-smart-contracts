module ABSTRACT-SEMANTICS
  imports EVM
  imports EVM-SYMBOLIC

  // to avoid unnecessary case analyses
  rule <k> LT W0 W1 => bool2Word(W0  <Int W1) ~> #push ... </k> [trusted]
  rule <k> GT W0 W1 => bool2Word(W0  >Int W1) ~> #push ... </k> [trusted]
  rule <k> EQ W0 W1 => bool2Word(W0 ==Int W1) ~> #push ... </k> [trusted]
  rule <k> ISZERO W => bool2Word(W  ==Int 0 ) ~> #push ... </k> [trusted]


  // ########################
  // Gas
  // ########################

  // accumulate the gas cost and never run out of gas
  rule <k> G ~> #deductGas => . ... </k>
       <gas> #gas(INITGAS, NONMEM, MEM) => #gas(INITGAS, NONMEM +Int G, MEM) </gas>
       <previousGas> _ => #gas(INITGAS, NONMEM, MEM) </previousGas>
    requires #getKLabelString(G) =/=String "#symCmem"
    [trusted, matching(#gas)]

  rule <k> #symCmem(MEM') ~> #deductGas => . ... </k>
       <gas> #gas(INITGAS, NONMEM, MEM) => #gas(INITGAS, NONMEM, MEM +Int MEM') </gas>
       <previousGas> _ => #gas(INITGAS, NONMEM, MEM) </previousGas>
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
      andBool #getKLabelString(GAVAIL) ==String "#gas"
      andBool GCAP ==Int GAVAIL
     [trusted]

   rule <k> Ccallgas(SCHED, ISEMPTY:Bool, GCAP, GAVAIL, VALUE)
          => #gas(Cgascap(SCHED, GCAP, GAVAIL, Cextra(SCHED, VALUE, ISEMPTY)) +Int Gcallstipend < SCHED >, 0, 0) ... </k>
     requires 0 <Int VALUE
      andBool #getKLabelString(GAVAIL) ==String "#gas"
      andBool GCAP ==Int GAVAIL
     [trusted]

   rule <k> #refund #gas(CALLEEINITGAS, CALLEENONMEM, CALLEEMEM) => . ... </k>
        <gas> #gas(CALLERINITGAS, CALLERNONMEM, CALLERMEM) => #gas(CALLERINITGAS, CALLERNONMEM -Int CALLEEINITGAS +Int CALLEENONMEM, CALLERMEM +Int CALLEEMEM)  </gas>
     requires #getKLabelString(CALLEEINITGAS) ==String "Cgascap"
     [trusted, matching(#gas)]


  // ########################
  // Call
  // ########################

  // send() succeed and ACCTFROM =/=K ACCTTO
  rule <k> #exec[CALL] => . ... </k>
       <schedule> SCHED </schedule>
       <id> ACCTFROM </id>
       <wordStack> 0 : ACCTTO : VALUE : ARGSTART : 0 : RETSTART : 0 : WS => 1 : WS </wordStack>
       <gas> #gas(INITGAS, NONMEM, MEM) => #gas(INITGAS, NONMEM +Int #sendGas(SCHED, ACCTTO, VALUE, true), MEM) </gas>
       <previousGas> _ => #gas(INITGAS, NONMEM, MEM) </previousGas>
       <account>
         <acctID> ACCTFROM </acctID>
         <balance> ORIGFROM => ORIGFROM -Int VALUE </balance>
         ...
       </account>
       <account>
         <acctID> ACCTTO </acctID>
         <balance> ORIGTO => ORIGTO +Int VALUE </balance>
         ...
       </account>
    requires #sendSuccess(ACCTTO)
     andBool ACCTFROM =/=K ACCTTO
     andBool VALUE <=Int ORIGFROM
     andBool ORIGTO +Int VALUE <Int pow256
    [trusted, matching(#gas)]

  // TODO: send() succeed and ACCTFROM ==K ACCTTO

  // send() fail
  rule <k> #exec[CALL] => . ... </k>
       <schedule> SCHED </schedule>
       <wordStack> 0 : ACCTTO : VALUE : ARGSTART : 0 : RETSTART : 0 : WS => 0 : WS </wordStack>
       <gas> #gas(INITGAS, NONMEM, MEM) => #gas(INITGAS, NONMEM +Int #sendGas(SCHED, ACCTTO, VALUE, false), MEM) </gas>
       <previousGas> _ => #gas(INITGAS, NONMEM, MEM) </previousGas>
    requires #sendFailure(ACCTTO)
    [trusted, matching(#gas)]


endmodule
