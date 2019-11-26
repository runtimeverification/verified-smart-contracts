
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

