requires "edsl.k"
requires "evm-data-map-symbolic.k"

module VERIFICATION
    imports EVM
    imports EDSL
    imports EVM-DATA-MAP-SYMBOLIC


    syntax Int ::= #symGas(Int, Int, Int, List, Int) [function]
    syntax Int ::= #symMem(Int, Set) [function]

    syntax Int ::= Int "-Gas" Int [function]
    syntax Int ::= Int "+Gas" Int [function]

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

    syntax Int ::= #sha256 ( WordStack ) [function, smtlib(sha256)]
    rule 0 <=Int  #sha256(_)             => true
    rule          #sha256(_) <Int pow256 => true



    rule #sha256(DATA) => #asWord(#parseHexBytes(Sha256(#unparseByteStack(DATA)))) [concrete]

    // revert-invalid_function_identifier-0_4
    rule #bufSeg(#buf(N, 0), 0, M) => #buf(M, 0) requires 0 <Int M andBool M <Int N

    syntax Bool ::= isStorage(Map) [function]
    rule 0 <=Int select(M, _)             => true requires isStorage(M)
    rule         select(M, _) <Int pow256 => true requires isStorage(M)

    rule 0 <=Int select(M, _) +Int 1      => true requires isStorage(M)

    // for to_little_endian_64

    rule 0 <=Int X /Int Y             => true requires #range(0 <= X < pow256) andBool #range(0 <= Y < pow256)
    rule         X /Int Y <Int pow256 => true requires #range(0 <= X < pow256) andBool #range(0 <= Y < pow256)

    rule X &Int 255 <Int 256 => true requires #range(0 <= X < pow256)

    rule 0 <=Int X *Int 256                    => true requires #range(0 <= X < 256  )
    rule 0 <=Int X *Int 256                    => true requires #range(0 <= X < pow16)
    rule 0 <=Int X *Int 256                    => true requires #range(0 <= X < pow24)
    rule 0 <=Int X *Int 256                    => true requires #range(0 <= X < pow32)
    rule 0 <=Int X *Int 256                    => true requires #range(0 <= X < pow40)
    rule 0 <=Int X *Int 256                    => true requires #range(0 <= X < pow48)
    rule 0 <=Int X *Int 256                    => true requires #range(0 <= X < pow56)

    rule         X *Int 256        <Int pow16  => true requires #range(0 <= X < 256  )
    rule         X *Int 256        <Int pow24  => true requires #range(0 <= X < pow16)
    rule         X *Int 256        <Int pow32  => true requires #range(0 <= X < pow24)
    rule         X *Int 256        <Int pow40  => true requires #range(0 <= X < pow32)
    rule         X *Int 256        <Int pow48  => true requires #range(0 <= X < pow40)
    rule         X *Int 256        <Int pow56  => true requires #range(0 <= X < pow48)
    rule         X *Int 256        <Int pow64  => true requires #range(0 <= X < pow56)

    rule         X *Int 256        <Int pow256 => true requires #range(0 <= X < 256  )
    rule         X *Int 256        <Int pow256 => true requires #range(0 <= X < pow16)
    rule         X *Int 256        <Int pow256 => true requires #range(0 <= X < pow24)
    rule         X *Int 256        <Int pow256 => true requires #range(0 <= X < pow32)
    rule         X *Int 256        <Int pow256 => true requires #range(0 <= X < pow40)
    rule         X *Int 256        <Int pow256 => true requires #range(0 <= X < pow48)
    rule         X *Int 256        <Int pow256 => true requires #range(0 <= X < pow56)

    rule 0 <=Int X *Int 256 +Int Y             => true requires #range(0 <= X < 256  ) andBool #range(0 <= Y < 256)
    rule 0 <=Int X *Int 256 +Int Y             => true requires #range(0 <= X < pow16) andBool #range(0 <= Y < 256)
    rule 0 <=Int X *Int 256 +Int Y             => true requires #range(0 <= X < pow24) andBool #range(0 <= Y < 256)
    rule 0 <=Int X *Int 256 +Int Y             => true requires #range(0 <= X < pow32) andBool #range(0 <= Y < 256)
    rule 0 <=Int X *Int 256 +Int Y             => true requires #range(0 <= X < pow40) andBool #range(0 <= Y < 256)
    rule 0 <=Int X *Int 256 +Int Y             => true requires #range(0 <= X < pow48) andBool #range(0 <= Y < 256)
    rule 0 <=Int X *Int 256 +Int Y             => true requires #range(0 <= X < pow56) andBool #range(0 <= Y < 256)

    rule         X *Int 256 +Int Y <Int pow16  => true requires #range(0 <= X < 256  ) andBool #range(0 <= Y < 256)
    rule         X *Int 256 +Int Y <Int pow24  => true requires #range(0 <= X < pow16) andBool #range(0 <= Y < 256)
    rule         X *Int 256 +Int Y <Int pow32  => true requires #range(0 <= X < pow24) andBool #range(0 <= Y < 256)
    rule         X *Int 256 +Int Y <Int pow40  => true requires #range(0 <= X < pow32) andBool #range(0 <= Y < 256)
    rule         X *Int 256 +Int Y <Int pow48  => true requires #range(0 <= X < pow40) andBool #range(0 <= Y < 256)
    rule         X *Int 256 +Int Y <Int pow56  => true requires #range(0 <= X < pow48) andBool #range(0 <= Y < 256)
    rule         X *Int 256 +Int Y <Int pow64  => true requires #range(0 <= X < pow56) andBool #range(0 <= Y < 256)

    rule         X *Int 256 +Int Y <Int pow256 => true requires #range(0 <= X < 256  ) andBool #range(0 <= Y < 256)
    rule         X *Int 256 +Int Y <Int pow256 => true requires #range(0 <= X < pow16) andBool #range(0 <= Y < 256)
    rule         X *Int 256 +Int Y <Int pow256 => true requires #range(0 <= X < pow24) andBool #range(0 <= Y < 256)
    rule         X *Int 256 +Int Y <Int pow256 => true requires #range(0 <= X < pow32) andBool #range(0 <= Y < 256)
    rule         X *Int 256 +Int Y <Int pow256 => true requires #range(0 <= X < pow40) andBool #range(0 <= Y < 256)
    rule         X *Int 256 +Int Y <Int pow256 => true requires #range(0 <= X < pow48) andBool #range(0 <= Y < 256)
    rule         X *Int 256 +Int Y <Int pow256 => true requires #range(0 <= X < pow56) andBool #range(0 <= Y < 256)

    // for addition overflow check

    rule X +Int Y <Int X => false requires X >=Int 0 andBool Y >=Int 0 // #range(0 <= (X +Int Y) < pow256)


  // ########################
  // Gas Abstraction
  // ########################

    // see also abstract-semantics.k

    /* Definition
    rule #symGas(INIT, LB, UB, S, MU) => INIT - [LB, UB] - sum(S) - MU
    rule #symMem(N, S) => maxInt(N, maxIntSet(S)) up/Int 32
    */

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

    rule #symGas(X,                   LB,          UB,          ListItem(C) S, CMEM) +Gas #symGas(CGASCAP +Int CCALLSTIPEND, LB', UB', S', CMEM')
      => #symGas(X +Int CCALLSTIPEND, LB +Int LB', UB +Int UB', S'          S, CMEM) -Gas CMEM'
        requires C ==K CGASCAP

    //  Cs*

    rule Csstore(SCHED, NEW, CURR, ORIG) => #makeItv(Gsstorereset < SCHED >, Gsstoreset < SCHED >)
        requires #isConcrete(SCHED)
         andBool notBool ( #isConcrete(NEW) andBool #isConcrete(CURR) )
         andBool notBool Ghasdirtysstore << SCHED >>


  // ########################
  // Word <-> Bytes
  // ########################

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

//  rule #asWord( 0 : W1 : WS  =>  W1 : WS )
    rule #asWord( 0 :      WS  =>       WS )

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


  // ########################
  // Memory Reasoning
  // ########################

    // TODO: drop hash1 and keccakIntList once new vyper hashed location scheme is captured in edsl.md

    syntax Int ::= hash1(Int)      [function, smtlib(smt_hash1)]
                 | hash2(Int, Int) [function, smtlib(smt_hash2)]

    rule hash1(V) => keccak(#padToWidth(32, #asByteStack(V)))
      requires 0 <=Int V andBool V <Int pow256
      [concrete]

    rule hash2(V1, V2) => keccak(   #padToWidth(32, #asByteStack(V1))
                                 ++ #padToWidth(32, #asByteStack(V2)))
      requires 0 <=Int V1 andBool V1 <Int pow256
       andBool 0 <=Int V2 andBool V2 <Int pow256
      [concrete]

    rule keccakIntList(V:Int .IntList) => hash1(V)
    rule keccakIntList(V1:Int V2:Int .IntList) => hash2(V1, V2)

    // for terms came from bytecode not via #hashedLocation
    rule keccak(WS) => keccakIntList(byteStack2IntList(WS))
      requires ( notBool #isConcrete(WS) )
       andBool ( #sizeWordStack(WS) ==Int 32 orBool #sizeWordStack(WS) ==Int 64 )

/*
    // Merge
    rule storeRange(storeRange(M, MS0, MW0, #bufSeg(BUF, BS0, BW0)), MS1, MW1, #bufSeg(BUF, BS1, BW1))
        => storeRange(M, MS0, MW0 +Int MW1, #bufSeg(BUF, BS0, MW0 +Int MW1))
      requires #isBuf(BUF) andBool MW0 ==Int BW0 andBool MW1 ==Int BW1
       andBool MS1 ==Int MS0 +Int MW0 andBool BS1 ==Int BS0 +Int BW0
*/

    // select/store key equality

    rule hash2(A,B) ==K I => false
      requires #isConcrete(I)
       andBool I <Int 20 //random small-ish number bigger than any fixed storage location

    rule I ==K hash2(A,B) => hash2(A,B) ==K I
      requires #isConcrete(I)

    rule hash2(A1,B1) ==K hash2(A2,B2) => A1 ==Int A2 andBool B1 ==Int B2

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

    rule K1 in keys(store(M, K2, _)) => true          requires K1  ==Int K2
    rule K1 in keys(store(M, K2, _)) => K1 in keys(M) requires K1 =/=Int K2

    //Reduces symbolic Maps where multiple entries share the same key
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


  // ########################
  // Buffer Reasoning
  // ########################

    rule #noOverflowAux(BUF) => true requires #isBuf(BUF) orBool #isTake(BUF)
    rule #noOverflowAux(WS1 ++ WS2) => #noOverflowAux(WS1) andBool #noOverflowAux(WS2)

    rule #bufSeg(BUF, S0, W0) ++ #bufSeg(BUF, S1, W1) => #bufSeg(BUF, S0, W0 +Int W1)
      requires S1 ==Int S0 +Int W0

    rule #bufSeg(BUF, S0, W0) ++ (#bufSeg(BUF, S1, W1) ++ WS) => #bufSeg(BUF, S0, W0 +Int W1) ++ WS
      requires S1 ==Int S0 +Int W0

    rule WS ++ .WordStack => WS

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

    rule selectRange(store(store(store(store(store(store(store(store(store(store(store(store(store(store(store(store(store(store(store(store(store(store(store(store(M,
        K1 , 0),
        K2 , 0),
        K3 , 0),
        K4 , 0),
        K5 , 0),
        K6 , 0),
        K7 , 0),
        K8 , 0),
        K9 , 0),
        K10, 0),
        K11, 0),
        K12, 0),
        K13, 0),
        K14, 0),
        K15, 0),
        K16, 0),
        K17, 0),
        K18, 0),
        K19, 0),
        K20, 0),
        K21, 0),
        K22, 0),
        K23, 0),
        K24, 0),
        K, W)
      => selectRange(storeRange(M, K1, 24, #buf(24, 0)), K, W)
      requires K1  +Int 1 ==Int K2
       andBool K2  +Int 1 ==Int K3
       andBool K3  +Int 1 ==Int K4
       andBool K4  +Int 1 ==Int K5
       andBool K5  +Int 1 ==Int K6
       andBool K6  +Int 1 ==Int K7
       andBool K7  +Int 1 ==Int K8
       andBool K8  +Int 1 ==Int K9
       andBool K9  +Int 1 ==Int K10
       andBool K10 +Int 1 ==Int K11
       andBool K11 +Int 1 ==Int K12
       andBool K12 +Int 1 ==Int K13
       andBool K13 +Int 1 ==Int K14
       andBool K14 +Int 1 ==Int K15
       andBool K15 +Int 1 ==Int K16
       andBool K16 +Int 1 ==Int K17
       andBool K17 +Int 1 ==Int K18
       andBool K18 +Int 1 ==Int K19
       andBool K19 +Int 1 ==Int K20
       andBool K20 +Int 1 ==Int K21
       andBool K21 +Int 1 ==Int K22
       andBool K22 +Int 1 ==Int K23
       andBool K23 +Int 1 ==Int K24

    // for [deposit-init-calldata]
    rule #take(X, #take(Y, WS)) => #take(X, WS)
      requires X <=Int Y

  // ########################
  // Range
  // ########################

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

    rule 0 <=Int #bufElm(_, _)     => true
    rule #bufElm(_, _) <Int 256    => true
    rule #bufElm(_, _) <Int pow256 => true

    // X xorInt (pow256 - 1)
    rule 0 <=Int X xorInt 115792089237316195423570985008687907853269984665640564039457584007913129639935             => true  requires 0<=Int X andBool X <Int pow256
    rule         X xorInt 115792089237316195423570985008687907853269984665640564039457584007913129639935 <Int pow256 => true  requires 0<=Int X andBool X <Int pow256

    rule 0 <=Int nthbyteof(V, I, N)             => true
    rule         nthbyteof(V, I, N) <Int 256    => true
    rule         nthbyteof(V, I, N) <Int pow256 => true

    rule 0 <=Int #asWord(WS)             => true
    rule         #asWord(WS) <Int pow256 => true

    rule 0 <=Int hash1(_)             => true
    rule         hash1(_) <Int pow256 => true

    rule 0 <=Int hash2(_,_)             => true
    rule         hash2(_,_) <Int pow256 => true

    rule 0 <=Int chop(V)             => true
    rule         chop(V) <Int pow256 => true

    rule 0 <=Int keccak(V)             => true
    rule         keccak(V) <Int pow256 => true

    rule 0 <=Int keccakIntList(_)             => true
    rule         keccakIntList(_) <Int pow256 => true


  // ########################
  // Simplification
  // ########################

    syntax Bool ::= #notKLabel ( K , String ) [function]
    rule #notKLabel(T, L) => #getKLabelString(T) =/=String L orBool #isVariable(T)

    rule (X +Int 31) /Int 32 *Int 32 => #ceil32(X)
    rule (31 +Int X) /Int 32 *Int 32 => #ceil32(X)

    rule #asWord(#buf(32, DATA)) => DATA  requires #rangeUInt(256, DATA)

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

    // #asWord(WS) &Int (pow256 - 1)
    rule #asWord(WS) &Int 115792089237316195423570985008687907853269984665640564039457584007913129639935 => #asWord(WS)

    // 2^256 - 2^160 = 0xff..ff00..00 (96 1's followed by 160 0's)
    rule 115792089237316195423570985007226406215939081747436879206741300988257197096960 &Int ADDR => 0
      requires #rangeAddress(ADDR)

    rule chop((ADDR &Int maxUInt160) modInt pow160) => ADDR
      requires #rangeAddress(ADDR)


  // ########################
  // Normalization
  // ########################

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


  // ########################
  // Arithmetic
  // ########################

    rule N +Int 0 => N

    rule N -Int 0 => N

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

    // 0xffff...f &Int N = N
    rule MASK &Int N => N  requires MASK ==Int (2 ^Int (log2Int(MASK) +Int 1)) -Int 1 // MASK = 0xffff...f
                            andBool 0 <=Int N andBool N <=Int MASK

    // N &Int 0xffff...f = N
    rule N &Int MASK => N  requires MASK ==Int (2 ^Int (log2Int(MASK) +Int 1)) -Int 1 // MASK = 0xffff...f
                            andBool 0 <=Int N andBool N <=Int MASK

    rule chop(I) => I requires 0 <=Int I andBool I <Int pow256

    // safeMath mul check c / a == b where c == a * b
    rule (X *Int Y) /Int X => Y  requires X =/=Int 0
    rule chop(X *Int Y) /Int X ==K Y => false  requires X =/=Int 0 andBool pow256 <=Int X *Int Y

    // TODO: move to builtin
    rule N -Int N => 0

    rule 2 ^%Int X pow256 => 2 ^Int X
      requires 0 <=Int X andBool X <Int 256

    rule X modInt Y => X
      requires 0 <=Int X andBool X <Int Y

    rule ((X *Int Y) /Int Z) /Int Y => X /Int Z
      requires Y =/=Int 0

    // 0xff..ff00..00 (16 1's followed by 240 0's)
    rule 115790322390251417039241401711187164934754157181743688420499462401711837020160 &Int #asWord(WS1 ++ WS2)
        => #asWord(WS1 ++ #buf(30, 0))
      requires #sizeWordStack(WS1) ==Int 2
       andBool #sizeWordStack(WS2) ==Int 30

    // x &Int (NOT 31)
    rule X &Int 115792089237316195423570985008687907853269984665640564039457584007913129639904 => (X /Int 32) *Int 32  requires 0 <=Int X

    rule (X /Int 32) *Int 32 => X  requires X modInt 32 ==Int 0

    rule #ceil32(X) => X requires X modInt 32 ==Int 0

    rule X <=Int #ceil32(X) => true
      requires X >=Int 0


  // ########################
  // Booleans
  // ########################

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

    rule #asWord(0 : 0 : 0 : 0 : 0 : 0 : 0 : 0 : 0 : 0 : 0 : 0 : 0 : 0 : 0 : 0 : 0 : 0 : 0 : 0 : 0 : 0 : 0
                   : 0 : 0 : 0 : 0 : 0 : 0 : 0 : 0 : nthbyteof(bool2Word( E ), I, N) : .WordStack)
         => bool2Word( E )

endmodule
