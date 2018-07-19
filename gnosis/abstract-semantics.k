module ABSTRACT-SEMANTICS
  imports EVM

  // to avoid unnecessary case analyses
  rule <k> LT W0 W1 => bool2Word(W0  <Int W1) ~> #push ... </k> [trusted]
  rule <k> GT W0 W1 => bool2Word(W0  >Int W1) ~> #push ... </k> [trusted]
  rule <k> EQ W0 W1 => bool2Word(W0 ==Int W1) ~> #push ... </k> [trusted]
  rule <k> ISZERO W => bool2Word(W  ==Int 0 ) ~> #push ... </k> [trusted]

  // FIXME: temporary hack for internal function
  // checkHash
  rule
    <k> (#execute => #execute) ~> _ </k>
    <callState>
      <wordStack> SIGNATURES : TXHASH : WS => WS </wordStack>
      <pc> 13439 => 13936 </pc>
      ...
    </callState>
    requires #sizeWordStack(WS) <=Int 500 //exact?
     andBool #sizeWordStack(WS) >=Int 0
     andBool #rangeUInt(256, TXHASH)
     andBool #rangeUInt(256, SIGNATURES)
    [trusted]

endmodule
