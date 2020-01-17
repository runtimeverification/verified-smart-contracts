requires "edsl.k"

module EVM-DATA-MAP-SYMBOLIC [symbolic]
    imports K-REFLECTION
    imports EVM-DATA
    imports EDSL

  // ########################
  // Buffer Reasoning
  // ########################

    rule ( WS1 ++ WS2 ) ++ WS3 => WS1 ++ ( WS2 ++ WS3 )

    syntax WordStack ::= #bufSeg ( WordStack , Int , Int ) [function, smtlib(bufSeg)] // BUFFER, START, WIDTH
    syntax Int       ::= #bufElm ( WordStack , Int )       [function] // BUFFER, INDEX

    syntax Bool ::= #isBuf ( WordStack ) [function]
    rule #isBuf(#buf(_,_)) => true
    rule #isBuf(#bufSeg(_,_,_)) => true

    rule #asWord(#buf(SIZE, DATA)) => DATA requires SIZE <=Int 32

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


    rule #sizeWordStack ( BUF ++ WS, SIZE ) => #sizeWordStack(WS, SIZE +Int #sizeBuffer(BUF)) requires #isBuf(BUF)
    rule #sizeWordStack ( BUF      , SIZE ) =>                    SIZE +Int #sizeBuffer(BUF)  requires #isBuf(BUF)

    syntax Int ::= #sizeBuffer ( WordStack ) [function]
 // ---------------------------------------------------
    rule #sizeBuffer ( #buf(N,_) )      => N
    rule #sizeBuffer ( #bufSeg(_,_,N) ) => N


  // ########################
  // Symbolic Word Map
  // ########################

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
endmodule
