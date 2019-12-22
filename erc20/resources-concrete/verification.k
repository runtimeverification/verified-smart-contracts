requires "evm-symbolic.k"
requires "evm-data-map-concrete.k"
requires "edsl.k"
requires "../lemmas.k"

module VERIFICATION
    imports EVM-SYMBOLIC
    imports EVM-DATA-MAP-CONCRETE
    imports EDSL
    imports LEMMAS

    //Rules for #padToWidth with non-regular symbolic arguments.
    rule #padToWidth(32, #asByteStack(V)) => #asByteStackInWidth(V, 32)
      requires 0 <=Int V andBool V <Int pow256

    rule #asByteStackInWidth(#asWord(WS), N) => WS
      requires #noOverflow(WS) andBool N ==Int #sizeWordStack(WS)

    rule chop ( W0:Int +Int W1:Int ) -Word W1:Int => chop ( W0 )
      requires #rangeUInt(256, W0) andBool #rangeUInt(256, W1)
endmodule
