requires "edsl.k"
requires "../lemmas-buf.k"

module EVM-DATA-MAP-SYMBOLIC [symbolic]
    imports K-REFLECTION
    imports EVM-DATA
    imports EDSL
    imports LEMMAS

  // ########################
  // Buffer Reasoning
  // ########################

    rule WS ++ .ByteArray => WS

    syntax Bool ::= #isBuf ( ByteArray ) [function]
    rule #isBuf(#buf(_,_)) => true

    rule #sizeByteArray(W : WS)        => 1 +Int #sizeByteArray(WS)
    rule #sizeByteArray(#buf(N, _)  )  => N
    rule #sizeByteArray(BUF1 ++ BUF2)  => #sizeByteArray(BUF1) +Int #sizeByteArray(BUF2)
    rule #sizeByteArray(#drop(N, BUF)) => maxInt(#sizeByteArray(BUF) -Int N, 0)

    rule #take(N, BUF)          => BUF                                              requires N ==Int #sizeByteArray(BUF)
    rule #take(N, BUF1 ++ BUF2) => #take(N, BUF1)                                   requires N <=Int #sizeByteArray(BUF1)
    rule #take(N, BUF1 ++ BUF2) => BUF1 ++ #take(N -Int #sizeByteArray(BUF1), BUF2) requires N  >Int #sizeByteArray(BUF1)

    rule #drop(N, BUF)           => .ByteArray                               requires #sizeByteArray(BUF) <=Int N
    rule #drop(N, BUF1 ++ BUF2)  => #drop(N -Int #sizeByteArray(BUF1), BUF2) requires N >=Int #sizeByteArray(BUF1)
    rule #drop(N, BUF1 ++ BUF2)  => #drop(N, BUF1) ++ BUF2                   requires N <Int #sizeByteArray(BUF1)

    rule #asWord(#buf(N, BUF)) => BUF

    rule #asWord(BUF) /Int 26959946667150639794667015087019630673637144422540572481103610249216 => #asWord(#take(4, BUF))

    rule M [ N := BUF ] [ N := BUF' ] => M [ N := BUF' ] requires #sizeByteArray(BUF) ==Int #sizeByteArray(BUF')

    rule BUF [ L .. W ] => .ByteArray requires W <=Int 0
    rule BUF [ 0 .. W ] => BUF        requires W ==Int #sizeByteArray(BUF)
    rule BUF [ L .. W ] => .ByteArray requires L  >Int #sizeByteArray(BUF)

    rule #range(M, N, K) => .ByteArray requires notBool K >Int 0

    rule #range(M [ N := BUF:ByteArray ], L, K) => #range(M, L, minInt(K, N -Int L)) ++ #range(M [ N := BUF ], N, K -Int minInt(K, N -Int L))
      requires K >Int 0
       andBool L <Int N

    rule #range(M [ N := BUF ], L, K) => BUF [ L -Int N .. minInt(K, #sizeByteArray(BUF) -Int (L -Int N)) ] ++ #range(M, N +Int #sizeByteArray(BUF), K -Int minInt(K, #sizeByteArray(BUF) -Int (L -Int N)))
      requires K  >Int 0
       andBool L >=Int N
       andBool L  <Int N +Int #sizeByteArray(BUF)

    rule #range(M [ N := BUF ], L, K) => #range(M, L, K)
      requires K  >Int 0
       andBool L >=Int N +Int #sizeByteArray(BUF)

    rule keccak(BUF1 ++ BUF2) => hash2(#asWord(BUF1), #asWord(BUF2)) requires #sizeByteArray(BUF1) ==Int 32 andBool #sizeByteArray(BUF2) ==Int 32


  // ########################
  // Symbolic Word Map
  // ########################

    syntax Map ::= store  ( Map , Int , Int ) [function, smtlib(storeInt) ]
    syntax Int ::= select ( Map , Int )       [function, smtlib(selectInt)]
 // -----------------------------------------------------------------------
    rule select(store(M, K0, V), K) => V            requires K0  ==Int K
    rule select(store(M, K0, V), K) => select(M, K) requires K0 =/=Int K

    syntax Map       ::= storeRange  ( Map , Int , Int , ByteArray ) [function, smtlib(storeRange) ]
    syntax ByteArray ::= selectRange ( Map , Int , Int )             [function, smtlib(selectRange)]
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

    // TODO: check validity: i.e., WS ==K .ByteArray
    rule storeRange(M, _, WIDTH, _) => M requires WIDTH ==Int 0

    rule selectRange(M, _, WIDTH) => .ByteArray requires WIDTH ==Int 0

    // lifting

    rule #lookup(M, K:Int)         => select(M, K)   requires notBool (#isConcrete(M) andBool #isConcrete(K))
    rule M:Map [ K:Int <- V:Int ]  => store(M, K, V) requires notBool (#isConcrete(M) andBool #isConcrete(K) andBool #isConcrete(V))

    rule #range(M, START, WIDTH) => selectRange(M, START, WIDTH)                 requires notBool (#isConcrete(M) andBool #isConcrete(START) andBool #isConcrete(WIDTH))
    rule M [ START := WS ]       => storeRange(M, START, #sizeByteArray(WS), WS) requires notBool (#isConcrete(M) andBool #isConcrete(START) andBool #isConcrete(WS))

    // once it gets down to the concrete map, return to the corresponding function
    // shouldn't have the infinite rule application
    rule select(M, K)                 => #lookup(M, K)           [concrete]
    rule selectRange(M, START, WIDTH) => #range(M, START, WIDTH) [concrete]
endmodule
