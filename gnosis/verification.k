requires "edsl.k"
requires "../lemmas.k"

module VERIFICATION
    imports EDSL
    imports LEMMAS

    //
    // Range
    //

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

    //Rule doesn't apply. Why?
    syntax Int ::= symkeccak ( Int ) [function, smtlib(smt_symkeccak)]
    rule keccak(WS) => symkeccak(#asWord(WS))
      requires notBool #isConcrete(WS)
               //to avoid collision with rule keccak(WS) => keccakIntList(...)
               andBool #sizeWordStack(WS) =/=Int 32 andBool #sizeWordStack(WS) =/=Int 64

    //
    // Unification
    //

 // rule   #signed(X) ==K   #signed(Y) => X ==K Y requires #rangeUInt(256,X) orBool #rangeUInt(256,Y)
 // rule #unsigned(X) ==K #unsigned(Y) => X ==K Y requires #rangeSInt(256,X) orBool #rangeSInt(256,Y)


// Reading symbolic WordStack from memory, then extracting bytes from it. General case (stack size can be != 32)
//========================================================================
    rule nthbyteof(chop(#asWord(W : WS) &Int MASK), I       , N       )
      => nthbyteof(chop(#asWord(    WS) &Int MASK), I -Int 1, N -Int 1)
      requires I >Int 0 andBool #sizeWordStack(W : WS) <=Int 32

    rule nthbyteof(chop(#asWord(W : WS) &Int MASK), 0, N) => W &Int (MASK >>Byte #sizeWordStack(WS))
      requires #sizeWordStack(W : WS) <=Int 32

    rule nthbyteof(_, _, _)  &Int (A => A &Int 255)
      requires A >Int 255

    rule nthbyteof(WS, I, N) &Int 255 => nthbyteof(WS, I, N)

    rule nthbyteof(chop(MASK &Int #asWord(WS)) => chop(#asWord(WS) &Int MASK), _, _)
      requires #isConcrete(MASK)
      //version below doesn't work
      //requires notBool (getKLabel(MASK) ==K #klabel(`#asWord`))

    // #asWord only keeps 32 bytes and chops the rest.
    rule #asWord(W : WS => WS)
      requires #sizeWordStack(W : WS) >Int 32

    syntax WordStack ::= #encSig (Int, Int, Int) [function]
 // ===============================================================
    rule #encSig(SIG_R, SIG_S, SIG_V) => #enc(#bytes32(SIG_R)) ++ #enc(#bytes32(SIG_S)) ++ #getValue(#uint8(SIG_V)) : .WordStack

endmodule
