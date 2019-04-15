requires "edsl.k"

module EVM-DIRECT-GAS     [symbolic]
    imports EVM
    imports EDSL

  // ########################
  // Direct gas representatioon as number - rules copy-pasted from KEVM but without [concrete]
  // ########################

  // Rules from evm.md that got [concrete] as part of migration to segmented gas model.
  // Only enabling the subset that is needed for current specs.
  //-----------------------------------------

/*
    rule #memoryUsageUpdate(MU, START, WIDTH) => maxInt(MU, (START +Int WIDTH) up/Int 32) requires WIDTH >Int 0

    rule Cgascap(SCHED, GCAP, GAVAIL, GEXTRA)
      => #if GAVAIL <Int GEXTRA orBool Gstaticcalldepth << SCHED >> #then GCAP #else minInt(#allBut64th(GAVAIL -Int GEXTRA), GCAP) #fi
*/
    rule Csstore(SCHED, NEW, CURR, ORIG)
      => #if CURR ==Int NEW orBool ORIG =/=Int CURR #then Gsload < SCHED > #else #if ORIG ==Int 0 #then Gsstoreset < SCHED > #else Gsstorereset < SCHED > #fi #fi
      requires Ghasdirtysstore << SCHED >>

    rule Csstore(SCHED, NEW, CURR, ORIG)
      => #if CURR ==Int 0 andBool NEW =/=Int 0 #then Gsstoreset < SCHED > #else Gsstorereset < SCHED > #fi
      requires notBool Ghasdirtysstore << SCHED >>

    rule Rsstore(SCHED, NEW, CURR, ORIG)
      => #if CURR =/=Int NEW andBool ORIG ==Int CURR andBool NEW ==Int 0 #then
             Rsstoreclear < SCHED >
         #else
             #if CURR =/=Int NEW andBool ORIG =/=Int CURR andBool ORIG =/=Int 0 #then
                 #if CURR ==Int 0 #then 0 -Int Rsstoreclear < SCHED > #else #if NEW ==Int 0 #then Rsstoreclear < SCHED > #else 0 #fi #fi
             #else
                 0
             #fi +Int
             #if CURR =/=Int NEW andBool ORIG ==Int NEW #then
                 #if ORIG ==Int 0 #then Gsstoreset < SCHED > #else Gsstorereset < SCHED > #fi -Int Gsload < SCHED >
             #else
                 0
             #fi
         #fi
      requires Ghasdirtysstore << SCHED >>

    rule Rsstore(SCHED, NEW, CURR, ORIG)
      => #if CURR =/=Int 0 andBool NEW ==Int 0 #then Rsstoreclear < SCHED > #else 0 #fi
      requires notBool Ghasdirtysstore << SCHED >>

/*
    rule Cextra(SCHED, ISEMPTY, VALUE)
      => Gcall < SCHED > +Int Cnew(SCHED, ISEMPTY, VALUE) +Int Cxfer(SCHED, VALUE)

    rule Cmem(SCHED, N) => (N *Int Gmemory < SCHED >) +Int ((N *Int N) /Int Gquadcoeff < SCHED >)
*/

endmodule
