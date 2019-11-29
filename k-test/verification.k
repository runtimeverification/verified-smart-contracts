requires "evm-symbolic.k"
requires "evm-data-map-concrete.k"
requires "edsl.k"
requires "../lemmas.k"

module VERIFICATION
    imports EVM-SYMBOLIC
    imports EVM-DATA-MAP-CONCRETE
    imports EDSL
    imports LEMMAS

    rule X <Int pow256 => true
       requires X <Int 256

    rule X <Int pow256 => true
       requires X <Int pow160

    rule 0 <=Int X => true
       requires 0 <Int X

    //Rules for #padToWidth with regular symbolic arguments.
    //Same as for concrete #padToWidth, when WordStack is of regular form "A:B ... :.WordStack"
    //Not clear why KEVM rules for #padToWidth were marked [concrete]. If they were general, rules below would not be necessary.
    rule #padToWidth(N, WS) => WS
      requires notBool #sizeWordStack(WS) <Int N andBool #isRegularWordStack(WS) ==K true

    rule #padToWidth(N, WS) => #padToWidth(N, 0 : WS)
      requires         #sizeWordStack(WS) <Int N andBool #isRegularWordStack(WS) ==K true

    //Rules for #padToWidth with non-regular symbolic arguments.
    rule #padToWidth(32, #asByteStack(V)) => #asByteStackInWidth(V, 32)
      requires 0 <=Int V andBool V <Int pow256 andBool #notKLabel(V, "#asWord")

    //1-byte ByteStack.
    rule #asByteStack(W) => W : .WordStack
      requires #rangeUInt(8, W) andBool 0 <Int W

    // Byte arrays with concrete size
    // Code sugar to represent byte arrays with concrete size but symbolic data.
    syntax TypedArg ::= #toBytes    ( Int , Int )      [function] //data, len
 // -----------------------------------------------------------------
    rule #toBytes(DATA, N) => #bytes(#asByteStackInWidth(DATA, N))
      requires #rangeBytes(N, DATA)

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
    //decoding nthbyteof(#asWord())
    rule nthbyteof(#asWord(W : WS), I       , N       )
      => nthbyteof(#asWord(    WS), I -Int 1, N -Int 1)
      requires 0 <Int I andBool I <Int N andBool N <=Int 32 andBool N ==Int #sizeWordStack(W : WS)

    rule nthbyteof(#asWord(W : WS), 0, N) => W
      requires N <=Int 32 andBool N ==Int #sizeWordStack(W : WS)

    //decoding nthbyteof(#asWord() &Int MASK)
    rule nthbyteof(#asWord(W : WS) &Int MASK, I       , N       )
      => nthbyteof(#asWord(    WS) &Int MASK, I -Int 1, N -Int 1)
      requires 0 <Int I andBool I <Int N andBool N <=Int 32 andBool N ==Int #sizeWordStack(W : WS)

    rule nthbyteof(#asWord(W : WS) &Int MASK, 0, N) => W &Int (MASK >>Byte #sizeWordStack(WS))
      requires N <=Int 32 andBool N ==Int #sizeWordStack(W : WS)

    //decoding nthbyteof() &Int MASK
    rule MASK &Int nthbyteof(WS, I, N) => nthbyteof(WS, I, N) &Int MASK
      requires #isConcrete(MASK)

    rule nthbyteof(_, _, _)  &Int (MASK => MASK &Int 255)
      requires #isConcrete(MASK) andBool MASK >Int 255

    rule nthbyteof(WS, I, N) &Int 255 => nthbyteof(WS, I, N)

    //decoding #asWord() &Int MASK
    rule MASK &Int #asWord(WS) => #asWord(WS) &Int MASK
      requires #isConcrete(MASK)
      //version below doesn't work
      //requires notBool (getKLabel(MASK) ==K #klabel(`#asWord`))

    //#asWord(...) & 255 is the last byte.
    rule #asWord( X : Y : WS => Y : WS ) &Int 255
    rule #asWord( X : .WordStack       ) &Int 255 => X

    // #asWord only keeps 32 bytes and chops the rest.
    rule #asWord(W : WS => WS)
      requires #sizeWordStack(W : WS) >Int 32


    syntax WordStack ::= #bytesSegment (Int, Int, Int, Int) [function] //DATA, START, RANGE_LEN, DATA_LEN
 // ===============================================================
    rule #bytesSegment(DATA, START, LEN, N)
         => nthbyteof(DATA, START, N) : #bytesSegment(DATA, START +Int 1, LEN -Int 1, N)
      requires #range ( 0 <= START < N ) andBool #range( 1 <= START +Int LEN <= N ) andBool LEN >Int 0

    rule #bytesSegment(_, _, 0, _) => .WordStack

endmodule
