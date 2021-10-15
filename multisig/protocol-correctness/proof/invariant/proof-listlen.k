module PROOF-LISTLEN
  imports PSEUDOCODE
  imports INVARIANT-EXECUTION

  // TODO: Remove the <k> cell.
  claim <k> call(listLen([.])) => u(0) ... </k>

  claim <k> call(listLen([E:Expression , Es:ExpressionCSV])) => u(1 +Int pListLen([Es])) ... </k>
    requires isKResult(E) andBool isKResult(Es)

  claim <k> call(listLen(L:ExpressionList)) => u(pListLen(L)) ... </k>
    requires isKResult(L)

endmodule
