module ABSTRACT-SEMANTICS
  imports EVM
  // to avoid unnecessary case analyses
  /*rule <k> LT W0 W1 => bool2Word(W0  <Int W1) ~> #push ... </k> [trusted]

  rule <k> GT W0 W1 => bool2Word(W0  >Int W1) ~> #push ... </k> [trusted]

  rule <k> EQ W0 W1 => bool2Word(W0 ==Int W1) ~> #push ... </k> [trusted]

  rule <k> ISZERO W => bool2Word(W  ==Int 0 ) ~> #push ... </k> [trusted]

  rule <k> SLT W0 W1 => W0 s<Word W1 ~> #push ... </k> [trusted]
  rule <k> SGT W0 W1 => W1 s<Word W0 ~> #push ... </k> [trusted]*/

  rule <k> #gasExec(SCHED, EXP W0 W1) => Gexp < SCHED > +Int (Gexpbyte < SCHED > *Int 32) ... </k>
    requires W1 =/=K 0 [trusted]

  rule <k> #gasExec(SCHED, SSTORE INDEX VALUE) => Gsstoreset < SCHED > ... </k> [trusted]

  rule <k> Ccallgas(SCHED, ISEMPTY:Bool, GCAP, GAVAIL, 0) => Cgascap(SCHED, GCAP, GAVAIL, Cextra(SCHED, 0, ISEMPTY)) ... </k> [trusted]

  rule <k> Ccallgas(SCHED, ISEMPTY:Bool, GCAP, GAVAIL, VALUE)
          => Cgascap(SCHED, GCAP, GAVAIL, Cextra(SCHED, VALUE, ISEMPTY)) +Int Gcallstipend < SCHED > ... </k>
    requires VALUE =/=Int 0 [trusted]

endmodule
