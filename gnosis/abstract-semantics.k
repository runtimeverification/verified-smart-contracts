module ABSTRACT-SEMANTICS
  imports EVM

  // to avoid unnecessary case analyses
  rule <k> LT W0 W1 => bool2Word(W0  <Int W1) ~> #push ... </k> [trusted]
  rule <k> GT W0 W1 => bool2Word(W0  >Int W1) ~> #push ... </k> [trusted]
  rule <k> EQ W0 W1 => bool2Word(W0 ==Int W1) ~> #push ... </k> [trusted]
  rule <k> ISZERO W => bool2Word(W  ==Int 0 ) ~> #push ... </k> [trusted]

    //todo model the case #symEcrec() == .Account
    //For this we need 2 regular rules, instead of one spec rule below.
    //One rule for case #symEcrec(DATA) != 0, another for #symEcrec(DATA) == 0,
    //with some extra side condition #isNull(DATA) and notBool #isNull(DATA),
    //designed to match an entry in path condition.
    //This in turn requires the ability to define regular rules in the spec.
  rule <k> ECREC => #end EVMC_SUCCESS ... </k>
       <callData> DATA </callData>
       <output> _ => #ecrec(#symEcrec(DATA)) </output>
    requires notBool #isConcrete(DATA) andBool #sizeWordStack(DATA) ==Int 128
      [trusted]

endmodule
