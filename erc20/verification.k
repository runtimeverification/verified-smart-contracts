requires "edsl.k"
requires "../lemmas.k"

module VERIFICATION
    imports EDSL
    imports LEMMAS

    rule 0 <=Int #asWord(WS)             => true
    rule         #asWord(WS) <Int pow256 => true requires #sizeWordStack(WS) <=Int 32

    rule chop(#asWord(WS)) => #asWord(#drop(#sizeWordStack(WS) -Int 32, WS))
      requires #sizeWordStack(WS) >Int 32

    syntax WordStack ::= WordStack "&ByteStack" WordStack [function]

    // equal length assumed
    rule (B1 : BS1) &ByteStack (B2 : BS2) => (B1 &Int B2) : (BS1 &ByteStack BS2)

    rule .WordStack &ByteStack .WordStack => .WordStack

    rule I &Int #asWord(WS) => #asWord(#asByteStackInWidth(I, #sizeWordStack(WS)) &ByteStack WS)

 // <Int 256 defined in lemmas.md, but not applied for `MASK &Int N => .. requires .. N <=Int MASK`
    rule nthbyteof(V, I, N) <=Int 255 => true

    rule #asWord( 0 : 0 : 0 : 0 : 0 : 0 : 0 : 0 : 0 : 0 : 0 : 0
                : nthbyteof(ADDR, 0, 20)
                : nthbyteof(ADDR, 1, 20)
                : nthbyteof(ADDR, 2, 20)
                : nthbyteof(ADDR, 3, 20)
                : nthbyteof(ADDR, 4, 20)
                : nthbyteof(ADDR, 5, 20)
                : nthbyteof(ADDR, 6, 20)
                : nthbyteof(ADDR, 7, 20)
                : nthbyteof(ADDR, 8, 20)
                : nthbyteof(ADDR, 9, 20)
                : nthbyteof(ADDR, 10, 20)
                : nthbyteof(ADDR, 11, 20)
                : nthbyteof(ADDR, 12, 20)
                : nthbyteof(ADDR, 13, 20)
                : nthbyteof(ADDR, 14, 20)
                : nthbyteof(ADDR, 15, 20)
                : nthbyteof(ADDR, 16, 20)
                : nthbyteof(ADDR, 17, 20)
                : nthbyteof(ADDR, 18, 20)
                : nthbyteof(ADDR, 19, 20)
                : .WordStack ) => ADDR
      requires 0 <=Int ADDR andBool ADDR <=Int maxUInt160

 // bytestack shift?

endmodule
