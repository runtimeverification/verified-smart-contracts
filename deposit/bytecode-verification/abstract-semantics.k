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



/*  interval gas abstraction

    rule Cgascap(SCHED, GCAP, GAVAIL, GEXTRA)
      => #if GAVAIL <Int GEXTRA orBool Gstaticcalldepth << SCHED >> #then GCAP #else minItv(#allBut64th(GAVAIL -Int GEXTRA), GCAP) #fi
        requires #isConcrete(SCHED)
         andBool #isConcreteItv(GCAP)
         andBool #isConcreteItv(GAVAIL)
         andBool #isConcreteItv(GEXTRA)

    rule Cextra(SCHED, ISEMPTY, VALUE)
      => Gcall < SCHED >
            +Int #if ISEMPTY #then #makeItv(0, Gnewaccount < SCHED >) #else 0 #fi // Cnew(SCHED, ISEMPTY, VALUE)
            +Int #makeItv(0, Gcallvalue < SCHED >)                                // Cxfer(SCHED, VALUE)
        requires #isConcrete(SCHED)
         andBool #isConcrete(ISEMPTY)
         andBool notBool #isConcrete(VALUE)

    rule Cmem(SCHED, N) => (N *Int Gmemory < SCHED >) +Int ((N *Int N) /Int Gquadcoeff < SCHED >)
        requires #isConcrete(SCHED)
         andBool #isConcreteItv(N)

    rule Csstore(SCHED, NEW, CURR, ORIG) => #makeItv(Gsstorereset < SCHED >, Gsstoreset < SCHED >)
        requires #isConcrete(SCHED)
         andBool notBool ( #isConcrete(NEW) andBool #isConcrete(CURR) )
         andBool notBool Ghasdirtysstore << SCHED >>

    rule #memoryUsageUpdate(MU, START, WIDTH) => maxItv(MU, (START +Int WIDTH) up/Int 32) requires WIDTH >Int 0
        requires #isConcreteItv(MU)
         andBool #isConcreteItv(START)
         andBool #isConcreteItv(WIDTH)
*/



    rule <k> #gasExec(SCHED, CALL GCAP ACCTTO VALUE _ _ _ _)
          => #accountNonexistent(ACCTTO) ~> #setupCallGas(SCHED, GCAP, VALUE)
          ~> 0 ... </k>
        [trusted]

    rule <k> ISEMPTY:Bool
          ~> #setupCallGas(SCHED, GCAP, VALUE)
          => #setupCallGasAux(SCHED, VALUE, Cextra(SCHED, ISEMPTY, VALUE),
               Cgascap(SCHED, GCAP, GAVAIL, Cextra(SCHED, ISEMPTY, VALUE)), 0 -Int Ccallstipend(VALUE)) ... </k>
         <gas> GAVAIL </gas>
        [trusted]

    rule <k> #setupCallGasAux(SCHED, VALUE, GEXTRA, CGASCAP, CCALLSTIPEND) => . ... </k>
         <gas> GAVAIL => #gasUsageUpdate(#gasUsageUpdate(GAVAIL, GEXTRA), CGASCAP) </gas>
         <previousGas> _ => #gasUsageUpdate(#symGas(CGASCAP, 0, 0, .List, 0), CCALLSTIPEND) </previousGas>
        [trusted]

    rule <k> #refund #symGas(C, LB', UB', S', MU') => Cmem(SCHED, MU') ~> #deductGas ... </k>
         <gas> #symGas(X, LB, UB, S ListItem(C), MU) => #symGas(X, LB +Int LB', UB +Int UB', S S', MU) </gas>
         <schedule> SCHED </schedule>
        [trusted, matching(#symGas)]

/*
    rule <k> #gasExec(SCHED, CALL GCAP ACCTTO VALUE _ _ _ _)
          => Ccallgas(SCHED, #accountNonexistent(ACCTTO), GCAP, GAVAIL, VALUE) ~> #allocateCallGas
          ~> Ccall   (SCHED, #accountNonexistent(ACCTTO), GCAP, GAVAIL, VALUE)
         ...
         </k>
         <gas> GAVAIL </gas>

    rule <k> Ccallgas(SCHED, ISEMPTY:Bool, GCAP, GAVAIL, VALUE)
          => Cgascap(SCHED, GCAP, GAVAIL, Cextra(...)) +Int Ccallstipend(VALUE) ... </k>

    rule <k> Ccall(SCHED, ISEMPTY:Bool, GCAP, GAVAIL, VALUE)
          => Cextra(...) +Int
             Cgascap(SCHED, GCAP, GAVAIL, Cextra(...)) ... </k>

    rule Cgascap(SCHED, GCAP, GAVAIL, GEXTRA)
      => #if GAVAIL <Int GEXTRA #then GCAP #else minInt(#allBut64th(GAVAIL -Int GEXTRA), GCAP) #fi  [concrete]

    rule Cextra(SCHED, ISEMPTY, VALUE)
      => 700 +Int Cnew(SCHED, ISEMPTY, VALUE) +Int Cxfer(SCHED, VALUE)  [concrete]

    rule Cnew(SCHED, ISEMPTY:Bool, VALUE)
      => #if ISEMPTY andBool VALUE =/=Int 0 #then 25000 #else 0 #fi

    rule Cxfer(SCHED, 0    ) => 0
    rule Cxfer(SCHED, VALUE) => 9000 requires VALUE =/=Int 0

    rule Gcall         < EIP150 > => 700
    rule Gcallstipend < DEFAULT > => 2300
    rule Gcallvalue   < DEFAULT > => 9000
    rule Gnewaccount  < DEFAULT > => 25000

    rule Gstaticcalldepth        << EIP150 >> => false
    rule Gzerovaluenewaccountgas << EIP158 >> => false

    rule Cmem(SCHED, N) => (N *Int Gmemory < SCHED >) +Int ((N *Int N) /Int Gquadcoeff < SCHED >)  [concrete]
*/




//  syntax Int ::= #symGas(Int) [function, smtlib(gas)]

/* NOTE:
   These abstractions are over-approximation, except that out-of-gas exceptions are ignored.
   The out-of-gas exception is not harmful when it comes to safety properties, and it can be avoided by simply providing enough gas.
   The only problematic case is to call sub-functions with a specific amount of gas (instead of all available gas at that point).
   In this case, additional analyses need to be made to ensure that the specific amount of gas is sufficient, for liveness properties.

   In particular, the deposit contract involves precompiled contract calls (i.e., SHA256 and ID), where ID calls are fed a specific amount of gas.
   That is, the amount of gas provided to ID calls is "18 + floor(CALLDATASIZE / 10)",
   which is greater than the actual gas cost of ID calls, "15 + 3 * ceil(CALLDATASIZE / 32)".
   Indeed, the sufficiency is not trivial to show, but the former is simpler (thus more gas-efficient) to compute at runtime than the latter.
   Other calls are either private calls or calls with all available gas.
*/

/*
    // uninterpreted gas abstraction, except #symGas(I) < #symGas(J) if I > J
    rule <k> _:Int ~> #deductGas => . ... </k>
         <gas> #symGas(N => N +Int 1) </gas>
        [trusted, matching(#symGas)]
*/

    rule <k> G':Int ~> #deductGas => . ... </k>
         <gas> G => #gasUsageUpdate(G, G') </gas>
        [trusted]

/*
    // uninterpreted memory usage abstraction, except #symMem(I) <= #symMem(J) if I < J
    rule <k> _:Int ~> #deductMemory => . ... </k>
         <memoryUsed> #symMem(N => N +Int 1) </memoryUsed>
        [trusted, matching(#symMem)]
*/

    rule <k> MU':Int ~> #deductMemory => . ... </k>
         <gas> #symGas(_, _, _, _, MU => MU') </gas>
         <memoryUsed> MU => MU' </memoryUsed>
        [trusted, matching(#symGas)]

/*
    // another unknown initial gas --- spawn in a new vm, thus no name clash
    rule <k> Ccallgas(SCHED, _, _, _, _) => #symGas(0) ... </k>
        [trusted]

    // ignore refund, since it does not affect the #symGas property.
    rule <k> #refund G:Int => . ... </k>
        [trusted]
*/


/*
//  rule <k> #gasExec(SCHED, CALL GCAP ACCTTO VALUE ARGSTART ARGWIDTH RETSTART RETWIDTH) => ??? ... </k>

    rule <k> #gasExec(SCHED, CALL GCAP 2 0 ARGSTART ARGWIDTH RETSTART RETWIDTH)
          => Cextra(SCHED, true, 0) +Int (60 +Int  12 *Int (ARGWIDTH up/Int 32)) ... </k>
        [trusted]

    rule <k> #gasExec(SCHED, CALL GCAP 4 0 ARGSTART ARGWIDTH RETSTART RETWIDTH)
          => Cextra(SCHED, true, 0) +Int (15 +Int   3 *Int (ARGWIDTH up/Int 32)) ... </k>
        [trusted]
*/


/*
    // ignore memory usage gas cost
    rule <k> MU':Int ~> #deductMemory => . ... </k>
         <memoryUsed> MU => MU' </memoryUsed>
        [trusted]

//  // no need to divide
//  rule #memoryUsageUpdate(MU, START, WIDTH) => maxInt(MU, START +Int WIDTH) requires WIDTH >Int 0
//      requires notBool (#isConcrete(MU) andBool #isConcrete(START) andBool #isConcrete(WIDTH))

    // no need to multiply
    rule <k> MSIZE => #ceil32(MU) ~> #push ... </k>
         <memoryUsed> MU </memoryUsed>
        [trusted]
*/


endmodule
