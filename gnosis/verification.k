requires "evm-symbolic.k"
requires "../lemmas.k"

module VERIFICATION
    imports EVM-SYMBOLIC
    imports EDSL
    imports LEMMAS

    // Account Map
    syntax Int ::= "#MASTER_COPY_ID" [function]
    syntax Int ::= "#PROXY_ID" [function]
    syntax Int ::= "#ORIGIN_ID" [function]

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

    rule (X *Int 32) +Int 192 ==K (Y *Int 32) +Int 160 => X +Int 1 ==K Y

    rule (X *Int 32) +Int 32 ==K Y *Int 32             => X +Int 1 ==K Y

    rule 192 ==K (X *Int 32) +Int 160                  => X ==K 1

    rule maxInt(maxInt(A, B), C) => maxInt(A, C)  requires B <=Int C

    rule (31 +Int X) /Int 32 *Int 32 => #ceil32(X)

    rule (X +Int 31) /Int 32 *Int 32 => #ceil32(X)

    rule (X /Int 32) *Int 32 => X  requires X modInt 32 ==Int 0

    rule #ceil32(X) => X requires X modInt 32 ==Int 0

    rule #asWord(WS) &Int 115792089237316195423570985008687907853269984665640564039457584007913129639935 => #asWord(WS)

    rule powmod(256, X, pow256) >=Int 1 => true  requires 0 <=Int X andBool X <Int 32

    rule powmod(256, X, pow256) <Int pow256 => true  requires 0 <=Int X

    rule 0 <=Int 32 -Int ( X -Int (X /Int 32) *Int 32 ) => true  requires 0 <=Int X

    rule 32 -Int ( X -Int (X /Int 32) *Int 32 ) <Int 32 => true requires 0 <=Int X andBool X modInt 32 =/=Int 0

    rule 0 <=Int X -Int 1 => true      requires X >=Int 1

    rule X -Int 1 <Int pow256 => true  requires X <Int pow256

    rule 0 <=Int X xorInt 115792089237316195423570985008687907853269984665640564039457584007913129639935 => true      requires 0<=Int X andBool X <Int pow256

    rule X xorInt 115792089237316195423570985008687907853269984665640564039457584007913129639935 <Int pow256 => true  requires 0<=Int X andBool X <Int pow256 

    rule #sizeWordStack(selectRange(_, _, WIDTH), SIZE) => SIZE +Int WIDTH

    rule (I1 +Int I2) -Int (I3 +Int I1) => I2 -Int I3

    rule I1 -Int (I1 -Int I2) => I2

    rule I1 +Int (I2 -Int I1) => I2

    // Left mask
    rule #asWord(WS1 ++ WS2) &Int ((powmod(256, MASKWIDTH, pow256) -Int 1) xorInt 115792089237316195423570985008687907853269984665640564039457584007913129639935)
        => #asWord(WS1 ++ #buf(MASKWIDTH, 0))
      requires 0 <=Int MASKWIDTH
       andBool #sizeWordStack(WS1) +Int #sizeWordStack(WS2) ==Int 32
       andBool #sizeWordStack(WS2) ==Int MASKWIDTH

    // Right mask
    rule #asWord(selectRange(M, START, 32)) &Int (powmod(256, MASKWIDTH, pow256) -Int 1) => #asWord(#buf(32 -Int MASKWIDTH, 0) ++ selectRange(M, START +Int 32 -Int MASKWIDTH, MASKWIDTH))
      requires 0 <=Int MASKWIDTH
       andBool MASKWIDTH <=Int 32

    rule #asWord(WS0 ++ #buf(MASKWIDTH0, 0)) |Int #asWord(#buf(MASKWIDHT1, 0) ++ WS1)
      => #asWord(WS0 ++ WS1)
      requires #sizeWordStack(WS0) +Int MASKWIDTH0 ==Int 32
       andBool #sizeWordStack(WS0) ==Int MASKWIDHT1
       andBool MASKWIDTH0 ==Int #sizeWordStack(WS1)

    rule 0 <=Int #asWord(_) => true

    rule #asWord(_) <Int pow256 => true

    rule #buf(32, #asWord(WS)) => WS  requires #sizeWordStack(WS) ==Int 32

    rule #buf(32, DATA) => #padToWidth(32, #asByteStack(DATA))  [concrete]


    syntax Int ::= #wordFirstNBytesMask ( Int )  [function]
 // -------------------------------------------------------
    rule chop((powmod(256, 32 -Int N, pow256) -Word 1) xorInt 115792089237316195423570985008687907853269984665640564039457584007913129639935) => #wordFirstNBytesMask(N)

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

// Range for #symEcrec
//========================================================================
    //case 0 is never wrapped into #symEcrec(), corresponds to #ecrecEmpty(DATA) == true
    rule 0 <Int   #symEcrec(DATA)             => true

    //that's because the result in concrete semantics is trimmed to Address range.
    rule          #symEcrec(DATA) <Int pow160 => true


 // Memory reasoning
 // ================
    rule #bufSeg(BUF, S0, W0) ++ #bufSeg(BUF, S1, W1) => #bufSeg(BUF, S0, W0 +Int W1)
      requires S1 ==Int S0 +Int W0

    rule storeRange(storeRange(M, MS0, MW0, #bufSeg(BUF, BS0, BW0)), MS1, MW1, #bufSeg(BUF, BS1, BW1))
        => storeRange(M, MS0, MW0 +Int MW1, #bufSeg(BUF, BS0, MW0 +Int MW1))
      requires #isBuf(BUF) andBool MW0 ==Int BW0 andBool MW1 ==Int BW1
       andBool MS1 ==Int MS0 +Int MW0 andBool BS1 ==Int BS0 +Int BW0

endmodule
