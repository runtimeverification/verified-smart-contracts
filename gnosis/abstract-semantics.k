requires "evm-symbolic.k"
requires "ecrec-symbolic.k"

module ABSTRACT-SEMANTICS
  imports EVM
  imports EVM-SYMBOLIC
  imports ECREC-SYMBOLIC

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
    requires #notKLabel(G, "#symCmem")
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
          => #gas(Cgascap(SCHED, GCAP, GAVAIL, Cextra(SCHED, ISEMPTY, VALUE)), 0, 0) ... </k>
     requires VALUE ==Int 0
      andBool #getKLabelString(GAVAIL) ==String "#gas"
      andBool GCAP ==Int GAVAIL
     [trusted]

   rule <k> Ccallgas(SCHED, ISEMPTY:Bool, GCAP, GAVAIL, VALUE)
          => #gas(Cgascap(SCHED, GCAP, GAVAIL, Cextra(SCHED, ISEMPTY, VALUE)) +Int Gcallstipend < SCHED >, 0, 0) ... </k>
     requires 0 <Int VALUE
      andBool #getKLabelString(GAVAIL) ==String "#gas"
      andBool GCAP ==Int GAVAIL
     [trusted]

  // ########################
  // Call
  // ########################

  // We only consider the case where the function call doesn't return any value (i.e, RETWIDTH == 0)
  // call() succeed and ACCTFROM =/=K ACCTTO
  rule <k> #exec[CALL] => . ... </k>
       <output> _ => _ </output>
       <schedule> SCHED </schedule>
       <id> ACCTFROM </id>
       <wordStack> GASCAP : ACCTTO : VALUE : ARGSTART : ARGWIDTH : RETSTART : 0 : WS => 1 : WS </wordStack>
       <pc> PCC </pc>
       <gas> #gas(INITGAS, NONMEM, MEM) => #gas(INITGAS, NONMEM +Int #callGas(SCHED, GASCAP, ACCTTO, VALUE, true), MEM) </gas>
       <previousGas> _ => #gas(INITGAS, NONMEM, MEM) </previousGas>
       <callDepth> CD </callDepth>
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
    requires #range(0 <= CD < 1023)
     andBool #callSuccess(PCC, ACCTTO)
     andBool ACCTFROM =/=K ACCTTO
     andBool VALUE <=Int ORIGFROM
     andBool ORIGTO +Int VALUE <Int pow256
    [trusted, matching(#gas)]

  // TODO: send() succeed and ACCTFROM ==K ACCTTO

  // Special rules for `ISignatureValidator(currentOwner).isValidSignature(data, contractSignature)`.
  // ACCTTO will be a complex expression and it is hard to match to a specific account in the accounts map.
  rule <k> #exec[CALL] => #setLocalMem RETSTART 32 #buf(32, #callResult(PCC, ACCTTO)) ... </k>
       <output> _ => #buf(32, #callResult(PCC, ACCTTO)) </output>
       <schedule> SCHED </schedule>
       <id> ACCTFROM </id>
       <wordStack> GASCAP : ACCTTO : VALUE : ARGSTART : ARGWIDTH : RETSTART : 32 : WS => 1 : WS </wordStack>
       <pc> PCC </pc>
       <gas> #gas(INITGAS, NONMEM, MEM) => #gas(INITGAS, NONMEM +Int #callGas(SCHED, GASCAP, ACCTTO, VALUE, true), MEM) </gas>
       <previousGas> _ => #gas(INITGAS, NONMEM, MEM) </previousGas>
       <callDepth> CD </callDepth>
    requires #range(0 <= CD < 1023)
     andBool #callSuccess(PCC, ACCTTO)
     andBool VALUE ==Int 0
    [trusted, matching(#gas)]

  // call() fail
  rule <k> #exec[CALL] => . ... </k>
       <output> _ => _ </output>
       <schedule> SCHED </schedule>
       <wordStack> GASCAP : ACCTTO : VALUE : ARGSTART : ARGWIDTH : RETSTART : REWIDTH : WS => 0 : WS </wordStack>
       <pc> PCC </pc>
       <gas> #gas(INITGAS, NONMEM, MEM) => #gas(INITGAS, NONMEM +Int #callGas(SCHED, GASCAP, ACCTTO, VALUE, false), MEM) </gas>
       <previousGas> _ => #gas(INITGAS, NONMEM, MEM) </previousGas>
    requires #callFailure(PCC, ACCTTO)
    [trusted, matching(#gas)]

  rule <k> #exec[CALL] => . ... </k>
       <output> _ => #buf(#tokenTransferCallReturnSize(PCC, ACCTTO, NOW), #tokenTransferCallReturnValue(PCC, ACCTTO, NOW)) </output>
       <schedule> SCHED </schedule>
       <id> ACCTFROM </id>
       <wordStack> GASCAP : ACCTTO : 0 : ARGSTART : ARGWIDTH : 0 : 0 /* end of CALL args */ : X : Y : AMOUNT : RECEIVER : WS => 1 : X : Y : AMOUNT : RECEIVER : WS </wordStack>
       <localMem> LM </localMem>
       <pc> PCC </pc>
       <gas> #gas(INITGAS, NONMEM, MEM) => #gas(INITGAS, NONMEM +Int #callGas(SCHED, GASCAP, ACCTTO, VALUE, true), MEM) </gas>
       <previousGas> _ => #gas(INITGAS, NONMEM, MEM) </previousGas>
       <callDepth> CD </callDepth>
       <timestamp> NOW </timestamp>
       <account>
         <acctID> ACCTTO </acctID>
         <storage> _ => _ </storage>
         ...
       </account>
    requires #range(0 <= CD < 1023)
     andBool #tokenTransferCallSuccess(PCC, ACCTTO)
  // andBool selectRange(LM, ARGSTART, ARGWIDTH) ==K #abiCallData("transfer", (#address(RECEIVER), #uint256(AMOUNT)))
    [trusted, matching(#gas)]
  // The above condition requires that the calldata generated by
  // `abi.encodeWithSignature("transfer(address,uint256)", receiver, amount)`
  // is correctly encoded. The left hand side evaluates to
  // ```
  // #buf ( 32 , #asWord ( selectRange ( M , ... , 4 ) ++ #bufSeg ( #buf ( 32 , RECEIVER ) , 0 , 28 ) ) &Int (2 ^Int (8 *Int 28) -Int 1) |Int 0xa9059cbb00000000000000000000000000000000000000000000000000000000 )
  // ++ #bufSeg( #buf( 32 , RECEIVER ) , 28 , 4 )
  // ++ #buf( 32 , AMOUNT )
  // ```
  // while the right hand side yields
  // `0xa9 : 0x05 : 0x9c : 0xbb : ( #buf ( 32 , RECEIVER ) ++ #buf ( 32 , AMOUNT ) )`.
  // It can be easily checked that those values are indeed equal, however,
  // K can't prove it because of the sophisticated structure. Adding more
  // lemmas might be helpful.

  rule <k> #exec[CALL] => . ... </k>
       <output> _ => #buf(#tokenTransferCallReturnSize(PCC, ACCTTO, NOW), #tokenTransferCallReturnValue(PCC, ACCTTO, NOW)) </output>
       <schedule> SCHED </schedule>
       <id> ACCTFROM </id>
       <wordStack> GASCAP : ACCTTO : 0 : ARGSTART : ARGWIDTH : 0 : 0 /* end of CALL args */ : X : Y : AMOUNT : RECEIVER : WS => 0 : X : Y : AMOUNT : RECEIVER : WS </wordStack>
       <localMem> LM </localMem>
       <pc> PCC </pc>
       <gas> #gas(INITGAS, NONMEM, MEM) => #gas(INITGAS, NONMEM +Int #callGas(SCHED, GASCAP, ACCTTO, VALUE, true), MEM) </gas>
       <previousGas> _ => #gas(INITGAS, NONMEM, MEM) </previousGas>
       <callDepth> CD </callDepth>
       <timestamp> NOW </timestamp>
       <account>
         <acctID> ACCTTO </acctID>
         <storage> _ => _ </storage>
         ...
       </account>
    requires #range(0 <= CD < 1023)
     andBool #tokenTransferCallFailure(PCC, ACCTTO)
  // andBool selectRange(LM, ARGSTART, ARGWIDTH) ==K #abiCallData("transfer", (#address(RECEIVER), #uint256(AMOUNT)))
    [trusted, matching(#gas)]


  // ########################
  // EXTCODESIZE
  // ########################

  rule <k> EXTCODESIZE ACCT => #extCodeSize(ACCT) ~> #push ... </k>  [trusted]

endmodule
