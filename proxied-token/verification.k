requires "evm-symbolic.k"
requires "edsl.k"
requires "../lemmas.k"

module VERIFICATION
    imports EDSL
    imports LEMMAS
    imports EVM-SYMBOLIC

    rule #sizeWordStack(WS, N) <Int SIZE => #sizeWordStack(WS, 0) +Int N <Int SIZE  requires N =/=Int 0
    rule SIZELIMIT <Int #sizeWordStack(WS, N) +Int DELTA  => SIZELIMIT <Int (#sizeWordStack(WS, 0) +Int N) +Int DELTA  requires N =/=Int 0
    rule SIZELIMIT <Int #sizeWordStack(WS, N)             => SIZELIMIT <Int #sizeWordStack(WS, 0) +Int N               requires N =/=Int 0

    rule #sizeWordStack(WS, N) <=Int SIZE => #sizeWordStack(WS, 0) +Int N <=Int SIZE requires N =/=Int 0

    //Rules for #padToWidth with non-regular symbolic arguments.
    rule #padToWidth(32, #asByteStack(V)) => #asByteStackInWidth(V, 32)
      requires 0 <=Int V andBool V <Int pow256 andBool #notKLabel(V, "#asWord")

    rule X modInt Y => X
      requires 0 <=Int X andBool X <Int Y

    rule chop ( W0:Int +Int W1:Int ) -Word W1:Int => chop ( W0 )
        requires #rangeUInt(256, W0) andBool #rangeUInt(256, W1)

    // The number below is equal to: (2^256 - 1) - (2^160 - 1), which in hex would be graphically
    // f...f (24 times) ++ 0...0 (40 times). An Ethereum address has at most 40 hex digits.
    // It follow when we bit-wise AND the two numbers, the result will always be 0.

    rule 115792089237316195423570985007226406215939081747436879206741300988257197096960 &Int X:Int => 0
        requires #rangeAddress(X)
endmodule
