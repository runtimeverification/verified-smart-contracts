requires "edsl.k"

// NOTE: This module includes all lemmas (except assosiativity ones) in both lemmas.md and evm-data-map-symbolic.k

module LEMMAS
    imports K-REFLECTION
    imports EDSL

    //////////////////////////
    // Macros
    //////////////////////////

    syntax Int ::= "pow24"
                 | "pow32"
                 | "pow40"
                 | "pow48"
                 | "pow56"
                 | "pow64"
    rule pow24 => 16777216                  [macro]
    rule pow32 => 4294967296                [macro]
    rule pow40 => 1099511627776             [macro]
    rule pow48 => 281474976710656           [macro]
    rule pow56 => 72057594037927936         [macro]
    rule pow64 => 18446744073709551616      [macro]

    syntax Bool ::= #regularAddress(Schedule, Int)
    rule #regularAddress(SCHEDULE, X) => X >Int 0 andBool (notBool X in #precompiledAccounts(SCHEDULE))  [macro]

    syntax Bool ::= #notKLabel ( K , String ) [function]
    rule #notKLabel(T, L) => #getKLabelString(T) =/=String L orBool #isVariable(T)

    // normalization

    rule X <=Int maxUInt256 => X <Int pow256
    rule X <=Int maxUInt160 => X <Int pow160
    rule X <=Int 255        => X <Int 256

    rule X >Int Y => Y <Int X
    rule X >=Int Y => Y <=Int X

    rule notBool (X <Int Y) => Y <=Int X
    rule notBool (X <=Int Y) => Y <Int X

    //orienting symbolic term to be first, converting -Int to +Int for concrete values.
    rule I +Int B => B          +Int I when #isConcrete(I) andBool notBool #isConcrete(B)
    rule A -Int I => A +Int (0 -Int I) when notBool #isConcrete(A) andBool #isConcrete(I)

    // eDSL

    rule #hashedLocation("Array", BASE, OFFSET OFFSETS) => #hashedLocation("Array", keccakIntList(BASE) +Word OFFSET, OFFSETS)

    //////////////////////////
    // Range Predicates
    //////////////////////////

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

    rule 0 <=Int #bufElm(_, _)             => true
    rule         #bufElm(_, _) <Int 256    => true
    rule         #bufElm(_, _) <Int pow256 => true

    rule 0 <=Int bool2Word(_)             => true
    rule         bool2Word(_) <Int 2      => true
    rule         bool2Word(_) <Int 256    => true
    rule         bool2Word(_) <Int pow256 => true

    rule 0 <=Int X xorInt maxUInt256             => true  requires #rangeUInt(256, X)
    rule         X xorInt maxUInt256 <Int pow256 => true  requires #rangeUInt(256, X)

    rule 0 <=Int #asWord(WS)             => true
    rule         #asWord(WS) <Int pow256 => true

    rule 0 <=Int chop(V)             => true
    rule         chop(V) <Int pow256 => true

    rule 0 <=Int keccak(V)             => true
    rule         keccak(V) <Int pow256 => true

    rule 0 <=Int keccakIntList(_)             => true
    rule         keccakIntList(_) <Int pow256 => true

    rule 0 <=Int  #sha256(_)             => true
    rule          #sha256(_) <Int pow256 => true

    syntax Bool ::= isStorage(Map) [function]
    rule 0 <=Int select(M, _)             => true requires isStorage(M)
    rule         select(M, _) <Int pow256 => true requires isStorage(M)


    //////////////////////////
    // Arithmetic
    //////////////////////////

    // TODO: move to builtin

    rule N +Int 0 => N

    rule N -Int 0 => N
    rule N -Int N => 0

    rule 1 *Int N => N
    rule N *Int 1 => N
    rule 0 *Int _ => 0
    rule _ *Int 0 => 0

    rule N /Int 1 => N

    rule 0 |Int N => N
    rule N |Int 0 => N
    rule N |Int N => N

    rule 0 &Int N => 0
    rule N &Int 0 => 0
    rule N &Int N => N

    rule (A +Int I2) +Int I3 => A +Int (I2 +Int I3) when notBool #isConcrete(A) andBool #isConcrete(I2) andBool #isConcrete(I3)

    rule A +Int (I -Int A) => I when notBool #isConcrete(A) andBool #isConcrete(I)

    rule 0 <=Int X +Int Y => true requires 0 <=Int X andBool 0 <=Int Y

    //
    // nonlinear
    //

    rule chop(I) => I requires 0 <=Int I andBool I <Int pow256

    // safeMath mul check c / a == b where c == a * b
    rule (X *Int Y) /Int X => Y  requires X =/=Int 0
    rule chop(X *Int Y) /Int X ==K Y => false  requires X =/=Int 0 andBool pow256 <=Int X *Int Y

    rule chop((ADDR &Int maxUInt160) modInt pow160) => ADDR
      requires #rangeAddress(ADDR)

    rule 2 ^%Int X pow256 => 2 ^Int X
      requires 0 <=Int X andBool X <Int 256

    rule X modInt Y => X
      requires 0 <=Int X andBool X <Int Y

    rule ((X *Int Y) /Int Z) /Int Y => X /Int Z
      requires Y =/=Int 0

    rule (X /Int 32) *Int 32 => X  requires X modInt 32 ==Int 0

    rule #ceil32(X) => X requires X modInt 32 ==Int 0

    rule X <=Int #ceil32(X) => true
      requires X >=Int 0

    rule (X +Int 31) /Int 32 *Int 32 => #ceil32(X)
    rule (31 +Int X) /Int 32 *Int 32 => #ceil32(X)

    //
    // bitwise
    //

    // 0xffff...f &Int N = N
    rule MASK &Int N => N  requires MASK ==Int (2 ^Int (log2Int(MASK) +Int 1)) -Int 1 // MASK = 0xffff...f
                            andBool 0 <=Int N andBool N <=Int MASK

    // N &Int 0xffff...f = N
    rule N &Int MASK => N  requires MASK ==Int (2 ^Int (log2Int(MASK) +Int 1)) -Int 1 // MASK = 0xffff...f
                            andBool 0 <=Int N andBool N <=Int MASK

    // 0xff..ff00..00 (16 1's followed by 240 0's)
    rule 115790322390251417039241401711187164934754157181743688420499462401711837020160 &Int #asWord(WS1 ++ WS2)
        => #asWord(WS1 ++ #buf(30, 0))
      requires #sizeWordStack(WS1) ==Int 2
       andBool #sizeWordStack(WS2) ==Int 30

    // x &Int (NOT 31)
    rule X &Int 115792089237316195423570985008687907853269984665640564039457584007913129639904 => (X /Int 32) *Int 32  requires 0 <=Int X

    // 2^256 - 2^160 = 0xff..ff00..00 (96 1's followed by 160 0's)
    rule 115792089237316195423570985007226406215939081747436879206741300988257197096960 &Int ADDR => 0
      requires #rangeAddress(ADDR)

    rule #asWord(WS) &Int maxUInt256 => #asWord(WS)

    //
    // boolean
    //

    rule bool2Word(A) |Int bool2Word(B) => bool2Word(A  orBool B)
    rule bool2Word(A) &Int bool2Word(B) => bool2Word(A andBool B)

    rule 1 |Int bool2Word(B) => 1
    rule 1 &Int bool2Word(B) => bool2Word(B)

    rule bool2Word(B) |Int 1 => 1
    rule bool2Word(B) &Int 1 => bool2Word(B)

    rule bool2Word(A)  ==K 0 => notBool(A)
    rule bool2Word(A)  ==K 1 => A
    rule bool2Word(A) =/=K 0 => A
    rule bool2Word(A) =/=K 1 => notBool(A)

    rule chop(bool2Word(B)) => bool2Word(B)


    //////////////////////////
    // Buffer Abstraction
    //////////////////////////

    syntax WordStack ::= #bufSeg ( WordStack , Int , Int ) [function, smtlib(bufSeg)] // BUFFER, START, WIDTH
    syntax Int       ::= #bufElm ( WordStack , Int )       [function] // BUFFER, INDEX

    syntax Bool ::= #isBuf ( WordStack ) [function]
    rule #isBuf(#buf(_,_)) => true
    rule #isBuf(#bufSeg(_,_,_)) => true

    syntax Bool ::= #isTake ( WordStack ) [function]
    rule #isTake(#take(_,_)) => true
    rule #isTake(#takeAux(_,_,_)) => true


    rule #asWord(#buf(SIZE, DATA)) => DATA requires SIZE <=Int 32 andBool #range(0 <= DATA < (2 ^Int (SIZE *Int 8))) andBool #isConcrete(SIZE)

    rule #buf(SIZE, _)        => .WordStack requires SIZE  ==Int 0
    rule #bufSeg(_, _, WIDTH) => .WordStack requires WIDTH ==Int 0

    rule #bufSeg(WS, START, WIDTH) => WS requires START ==Int 0 andBool WIDTH ==Int #sizeWordStack(WS)

    rule #bufSeg(#bufSeg(BUF, START0, WIDTH0), START, WIDTH)
      => #bufSeg(BUF, START0 +Int START, WIDTH)
      requires 0 <=Int START andBool START +Int WIDTH <=Int WIDTH0

    rule #bufElm(#bufSeg(BUF, START0, WIDTH0), INDEX)
      => #bufElm(BUF, START0 +Int INDEX)
      requires 0 <=Int INDEX andBool INDEX <Int WIDTH0


    // Auxiliary function to make rules compatible with simplification `rule WS ++ .WordStack => WS`
    syntax WordStack ::= #takeAux ( Int , WordStack , WordStack ) [function]
 // ------------------------------------------------------------------------
    rule #take(N, BUF      ) => #takeAux(N, BUF, .WordStack)               requires #isBuf(BUF)
    rule #take(N, BUF ++ WS) => #takeAux(N, BUF, WS)                       requires #isBuf(BUF)
    rule #takeAux(N, BUF, WS) => #bufSeg(BUF, 0, N)                        requires 0 <=Int N andBool N <=Int #sizeBuffer(BUF)
    rule #takeAux(N, BUF, WS) => BUF ++ #take(N -Int #sizeBuffer(BUF), WS) requires N >Int #sizeBuffer(BUF)

    rule #take(N, .WordStack) => #buf(N, 0) requires notBool #isConcrete(N)

    syntax WordStack ::= #dropAux ( Int , WordStack , WordStack ) [function]
 // ------------------------------------------------------------------------
    rule #drop(N, BUF      ) => #dropAux(N, BUF, .WordStack)                    requires #isBuf(BUF)
    rule #drop(N, BUF ++ WS) => #dropAux(N, BUF, WS)                            requires #isBuf(BUF)
    rule #dropAux(N, BUF, WS) => #bufSeg(BUF, N, #sizeBuffer(BUF) -Int N) ++ WS requires 0 <=Int N andBool N <=Int #sizeBuffer(BUF)
    rule #dropAux(N, BUF, WS) => #drop(N -Int #sizeBuffer(BUF), WS)             requires N >=Int #sizeBuffer(BUF)

    syntax Int ::= #getElmAux ( WordStack , WordStack , Int ) [function]
 // --------------------------------------------------------------------
    rule (BUF      ) [ N ] => #getElmAux(BUF, .WordStack, N)      requires #isBuf(BUF)
    rule (BUF ++ WS) [ N ] => #getElmAux(BUF, WS, N)              requires #isBuf(BUF)
    rule #getElmAux(BUF, WS, N) => #bufElm(BUF, N)                requires 0 <=Int N andBool N <Int #sizeBuffer(BUF)
    rule #getElmAux(BUF, WS, N) => WS [ N -Int #sizeBuffer(BUF) ] requires N >=Int #sizeBuffer(BUF)


    rule #sizeWordStack ( BUF ++ WS, SIZE ) => #sizeWordStack(WS, SIZE +Int #sizeBuffer(BUF)) requires #isBuf(BUF) orBool #isTake(BUF)
    rule #sizeWordStack ( BUF      , SIZE ) =>                    SIZE +Int #sizeBuffer(BUF)  requires #isBuf(BUF) orBool #isTake(BUF)

    syntax Int ::= #sizeBuffer ( WordStack ) [function]
 // ---------------------------------------------------
    rule #sizeBuffer ( #buf(N,_) )      => N
    rule #sizeBuffer ( #bufSeg(_,_,N) ) => N

    rule #sizeBuffer ( #take(N,_) )      => N
    rule #sizeBuffer ( #takeAux(N,_,_) ) => N

    //
    // simplification
    //

    rule ( WS1 ++ WS2 ) ++ WS3 => WS1 ++ ( WS2 ++ WS3 )

    rule WS ++ .WordStack => WS

