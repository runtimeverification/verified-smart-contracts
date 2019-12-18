requires "evm-symbolic.k"
requires "evm-data-map-concrete-buf.k"
requires "edsl.k"
requires "../lemmas.k"

module VERIFICATION
    imports EVM-SYMBOLIC
    imports EVM-DATA-MAP-CONCRETE-BUF
    imports EDSL
    imports LEMMAS

    rule #padToWidth(32, #asByteStack(V)) => #buf(32, V) // #asByteStackInWidth(V, 32)
      requires 0 <=Int V andBool V <Int pow256 //andBool #notKLabel(V, "#asWord") //todo #notKLabel disabling for test

    rule #buf(N, #asWord(WS)) => WS
      requires #noOverflow(WS) andBool N ==Int #sizeWordStack(WS)

    rule chop ( W0:Int +Int W1:Int ) -Word W1:Int => chop ( W0 )
      requires #rangeUInt(256, W0) andBool #rangeUInt(256, W1)
endmodule
