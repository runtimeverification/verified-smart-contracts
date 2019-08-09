requires "evm-symbolic.k"
requires "evm-data-map-symbolic.k"
requires "edsl.k"
requires "../lemmas.k"

module VERIFICATION
    imports EVM-SYMBOLIC
    imports EVM-DATA-MAP-SYMBOLIC
    imports EDSL
    imports LEMMAS

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


//  rule (X *Int 256 +Int Y) <Int (X *Int 256) => false requires #range(0 <= X < 256  ) andBool #range(0 <= Y < 256)
//  rule (X *Int 256 +Int Y) <Int (X *Int 256) => false requires #range(0 <= X < pow16) andBool #range(0 <= Y < 256)
//  rule (X *Int 256 +Int Y) <Int (X *Int 256) => false requires #range(0 <= X < pow24) andBool #range(0 <= Y < 256)
//  rule (X *Int 256 +Int Y) <Int (X *Int 256) => false requires #range(0 <= X < pow32) andBool #range(0 <= Y < 256)
//  rule (X *Int 256 +Int Y) <Int (X *Int 256) => false requires #range(0 <= X < pow40) andBool #range(0 <= Y < 256)
//  rule (X *Int 256 +Int Y) <Int (X *Int 256) => false requires #range(0 <= X < pow48) andBool #range(0 <= Y < 256)
//  rule (X *Int 256 +Int Y) <Int (X *Int 256) => false requires #range(0 <= X < pow56) andBool #range(0 <= Y < 256)




/*
    syntax Bool ::= #isConcreteItv(Int) [function]
    rule #isConcreteItv(X) => #isConcrete(X) orBool #getKLabelString(X) ==String "#itv"
*/

    syntax Int ::= #makeItv(Int, Int) [function]
    rule #makeItv(X1, X2) => #itv(X1, X2) requires X1  <Int X2 andBool #isConcrete(X1) andBool #isConcrete(X2)
    rule #makeItv(X1, X2) => X1           requires X1 ==Int X2 andBool #isConcrete(X1) andBool #isConcrete(X2)

    // interval abstraction -- both bounds must be concrete
    syntax Int ::= #itv(Int, Int) [function]

