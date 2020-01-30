requires "evm-symbolic.k"
requires "evm-data-map-symbolic.k"
requires "edsl.k"
requires "../lemmas-buf.k"

module VERIFICATION
    imports EVM-SYMBOLIC
    imports EVM-DATA-MAP-SYMBOLIC
    imports EDSL
    imports LEMMAS

    rule #padToWidth(32, #asByteStack(V)) => #buf(32, V) // #asByteStackInWidth(V, 32)
      requires 0 <=Int V andBool V <Int pow256

    rule #buf(N, #asWord(WS)) => WS
      requires #noOverflow(WS) andBool N ==Int #sizeWordStack(WS)

    rule chop ( W0:Int +Int W1:Int ) -Word W1:Int => chop ( W0 )
      requires #rangeUInt(256, W0) andBool #rangeUInt(256, W1)


  // ########################
  // Gas
  // ########################

    rule 0 <=Int X -Int #gas(A, B, C)             => true  requires #gas(A, B, C) <=Int X
    rule         X -Int #gas(A, B, C) <Int pow256 => true  requires X <Int pow256

    rule #gas(A1, B1, C1) -Int #gas(A1, B2, C2) => (B2 +Int C2) -Int (B1 +Int C1)

    rule 0 <=Int #gas(_, _, _)             => true
    rule         #gas(_, _, _) <Int pow256 => true


  // ########################
  // Buffer Reasoning
  // ########################

    rule #noOverflowAux(BUF) => true requires #isBuf(BUF)
    rule #noOverflowAux(WS1 ++ WS2) => #noOverflowAux(WS1) andBool #noOverflowAux(WS2)

    rule WS ++ .WordStack => WS

    rule #sizeWordStack(WS, N) <Int SIZE => #sizeWordStack(WS, 0) +Int N <Int SIZE  requires N =/=Int 0
    rule SIZELIMIT <Int #sizeWordStack(WS, N) +Int DELTA  => SIZELIMIT <Int (#sizeWordStack(WS, 0) +Int N) +Int DELTA  requires N =/=Int 0
    rule SIZELIMIT <Int #sizeWordStack(WS, N)             => SIZELIMIT <Int #sizeWordStack(WS, 0) +Int N               requires N =/=Int 0

    rule #sizeWordStack(WS, N) <=Int SIZE => #sizeWordStack(WS, 0) +Int N <=Int SIZE requires N =/=Int 0

    rule #bufSeg(BUF, 0, WIDTH) => BUF  requires WIDTH ==Int #sizeWordStack(BUF)

    // #buf unfolding, for concrete DATA
    rule #buf(SIZE, DATA) => #padToWidth(SIZE, #asByteStack(DATA)) requires #range(0 <= DATA < (2 ^Int (SIZE *Int 8))) [concrete]

    // #buf folding, for symbolic DATA - todo test - might apply in too many places
    rule #padToWidth(SIZE, #asByteStack(DATA)) => #buf(SIZE, DATA) requires notBool #isConcrete(DATA)

  // ########################
  // Memory Reasoning
  // ########################

    rule store(M, K, select(M, K)) => M

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
 // -----------------------------------
    rule K1 in keys(store(M, K2, _)) => true          requires K1  ==Int K2
    rule K1 in keys(store(M, K2, _)) => K1 in keys(M) requires K1 =/=Int K2

    //Reduces IMaps where multiple entries share the same key
    rule store(store(M, K0, V0), K1, V1) => store(M, K0, V1)
      requires K0 ==Int K1

    rule store(store(M, K0, V0), K1, V1) => store(store(M, K1, V1), K0, V0)
      requires K0 =/=Int K1 andBool K1 in keys(M)

    rule notBool( hash2(K1,V1) ==K hash2(K2,V2) ) => K1 =/=Int K2 orBool V1 =/=Int V2

    rule A ==K hash2(K,V) => hash2(K,V) ==K A
      requires #isConcrete(A)

    //Assumption of non-collision between hashes and small constants that likely represent memory addresses or offsets.
    rule notBool( hash2(_,_) ==K A ) => true
      requires #isConcrete(A) andBool A <=Int 20

  // ########################
  // Byte Array
  // ########################

    rule WS ++ .WordStack => WS

    rule #sizeWordStack(#buf(N, _)  , M) => M +Int N
    rule #sizeWordStack(BUF1 ++ BUF2, M) => M +Int #sizeWordStack(BUF1) +Int #sizeWordStack(BUF2)
    rule #sizeWordStack(#drop(N, BUF))   => maxInt(#sizeWordStack(BUF) -Int N, 0)

    rule #take(N, BUF)          => BUF                                              requires N ==Int #sizeWordStack(BUF)
    rule #take(N, BUF1 ++ BUF2) => #take(N, BUF1)                                   requires N <=Int #sizeWordStack(BUF1)
    rule #take(N, BUF1 ++ BUF2) => BUF1 ++ #take(N -Int #sizeWordStack(BUF1), BUF2) requires N  >Int #sizeWordStack(BUF1)

    rule #drop(N, BUF)           => .WordStack                               requires #sizeWordStack(BUF) <=Int N
    rule #drop(N, #drop(M, BUF)) => #drop(N +Int M, BUF)
    rule #drop(N, BUF1 ++ BUF2)  => #drop(N -Int #sizeWordStack(BUF1), BUF2) requires N >=Int #sizeWordStack(BUF1)
    rule #drop(N, BUF1 ++ BUF2)  => #drop(N, BUF1) ++ BUF2                   requires N <Int #sizeWordStack(BUF1)

    rule #asWord(#buf(N, BUF)) => BUF

    rule #asWord(W0 : W1 : W2 : W3 : #take(28, BUF)) /Int 26959946667150639794667015087019630673637144422540572481103610249216 => #asWord(W0 : W1 : W2 : W3 : .WordStack)

    rule M [ N := BUF ] [ N := BUF' ] => M [ N := BUF' ] requires #sizeWordStack(BUF) ==Int #sizeWordStack(BUF')

    rule BUF:WordStack [ L .. W ] => .ByteArray requires W <=Int 0
    rule BUF           [ 0 .. W ] => BUF        requires W ==Int #sizeWordStack(BUF)
    rule BUF           [ L .. W ] => .ByteArray requires L  >Int #sizeWordStack(BUF)

    rule #range(M, N, K) => .ByteArray requires notBool K >Int 0

    rule #range(M [ N := BUF:WordStack ], L, K) => #range(M, L, minInt(K, N -Int L)) ++ #range(M [ N := BUF ], N, K -Int minInt(K, N -Int L))
      requires K >Int 0
       andBool L <Int N

    rule #range(M [ N := BUF ], L, K) => BUF [ L -Int N .. minInt(K, #sizeWordStack(BUF) -Int (L -Int N)) ] ++ #range(M, N +Int #sizeWordStack(BUF), K -Int minInt(K, #sizeWordStack(BUF) -Int (L -Int N)))
      requires K  >Int 0
       andBool L >=Int N
       andBool L  <Int N +Int #sizeWordStack(BUF)

    rule #range(M [ N := BUF ], L, K) => #range(M, L, K)
      requires K  >Int 0
       andBool L >=Int N +Int #sizeWordStack(BUF)

    rule keccak(BUF1 ++ BUF2) => hash2(#asWord(BUF1), #asWord(BUF2)) requires #sizeWordStack(BUF1) ==Int 32 andBool #sizeWordStack(BUF2) ==Int 32

  // ########################
  // Arithmetic
  // ########################

    rule A -Int B +Int B => A
    rule A +Int B -Int B => A
    rule A +Int B -Int A => B
    rule A +Int (B -Int A) => B

endmodule