//  rule #asWord( 0 : W1 : WS  =>  W1 : WS )
    rule #asWord( 0 :      WS  =>       WS )

    rule #padToWidth(32, #asByteStack(V)) => #buf(32, V)
      requires 0 <=Int V andBool V <Int pow256 andBool #notKLabel(V, "#asWord")

    rule #buf(32, #asWord(WS)) => WS  requires #sizeWordStack(WS) ==Int 32
    rule #buf(32, #asWord(#bufSeg(BUF, START, WIDTH))) => #bufSeg(BUF, START +Int WIDTH -Int 32, 32)  requires WIDTH >=Int 32

    rule #asWord(#bufSeg(BUF, START, WIDTH)) &Int 255 => #asWord(#bufSeg(BUF, START +Int WIDTH -Int 1, 1))  requires WIDTH >=Int 1
    rule 255 &Int #asWord(#bufSeg(BUF, START, WIDTH)) => #asWord(#bufSeg(BUF, START +Int WIDTH -Int 1, 1))  requires WIDTH >=Int 1

    rule #bufSeg(BUF, START, 1) => #bufElm(BUF, START) : .WordStack
    rule #asWord(#bufElm(BUF, INDEX) : .WordStack) => #bufElm(BUF, INDEX)

    rule #buf(SIZE, DATA) => #padToWidth(SIZE, #asByteStack(DATA)) requires #range(0 <= DATA < (2 ^Int (SIZE *Int 8))) [concrete]

    rule #asWord(WS0 ++ #buf(MASKWIDTH0, 0)) |Int #asWord(#buf(MASKWIDHT1, 0) ++ WS1)
      => #asWord(WS0 ++ WS1)
      requires #sizeWordStack(WS0) +Int MASKWIDTH0 ==Int 32
       andBool #sizeWordStack(WS0) ==Int MASKWIDHT1
       andBool MASKWIDTH0 ==Int #sizeWordStack(WS1)

    rule #noOverflowAux(BUF) => true requires #isBuf(BUF) orBool #isTake(BUF)
    rule #noOverflowAux(WS1 ++ WS2) => #noOverflowAux(WS1) andBool #noOverflowAux(WS2)

    rule #bufSeg(BUF, S0, W0) ++ #bufSeg(BUF, S1, W1) => #bufSeg(BUF, S0, W0 +Int W1)
      requires S1 ==Int S0 +Int W0

    rule #bufSeg(BUF, S0, W0) ++ (#bufSeg(BUF, S1, W1) ++ WS) => #bufSeg(BUF, S0, W0 +Int W1) ++ WS
      requires S1 ==Int S0 +Int W0

    rule 0 <=Int #sizeWordStack ( _ , _ ) => true [smt-lemma]

    rule #sizeWordStack(WS, N) <Int SIZE => #sizeWordStack(WS, 0) +Int N <Int SIZE  requires N =/=Int 0
    rule SIZELIMIT <Int #sizeWordStack(WS, N) +Int DELTA  => SIZELIMIT <Int (#sizeWordStack(WS, 0) +Int N) +Int DELTA  requires N =/=Int 0
    rule SIZELIMIT <Int #sizeWordStack(WS, N)             => SIZELIMIT <Int #sizeWordStack(WS, 0) +Int N               requires N =/=Int 0

    rule #sizeWordStack(WS, N) <=Int SIZE => #sizeWordStack(WS, 0) +Int N <=Int SIZE requires N =/=Int 0

    rule #sizeWordStack(selectRange(_, _, WIDTH), SIZE) => SIZE +Int WIDTH

    rule #take(#sizeWordStack(WS, 0), WS) => WS

    rule #bufSeg(BUF, N, WIDTH) => BUF requires WIDTH ==Int #sizeBuffer(BUF)

    rule selectRange(storeRange(M, START1, WIDTH1, BUF), START2, WIDTH2) => BUF
      requires START1 ==Int START2 andBool WIDTH1 ==Int WIDTH2

