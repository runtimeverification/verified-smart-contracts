requires "edsl.k"
requires "../lemmas.k"

module VERIFICATION
    imports EDSL
    imports LEMMAS

    //Rules for #padToWidth with non-regular symbolic arguments.
    rule #padToWidth(32, #asByteStack(V)) => #asByteStackInWidth(V, 32)
      requires 0 <=Int V andBool V <Int pow256 andBool #getKLabelString(V) =/=String "#asWord"

    rule chop ( W0:Int +Int W1:Int ) -Word W1:Int => chop ( W0 )
      requires #rangeUInt(256, W0) andBool #rangeUInt(256, W1)
endmodule