/*
    rule #itv(X1, X2) +Int #itv(Y1, Y2) => #makeItv(X1 +Int Y1, X2 +Int Y2)
    rule #itv(X1, X2) -Int #itv(Y1, Y2) => #makeItv(X1 -Int Y2, X2 -Int Y1)
    rule #itv(X1, X2) *Int #itv(Y1, Y2) => #makeItv(X1 *Int Y1, X2 *Int Y2)
    rule #itv(X1, X2) /Int #itv(Y1, Y2) => #makeItv(X1 /Int Y2, X2 /Int Y1)

    rule #itv(X1, X2) +Int Y => #makeItv(X1 +Int Y, X2 +Int Y)  requires #isConcrete(Y)
    rule #itv(X1, X2) -Int Y => #makeItv(X1 -Int Y, X2 -Int Y)  requires #isConcrete(Y)
    rule #itv(X1, X2) *Int Y => #makeItv(X1 *Int Y, X2 *Int Y)  requires #isConcrete(Y)
    rule #itv(X1, X2) /Int Y => #makeItv(X1 /Int Y, X2 /Int Y)  requires #isConcrete(Y)

    rule X +Int #itv(Y1, Y2) => #makeItv(X +Int Y1, X +Int Y2)  requires #isConcrete(X)
    rule X -Int #itv(Y1, Y2) => #makeItv(X -Int Y2, X -Int Y1)  requires #isConcrete(X)
    rule X *Int #itv(Y1, Y2) => #makeItv(X *Int Y1, X *Int Y2)  requires #isConcrete(X)
    rule X /Int #itv(Y1, Y2) => #makeItv(X /Int Y2, X /Int Y1)  requires #isConcrete(X)

    rule #itv(X1, X2)  <Int #itv(Y1, Y2) => true  requires X2  <Int Y1
    rule #itv(X1, X2)  <Int #itv(Y1, Y2) => false requires X1 >=Int Y2
    rule #itv(X1, X2) <=Int #itv(Y1, Y2) => true  requires X2 <=Int Y1
    rule #itv(X1, X2) <=Int #itv(Y1, Y2) => false requires X1  >Int Y2

    rule #itv(X1, X2)  <Int Y => true  requires X2  <Int Y // andBool #isConcrete(Y)
    rule #itv(X1, X2)  <Int Y => false requires X1 >=Int Y // andBool #isConcrete(Y)
    rule #itv(X1, X2) <=Int Y => true  requires X2 <=Int Y // andBool #isConcrete(Y)
    rule #itv(X1, X2) <=Int Y => false requires X1  >Int Y // andBool #isConcrete(Y)

    rule X  <Int #itv(Y1, Y2) => true  requires X  <Int Y1 // andBool #isConcrete(X)
    rule X  <Int #itv(Y1, Y2) => false requires X >=Int Y2 // andBool #isConcrete(X)
    rule X <=Int #itv(Y1, Y2) => true  requires X <=Int Y1 // andBool #isConcrete(X)
    rule X <=Int #itv(Y1, Y2) => false requires X  >Int Y2 // andBool #isConcrete(X)

    syntax Int ::= minItv(Int, Int) [function]
                 | maxItv(Int, Int) [function]

    rule minItv(#itv(X1, X2), #itv(Y1, Y2)) => #makeItv(minInt(X1, Y1), minInt(X2, Y2))
    rule maxItv(#itv(X1, X2), #itv(Y1, Y2)) => #makeItv(maxInt(X1, Y1), maxInt(X2, Y2))

    rule minItv(#itv(X1, X2), Y) => #makeItv(minInt(X1, Y), minInt(X2, Y))  requires #isConcrete(Y)
    rule maxItv(#itv(X1, X2), Y) => #makeItv(maxInt(X1, Y), maxInt(X2, Y))  requires #isConcrete(Y)

    rule minItv(X, #itv(Y1, Y2)) => #makeItv(minInt(X, Y1), minInt(X, Y2))  requires #isConcrete(X)
    rule maxItv(X, #itv(Y1, Y2)) => #makeItv(maxInt(X, Y1), maxInt(X, Y2))  requires #isConcrete(X)

    rule minItv(X, Y) => minInt(X, Y)  requires #isConcrete(X) andBool #isConcrete(Y)
    rule maxItv(X, Y) => maxInt(X, Y)  requires #isConcrete(X) andBool #isConcrete(Y)
*/


/*
    rule maxInt(maxInt(A, B), C) => maxInt(A, C)  requires C  >Int B
    rule maxInt(maxInt(A, B), C) => maxInt(A, B)  requires C <=Int B

    rule maxInt(A, B) => maxInt(B, A)  requires #isConcrete(A) andBool notBool #isConcrete(B)
    rule maxInt(maxInt(A, B), C) => maxInt(maxInt(A, C), B)  requires #isConcrete(B) andBool notBool #isConcrete(C)


// TODO: move to domains.k
  rule maxInt(I1:Int, I2:Int) => I1 requires I1 >=Int I2
  rule maxInt(I1:Int, I2:Int) => I2 requires I1 <=Int I2
*/


    syntax Int ::= #symGas(Int, Int, Int, List) [function]
    syntax Int ::= #symMem(Int, Set) [function]

    /* definition
    rule #symMem(N, S) => maxInt(N, maxIntSet(S)) up/Int 32

    rule #symGas(LB, UB, S) => #symGas(0, 0, .List) - [LB, UB] - sum(S) - Cmem(SCHED, MU)
        <memoryUsed> MU </memoryUsed>
    */


