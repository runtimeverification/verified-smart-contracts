requires "abstract-semantics-segmented-gas.k"
requires "evm-symbolic.k"

module ABSTRACT-SEMANTICS
  imports ABSTRACT-SEMANTICS-SEGMENTED-GAS
  imports EVM-SYMBOLIC
  imports EVM

    rule <k> SHA256 => #end EVMC_SUCCESS ... </k>
         <callData> DATA </callData>
         <output> _ => #buf(32, #sha256(DATA)) </output>
      requires notBool #isConcrete(DATA)
      [trusted]

/*
    rule <k> MSTORE8 INDEX VALUE => . ... </k>
//       <localMem> LM => LM [ INDEX <- (VALUE modInt 256) ] </localMem>
//       <localMem> LM => storeRange(LM, INDEX, 1, #buf(1, VALUE modInt 256)) </localMem>
//       <localMem> LM => LM [ INDEX := ((VALUE modInt 256) : .WordStack) ] </localMem>
         <localMem> LM => LM [ INDEX := #buf(1, VALUE modInt 256) ] </localMem>
      requires notBool (#isConcrete(LM) andBool #isConcrete(INDEX) andBool #isConcrete(VALUE))
      [trusted]
*/

  // ########################
  // Gas - in addition to ABSTRACT-SEMANTICS-COMMON
  // ########################

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

endmodule