/*
    // Merge
    rule storeRange(storeRange(M, MS0, MW0, #bufSeg(BUF, BS0, BW0)), MS1, MW1, #bufSeg(BUF, BS1, BW1))
        => storeRange(M, MS0, MW0 +Int MW1, #bufSeg(BUF, BS0, MW0 +Int MW1))
      requires #isBuf(BUF) andBool MW0 ==Int BW0 andBool MW1 ==Int BW1
       andBool MS1 ==Int MS0 +Int MW0 andBool BS1 ==Int BS0 +Int BW0
*/

    // for Vyper
    rule #padToWidth(N, #asByteStack(#asWord(WS))) => WS
      requires #noOverflow(WS) andBool N ==Int #sizeWordStack(WS)

    syntax Bool ::= #noOverflow    ( WordStack ) [function]
                  | #noOverflowAux ( WordStack ) [function]
 // -------------------------------------------------------
    rule #noOverflow(WS) => #sizeWordStack(WS) <=Int 32 andBool #noOverflowAux(WS)

    rule #noOverflowAux(W : WS)     => 0 <=Int W andBool W <Int 256 andBool #noOverflowAux(WS)
    rule #noOverflowAux(.WordStack) => true


    //////////////////////////
    // Map
    //////////////////////////

    syntax Map ::= store  ( Map , Int , Int ) [function, smtlib(storeInt) ]
    syntax Int ::= select ( Map , Int )       [function, smtlib(selectInt)]
 // -----------------------------------------------------------------------
    rule select(store(M, K0, V), K) => V            requires K0  ==Int K
    rule select(store(M, K0, V), K) => select(M, K) requires K0 =/=Int K

    syntax Map       ::= storeRange  ( Map , Int , Int , WordStack ) [function, smtlib(storeRange) ]
    syntax WordStack ::= selectRange ( Map , Int , Int )             [function, smtlib(selectRange)]
 // ------------------------------------------------------------------------------------------------
    rule select(storeRange(M, START, WIDTH, WS), K) => WS[K -Int START] requires          START <=Int K andBool K <Int START +Int WIDTH
    rule select(storeRange(M, START, WIDTH, WS), K) => select(M, K)     requires notBool (START <=Int K andBool K <Int START +Int WIDTH)

    rule selectRange(store(M, K0, V), START, WIDTH) => selectRange(M, START, WIDTH) requires ( K0 <Int START orBool START +Int WIDTH <=Int K0 ) // no overlap

    // included: [START0..[START..END]..END0]
    rule selectRange(storeRange(M, START0, WIDTH0, WS), START, WIDTH) => WS [ START -Int START0 .. WIDTH ]
      requires START0 <=Int START andBool START +Int WIDTH <=Int START0 +Int WIDTH0

    // no overlap: [START..END]..[START0..END0]  or  [START0..END0]..[START..END]
    rule selectRange(storeRange(M, START0, WIDTH0, WS), START, WIDTH) => selectRange(M, START, WIDTH)
      requires ( (START +Int WIDTH) <=Int START0 orBool (START0 +Int WIDTH0) <=Int START )

    // left  margin: [START..(START0..END]..END0)  or  [START..(START0..END0)..END]
    rule selectRange(storeRange(M, START0, WIDTH0, WS), START, WIDTH) => selectRange(M, START, START0 -Int START)
                                                                      ++ selectRange(storeRange(M, START0, WIDTH0, WS), START0, (START +Int WIDTH) -Int START0)
      requires START <Int START0 andBool START0 <Int START +Int WIDTH
       andBool WIDTH0 >=Int 1 // to avoid unnecessary split

    // right margin: (START0..[START..END0)..END]  or  [START..(START0..END0)..END]
    rule selectRange(storeRange(M, START0, WIDTH0, WS), START, WIDTH) => selectRange(storeRange(M, START0, WIDTH0, WS), START, (START0 +Int WIDTH0) -Int START)
                                                                      ++ selectRange(M, START0 +Int WIDTH0, (START +Int WIDTH) -Int (START0 +Int WIDTH0))
      requires START <Int START0 +Int WIDTH0 andBool START0 +Int WIDTH0 <Int START +Int WIDTH
       andBool WIDTH0 >=Int 1 // to avoid unnecessary split

    // simplification

    rule store(M, K, select(M, K)) => M

    // TODO: check validity: i.e., WS ==K .WordStack
    rule storeRange(M, _, WIDTH, _) => M requires WIDTH ==Int 0

    rule selectRange(M, _, WIDTH) => .WordStack requires WIDTH ==Int 0

    // lifting

    rule #lookup(M, K:Int)         => select(M, K)   requires notBool (#isConcrete(M) andBool #isConcrete(K))
    rule M:Map [ K:Int <- V:Int ]  => store(M, K, V) requires notBool (#isConcrete(M) andBool #isConcrete(K) andBool #isConcrete(V))

    rule #range(M, START, WIDTH) => selectRange(M, START, WIDTH)                 requires notBool (#isConcrete(M) andBool #isConcrete(START) andBool #isConcrete(WIDTH))
    rule M [ START := WS ]       => storeRange(M, START, #sizeWordStack(WS), WS) requires notBool (#isConcrete(M) andBool #isConcrete(START) andBool #isConcrete(WS))

    // once it gets down to the concrete map, return to the corresponding function
    // shouldn't have the infinite rule application
    rule select(M, K)                 => #lookup(M, K)           [concrete]
    rule selectRange(M, START, WIDTH) => #range(M, START, WIDTH) [concrete]

    // equalities

    syntax Bool ::= Map "==IMap" Map [function, smtlib(=)]
    syntax Bool ::= Map "==IMap" Map "except" Set [function]
 // --------------------------------------------------------
    rule store(M1, K, _) ==IMap M2 except Ks
      =>       M1        ==IMap M2 except Ks
      requires K in Ks

    rule M1 ==IMap store(M2, K, _) except Ks
      => M1 ==IMap       M2        except Ks
      requires K in Ks

    rule M1 ==IMap M2 except _ => true
      requires M1 ==K M2  // structural equality

    syntax Set ::= keys(Map) [function]

    rule K1 in keys(store(M, K2, _)) => true          requires K1  ==Int K2
    rule K1 in keys(store(M, K2, _)) => K1 in keys(M) requires K1 =/=Int K2

    // in-place update

    // store

    rule store(store(M, K0, V0), K1, V1) => store(M, K0, V1)
      requires K0 ==Int K1

    rule store(store(M, K0, V0), K1, V1) => store(store(M, K1, V1), K0, V0)
      requires K0 =/=Int K1 andBool K1 in keys(M)

    // storeRange

    rule storeRange(storeRange(M, K0, W0, V0), K1, W1, V1) => storeRange(M, K0, W0, V1)
      requires range(K0, W0) ==Range range(K1, W1)

    rule storeRange(storeRange(M, K0, W0, V0), K1, W1, V1) => storeRange(storeRange(M, K1, W1, V1), K0, W0, V0)
      requires range(K0, W0) <>Range range(K1, W1)
       andBool range(K1, W1) in keys(M)

    rule storeRange(store(M, K0, V0), K1, W1, V1) => store(storeRange(M, K1, W1, V1), K0, V0)
      requires range(K0, 1) <>Range range(K1, W1) andBool range(K1, W1) in keys(M)

    rule store(storeRange(M, K0, W0, V0), K1, V1) => storeRange(store(M, K1, V1), K0, W0, V0)
      requires range(K0, W0) <>Range range(K1, 1) andBool K1 in keys(M)

    syntax Range ::= range(Int, Int)

    rule range(K1, W1) in keys(storeRange(M, K2, W2, _)) => true                     requires range(K1, W1) ==Range range(K2, W2)
    rule range(K1, W1) in keys(storeRange(M, K2, W2, _)) => range(K1, W1) in keys(M) requires range(K1, W1) <>Range range(K2, W2)

    rule range(K1, W1) in keys(store     (M, K2,     _)) => range(K1, W1) in keys(M) requires range(K1, W1) <>Range range(K2, 1)
    rule       K1      in keys(storeRange(M, K2, W2, _)) =>       K1      in keys(M) requires range(K1, 1)  <>Range range(K2, W2)

    syntax Bool ::= Range "==Range" Range [function]
                  | Range "<>Range" Range [function]

    rule range(K1, W1) ==Range range(K2, W2) => K1 ==Int K2 andBool W1 ==Int W2
    rule range(K1, W1) <>Range range(K2, W2) => K1 +Int W1 <=Int K2 orBool K2 +Int W2 <=Int K1


    //////////////////////////
    // Hash Abstraction
    //////////////////////////
    // sha256

    syntax Int ::= #sha256 ( WordStack ) [function, smtlib(sha256)]

    rule #sha256(DATA) => #asWord(#parseHexBytes(Sha256(#unparseByteStack(DATA)))) [concrete]


    //////////////////////////
    // Gas Abstraction
    //////////////////////////

    // see also abstract-semantics.k

    syntax Int ::= #symGas(Int, Int, Int, List, Int) [function]
    syntax Int ::= #symMem(Int, Set) [function]

    /* Definition
    rule #symGas(INIT, LB, UB, S, MU) => INIT - [LB, UB] - sum(S) - MU
    rule #symMem(N, S) => maxInt(N, maxIntSet(S)) up/Int 32
    */

    syntax Int ::= Int "-Gas" Int [function]
    syntax Int ::= Int "+Gas" Int [function]

    // interval abstraction -- both bounds must be concrete
    syntax Int ::= #itv(Int, Int) [function]

    syntax Int ::= #makeItv(Int, Int) [function]
    rule #makeItv(X1, X2) => #itv(X1, X2) requires X1  <Int X2 andBool #isConcrete(X1) andBool #isConcrete(X2)
    rule #makeItv(X1, X2) => X1           requires X1 ==Int X2 andBool #isConcrete(X1) andBool #isConcrete(X2)

    // #memoryUsageUpdate

    rule #memoryUsageUpdate(#symMem(MU, MUS), START, WIDTH) => #symMem(maxInt(MU, START +Int WIDTH), MUS)
        requires #isConcrete(MU) andBool #isConcrete(START) andBool #isConcrete(WIDTH)

    rule #memoryUsageUpdate(#symMem(MU, MUS), START, WIDTH) => #symMem(MU, SetItem(START +Int WIDTH) MUS)
        requires notBool (#isConcrete(START) andBool #isConcrete(WIDTH))

    rule #memoryUsageUpdate(        MU,       START, WIDTH) => #symMem(MU, SetItem(START +Int WIDTH) .Set)
        requires #isConcrete(MU) andBool notBool (#isConcrete(START) andBool #isConcrete(WIDTH))

    // deductGas

    rule #symGas(I, LB, UB, S, CMEM) -Gas G              => #symGas(I, LB +Int G,   UB +Int G,               S, CMEM)
        requires #isConcrete(G)

    rule #symGas(I, LB, UB, S, CMEM) -Gas #itv(LB', UB') => #symGas(I, LB +Int LB', UB +Int UB',             S, CMEM)

    rule #symGas(I, LB, UB, S, CMEM) -Gas G              => #symGas(I, LB,          UB,          ListItem(G) S, CMEM)
        requires (notBool #isConcrete(G)) andBool #getKLabelString(G) =/=String "#itv" andBool #getKLabelString(G) =/=String "_+Int_"

    rule G -Gas (G1 +Int G2) => (G -Gas G1) -Gas G2

    // refund

    rule #symGas(X,                   LB,          UB,          ListItem(C) S, CMEM) +Gas #symGas(CGASCAP,                   LB', UB', S', CMEM')
      => #symGas(X,                   LB +Int LB', UB +Int UB', S'          S, CMEM) -Gas CMEM'
        requires C ==K CGASCAP
         andBool isPositiveGas(#symGas(CGASCAP,                   LB', UB', S', CMEM'))

    rule #symGas(X,                   LB,          UB,          ListItem(C) S, CMEM) +Gas #symGas(CGASCAP +Int CCALLSTIPEND, LB', UB', S', CMEM')
      => #symGas(X +Int CCALLSTIPEND, LB +Int LB', UB +Int UB', S'          S, CMEM) -Gas CMEM'
        requires C ==K CGASCAP
         andBool isPositiveGas(#symGas(CGASCAP +Int CCALLSTIPEND, LB', UB', S', CMEM'))

    syntax Bool ::= isPositiveGas(Int) [function]

    syntax Bool ::= isInitGas(Int) [function]

    // call with constant gas (particularly for precompiled contract calls)
    rule isPositiveGas(#symGas(Cgascap(_, G, #symGas(IG, _, _, _, _), _),                   _, UB, .List, 0)) => G                   >=Int UB
        requires isInitGas(IG) andBool #isConcrete(G) andBool #isConcrete(UB)
    rule isPositiveGas(#symGas(Cgascap(_, G, #symGas(IG, _, _, _, _), _) +Int CCALLSTIPEND, _, UB, .List, 0)) => G +Int CCALLSTIPEND >=Int UB
        requires isInitGas(IG) andBool #isConcrete(G) andBool #isConcrete(UB) andBool #isConcrete(CCALLSTIPEND)

    // call with all available gas
    rule isPositiveGas(#symGas(Cgascap(_, #symGas(IG, _, _, _, _), _, _),        _, _, _, _)) => true
        requires isInitGas(IG)
    rule isPositiveGas(#symGas(Cgascap(_, #symGas(IG, _, _, _, _), _, _) +Int _, _, _, _, _)) => true
        requires isInitGas(IG)

    //  Cs*

    rule Csstore(SCHED, NEW, CURR, ORIG) => #makeItv(Gsstorereset < SCHED >, Gsstoreset < SCHED >)
        requires #isConcrete(SCHED)
         andBool notBool ( #isConcrete(NEW) andBool #isConcrete(CURR) )
         andBool notBool Ghasdirtysstore << SCHED >>

endmodule