//  // no need to divide
//  rule #memoryUsageUpdate(MU, START, WIDTH) => maxInt(MU, START +Int WIDTH)
//      requires WIDTH >Int 0
//       andBool notBool (#isConcrete(MU) andBool #isConcrete(START) andBool #isConcrete(WIDTH))


    rule #memoryUsageUpdate(#symMem(MUC, MUS), START, WIDTH) => #symMem(maxInt(MUC, START +Int WIDTH), MUS)
        requires #isConcrete(MUC) andBool #isConcrete(START) andBool #isConcrete(WIDTH)

    rule #memoryUsageUpdate(#symMem(MUC, MUS), START, WIDTH) => #symMem(MUC, SetItem(START +Int WIDTH) MUS)
        requires notBool (#isConcrete(START) andBool #isConcrete(WIDTH))


    syntax Int ::= #gasUsageUpdate(Int, Int) [function]

    rule #gasUsageUpdate(#symGas(N, LB, UB, S), G) => #symGas(N +Int 1, LB +Int G, UB +Int G, S)
        requires #isConcrete(G)

    rule #gasUsageUpdate(#symGas(N, LB, UB, S), #itv(LB', UB')) => #symGas(N +Int 1, LB +Int LB', UB +Int UB', S)

    rule #gasUsageUpdate(#symGas(N, LB, UB, S), G) => #symGas(N +Int 1, LB, UB, S ListItem(G))
        requires (notBool #isConcrete(G)) andBool #getKLabelString(G) =/=String "#itv"



    rule Csstore(SCHED, NEW, CURR, ORIG) => #makeItv(Gsstorereset < SCHED >, Gsstoreset < SCHED >)
        requires #isConcrete(SCHED)
         andBool notBool ( #isConcrete(NEW) andBool #isConcrete(CURR) )
         andBool notBool Ghasdirtysstore << SCHED >>



  // ########################
  // Memory Reasoning
  // ########################

    // Merge
    rule storeRange(storeRange(M, MS0, MW0, #bufSeg(BUF, BS0, BW0)), MS1, MW1, #bufSeg(BUF, BS1, BW1))
        => storeRange(M, MS0, MW0 +Int MW1, #bufSeg(BUF, BS0, MW0 +Int MW1))
      requires #isBuf(BUF) andBool MW0 ==Int BW0 andBool MW1 ==Int BW1
       andBool MS1 ==Int MS0 +Int MW0 andBool BS1 ==Int BS0 +Int BW0

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

    rule #sizeWordStack(WS, N) <Int SIZE => #sizeWordStack(WS, 0) +Int N <Int SIZE  requires N =/=Int 0
    rule SIZELIMIT <Int #sizeWordStack(WS, N) +Int DELTA  => SIZELIMIT <Int (#sizeWordStack(WS, 0) +Int N) +Int DELTA  requires N =/=Int 0
    rule SIZELIMIT <Int #sizeWordStack(WS, N)             => SIZELIMIT <Int #sizeWordStack(WS, 0) +Int N               requires N =/=Int 0

    rule #sizeWordStack(WS, N) <=Int SIZE => #sizeWordStack(WS, 0) +Int N <=Int SIZE requires N =/=Int 0

    rule #sizeWordStack(selectRange(_, _, WIDTH), SIZE) => SIZE +Int WIDTH

    rule #take(#sizeWordStack(WS, 0), WS) => WS

    rule #bufSeg(BUF, N, WIDTH) => BUF requires WIDTH ==Int #sizeBuffer(BUF)

    rule selectRange(storeRange(M, START1, WIDTH1, BUF), START2, WIDTH2) => BUF
      requires START1 ==Int START2 andBool WIDTH1 ==Int WIDTH2

    rule selectRange(store(store(store(store(store(store(store(store(M, K1, 0), K2, 0), K3, 0), K4, 0), K5, 0), K6, 0), K7, 0), K8, 0), K, W)
      => selectRange(storeRange(M, K1, 8, #buf(8, 0)), K, W)
      requires K1 +Int 1 ==Int K2
       andBool K2 +Int 1 ==Int K3
       andBool K3 +Int 1 ==Int K4
       andBool K4 +Int 1 ==Int K5
       andBool K5 +Int 1 ==Int K6
       andBool K6 +Int 1 ==Int K7
       andBool K7 +Int 1 ==Int K8

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


  // ########################
  // Simplification
  // ########################

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
  // Arithmetic
  // ########################


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

endmodule
