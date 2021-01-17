module PROOF-LISTLEN
  imports PSEUDOCODE
  imports INVARIANT-EXECUTION

  claim <k> call(listLen([.])) => u(0) ... </k>
        <last-instrumented> .K </last-instrumented>

  claim <k> call(listLen([E:Expression , Es:ExpressionCSV])) => u(1 +Int pListLen([Es])) ... </k>
        <last-instrumented> .K </last-instrumented>
    requires isKResult(E) andBool isKResult(Es)

  claim <k> call(listLen(L:ExpressionList)) => u(pListLen(L)) ... </k>
        <last-instrumented> .K </last-instrumented>
    requires isKResult(L)

endmodule
