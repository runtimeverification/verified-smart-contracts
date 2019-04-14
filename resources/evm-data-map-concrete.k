requires "edsl.k"

module EVM-DATA-MAP-CONCRETE [symbolic]
    imports K-REFLECTION
    imports EVM-DATA
    imports EDSL
    
    // Same rules exist in KEVM, but are marked [concrete]. Allowing them for symbolic arguments here.

    rule #lookup( (KEY |-> VAL) M, KEY ) => VAL
    rule #lookup(               M, KEY ) => 0 requires notBool KEY in_keys(M)
        
    rule #range(WM, START, WIDTH) => #range(WM, START +Int WIDTH -Int 1, WIDTH, .WordStack)
    
    rule WM[ N := W : WS     ] => (WM[N <- W])[N +Int 1 := WS]

    //semantics of #buf
    rule #buf(LEN, BYTES) => #padToWidth(LEN, #asByteStack( BYTES ))

endmodule
