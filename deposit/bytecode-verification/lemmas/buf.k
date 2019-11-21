
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
  //rule #asWord(#buf(32, DATA)) => DATA  requires #rangeUInt(256, DATA)

    rule #buf(SIZE, _)        => .WordStack requires SIZE  ==Int 0
    rule #bufSeg(_, _, WIDTH) => .WordStack requires WIDTH ==Int 0

    rule #bufSeg(WS, START, WIDTH) => WS requires START ==Int 0 andBool WIDTH ==Int #sizeWordStack(WS)

    rule #bufSeg(#bufSeg(BUF, START0, WIDTH0), START, WIDTH)
      => #bufSeg(BUF, START0 +Int START, WIDTH)
      requires 0 <=Int START andBool START +Int WIDTH <=Int WIDTH0


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

    rule #padToWidth(32, #asByteStack(V)) => #buf(32, V) // #asByteStackInWidth(V, 32)
      requires 0 <=Int V andBool V <Int pow256 andBool #notKLabel(V, "#asWord")

    rule #buf(32, #asWord(WS)) => WS  requires #sizeWordStack(WS) ==Int 32
    rule #buf(32, #asWord(#bufSeg(BUF, START, WIDTH))) => #bufSeg(BUF, START +Int WIDTH -Int 32, 32)  requires WIDTH >=Int 32

    rule #asWord(#bufSeg(BUF, START, WIDTH)) &Int 255 => #asWord(#bufSeg(BUF, START +Int WIDTH -Int 1, 1))  requires WIDTH >=Int 1
    rule 255 &Int #asWord(#bufSeg(BUF, START, WIDTH)) => #asWord(#bufSeg(BUF, START +Int WIDTH -Int 1, 1))  requires WIDTH >=Int 1

    rule #bufSeg(BUF, START, 1) => #bufElm(BUF, START) : .WordStack
    rule #asWord(#bufElm(BUF, INDEX) : .WordStack) => #bufElm(BUF, INDEX)

//  rule #buf(32, DATA) => #padToWidth(32, #asByteStack(DATA))  [concrete]
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

    //
    // nthbyteof
    //

    syntax Int ::= nthbyteof ( Int , Int , Int ) [function, smtlib(smt_nthbyteof), proj]
 // ------------------------------------------------------------------------------------
    rule nthbyteof(V, I, N) => nthbyteof(V /Int 256, I, N -Int 1) when N  >Int (I +Int 1) [concrete]
    rule nthbyteof(V, I, N) =>           V modInt 256             when N ==Int (I +Int 1) [concrete]

    rule #asWord( nthbyteof(V,  0, 32)
                : nthbyteof(V,  1, 32)
                : nthbyteof(V,  2, 32)
                : nthbyteof(V,  3, 32)
                : nthbyteof(V,  4, 32)
                : nthbyteof(V,  5, 32)
                : nthbyteof(V,  6, 32)
                : nthbyteof(V,  7, 32)
                : nthbyteof(V,  8, 32)
                : nthbyteof(V,  9, 32)
                : nthbyteof(V, 10, 32)
                : nthbyteof(V, 11, 32)
                : nthbyteof(V, 12, 32)
                : nthbyteof(V, 13, 32)
                : nthbyteof(V, 14, 32)
                : nthbyteof(V, 15, 32)
                : nthbyteof(V, 16, 32)
                : nthbyteof(V, 17, 32)
                : nthbyteof(V, 18, 32)
                : nthbyteof(V, 19, 32)
                : nthbyteof(V, 20, 32)
                : nthbyteof(V, 21, 32)
                : nthbyteof(V, 22, 32)
                : nthbyteof(V, 23, 32)
                : nthbyteof(V, 24, 32)
                : nthbyteof(V, 25, 32)
                : nthbyteof(V, 26, 32)
                : nthbyteof(V, 27, 32)
                : nthbyteof(V, 28, 32)
                : nthbyteof(V, 29, 32)
                : nthbyteof(V, 30, 32)
                : nthbyteof(V, 31, 32)
                : .WordStack ) => V
      requires 0 <=Int V andBool V <Int pow256

    rule nthbyteof(N, 0, 1) => N

    syntax Bool ::= #isRegularWordStack ( WordStack ) [function]
 // -------------------------------------------------------
    rule #isRegularWordStack(N : WS => WS)
    rule #isRegularWordStack(.WordStack) => true

    // for Vyper
    rule #padToWidth(N, #asByteStack(#asWord(WS))) => WS
      requires #noOverflow(WS) andBool N ==Int #sizeWordStack(WS)

    // storing a symbolic boolean value in memory
    rule #padToWidth(32, #asByteStack(bool2Word(E)))
      => #asByteStackInWidthAux(0, 30, 32, nthbyteof(bool2Word(E), 31, 32) : .WordStack)

    // for Solidity
    rule #asWord(WS) /Int D => #asWord(#take(#sizeWordStack(WS) -Int log256Int(D), WS))
      requires D modInt 256 ==Int 0 andBool D >=Int 0
       andBool #sizeWordStack(WS) >=Int log256Int(D)
       andBool #noOverflow(WS)

    syntax Bool ::= #noOverflow    ( WordStack ) [function]
                  | #noOverflowAux ( WordStack ) [function]
 // -------------------------------------------------------
    rule #noOverflow(WS) => #sizeWordStack(WS) <=Int 32 andBool #noOverflowAux(WS)

    rule #noOverflowAux(W : WS)     => 0 <=Int W andBool W <Int 256 andBool #noOverflowAux(WS)
    rule #noOverflowAux(.WordStack) => true

    syntax WordStack ::= #asByteStackInWidth    ( Int, Int )                 [function]
                       | #asByteStackInWidthAux ( Int, Int, Int, WordStack ) [function]
 // -----------------------------------------------------------------------------------
    rule #asByteStackInWidth(X, N) => #asByteStackInWidthAux(X, N -Int 1, N, .WordStack)
      requires #rangeBytes(N, X)

    rule #asByteStackInWidthAux(X, I => I -Int 1, N, WS => nthbyteof(X, I, N) : WS) when I >=Int 0
    rule #asByteStackInWidthAux(X,            -1, N, WS) => WS

