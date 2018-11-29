requires "edsl.k"
requires "lemmas.k"

module VERIFICATION
    imports EDSL
    imports LEMMAS

    rule chop ( W0:Int +Int W1:Int ) -Word W1:Int => chop ( W0 )
      requires #rangeUInt(256, W0) andBool #rangeUInt(256, W1)
endmodule
