requires "edsl.k"
requires "../lemmas.k"

module VERIFICATION
    imports EDSL
    imports LEMMAS

 // FIXME: remove this
    syntax TypedArg ::= #bytes ( WordStack )
    rule #typeName(#bytes( _ )) => "bytes"
    rule #lenOfHead(#bytes( _ )) => 32
    rule #isStaticType(#bytes( _ )) => false
    rule #sizeOfDynamicType(#bytes( WS )) => 32 +Int #ceil32(#sizeWordStack(WS))
    rule #enc(#bytes(WS)) => #enc(#uint256(#sizeWordStack(WS))) ++ #padRightToWidth(#ceil32(#sizeWordStack(WS)), WS)

    rule #enc( #bytes(N, DATA)) => #enc(#uint256(N)) ++ #padRightToWidth(#ceil32(N), #asByteStack(DATA))

    syntax WordStack ::= #padRightToWidth ( Int , WordStack ) [function]
 // --------------------------------------------------------------------
    rule  #padRightToWidth(N, WS) => #padRightToWidthAux(N -Int #sizeWordStack(WS), WS, .WordStack)

    syntax WordStack ::= #padRightToWidthAux ( Int , WordStack , WordStack ) [function]
 // -----------------------------------------------------------------------------------
    rule #padRightToWidthAux(0, WS, ZEROS) => WS ++ ZEROS
    rule #padRightToWidthAux(N, WS, ZEROS) => #padRightToWidthAux(N -Int 1, WS, 0 : ZEROS)
      requires N >Int 0

    //
    // Range
    //

    // maxUInt256 vs pow256
    rule X <=Int maxUInt256 => X <Int pow256

    rule 0 <=Int (X modInt Y)         => true
    rule         (X modInt Y) <Int Y  => true  requires Y >Int 0

    rule 0 <=Int 2 ^Int X             => true
    rule         2 ^Int X <Int pow256 => true  requires X <Int 256

    rule 0 <=Int X &Int Y             => true  requires #rangeUInt(256, X) andBool #rangeUInt(256, Y)
    rule         X &Int Y <Int pow256 => true  requires #rangeUInt(256, X) andBool #rangeUInt(256, Y)

    rule 0 <=Int X |Int Y             => true  requires #rangeUInt(256, X) andBool #rangeUInt(256, Y)
    rule         X |Int Y <Int pow256 => true  requires #rangeUInt(256, X) andBool #rangeUInt(256, Y)

    rule 0 <=Int #blockhash(_, _, _, _)             => true
    rule         #blockhash(_, _, _, _) <Int pow256 => true

    rule 0 <=Int symkeccak(N)             => true
    rule         symkeccak(N) <Int pow256 => true

    //
    // Simplification
    //

    // TODO: move to builtin
    rule N -Int N => 0

    rule 2 ^%Int X pow256 => 2 ^Int X
      requires 0 <=Int X andBool X <Int 256

    rule X modInt Y => X
      requires 0 <=Int X andBool X <Int Y

    rule ((X *Int Y) /Int Z) /Int Y => X /Int Z

    rule 1 |Int chop(A xorInt maxUInt256) => 1

    rule chop((ADDR &Int maxUInt160) modInt pow160) => ADDR
      requires #rangeAddress(ADDR)

    // 2^256 - 2^160 = 0xff..ff00..00 (96 1's followed by 160 0's)
    rule 115792089237316195423570985007226406215939081747436879206741300988257197096960 &Int ADDR => 0
      requires #rangeAddress(ADDR)

    //
    // Abstraction
    //

    syntax Int ::= symkeccak ( Int ) [function, smtlib(smt_symkeccak)]
    rule keccak(WS) => symkeccak(#asWord(WS))  requires notBool #isConcrete(WS)

    //
    // Unification
    //

 // rule   #signed(X) ==K   #signed(Y) => X ==K Y requires #rangeUInt(256,X) orBool #rangeUInt(256,Y)
 // rule #unsigned(X) ==K #unsigned(Y) => X ==K Y requires #rangeSInt(256,X) orBool #rangeSInt(256,Y)

endmodule
