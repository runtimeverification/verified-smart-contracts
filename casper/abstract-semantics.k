module ABSTRACT-SEMANTICS
  imports EVM
  // to avoid unnecessary case analyses
  rule <k> LT W0 W1 => bool2Word(W0  <Int W1) ~> #push ... </k> [trusted]
  rule <k> GT W0 W1 => bool2Word(W0  >Int W1) ~> #push ... </k> [trusted]
  rule <k> EQ W0 W1 => bool2Word(W0 ==Int W1) ~> #push ... </k> [trusted]
  rule <k> ISZERO W => bool2Word(W  ==Int 0 ) ~> #push ... </k> [trusted]
  rule <k> #gasExec(SCHED, EXP W0 W1) => Gexp < SCHED > +Int (Gexpbyte < SCHED > *Int 32) ... </k>
    requires W1 =/=K 0 [trusted]
  rule <k> #gasExec(SCHED, SSTORE INDEX VALUE) => Gsstoreset < SCHED > ... </k> [trusted]
endmodule
