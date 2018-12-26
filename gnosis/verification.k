requires "evm-symbolic.k"
requires "../lemmas.k"

module VERIFICATION
    imports EVM-SYMBOLIC
    imports EDSL
    imports LEMMAS

  // ########################
  // Memory Usage
  // ########################

    rule #memoryUsageUpdate(#memoryUsageUpdate(MU, START0, WIDTH0), START1, WIDTH1) => #memoryUsageUpdate(MU, START0, WIDTH0)
      requires START1 +Int WIDTH1 <Int START0 +Int WIDTH0
        andBool 0 <Int WIDTH0
        andBool 0 <Int WIDTH1

    rule #memoryUsageUpdate(#memoryUsageUpdate(MU, START0, WIDTH0), START1, WIDTH1) => #memoryUsageUpdate(MU, START1, WIDTH1)
      requires START0 +Int WIDTH0 <=Int START1 +Int WIDTH1
        andBool 0 <Int WIDTH0
        andBool 0 <Int WIDTH1

    rule 0 <=Int #memoryUsageUpdate(MU, START, WIDTH) => true


  // ########################
  // Gas
  // ########################

    rule 0 <=Int X -Int #gas(A, B, C)             => true  requires #gas(A, B, C) <=Int X
    rule         X -Int #gas(A, B, C) <Int pow256 => true  requires X <Int pow256


  // ########################
  // Account Map
  // ########################

    syntax Int ::= "#MASTER_COPY_ID"  [function]
    syntax Int ::= "#PROXY_ID"        [function]
    syntax Int ::= "#ORIGIN_ID"       [function]
    syntax Int ::= "#REFUND_RECEIVER" [function]

    rule 0 <=Int #MASTER_COPY_ID              => true
    rule         #MASTER_COPY_ID  <Int pow160 => true
    rule         #MASTER_COPY_ID  <Int pow256 => true

    rule 0 <=Int #PROXY_ID                    => true
    rule         #PROXY_ID        <Int pow160 => true
    rule         #PROXY_ID        <Int pow256 => true

    rule 0 <=Int #ORIGIN_ID                   => true
    rule         #ORIGIN_ID       <Int pow160 => true
    rule         #ORIGIN_ID       <Int pow256 => true

    rule 0 <=Int #REFUND_RECEIVER             => true
    rule         #REFUND_RECEIVER <Int pow160 => true
    rule         #REFUND_RECEIVER <Int pow256 => true


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

    syntax Bool ::= IMap "==IMap" IMap [function, smtlib(=)]

    syntax Bool ::= IMap "==IMap" IMap "except" Set [function]

    rule store(M1, K, _) ==IMap M2 except Ks
      =>       M1        ==IMap M2 except Ks
      requires K in Ks

    rule M1 ==IMap store(M2, K, _) except Ks
      => M1 ==IMap       M2        except Ks
      requires K in Ks

    rule M1 ==IMap M2 except _ => true
      requires M1 ==K M2  // structural equality

    syntax Set ::= keys(IMap) [function]

    rule K1 in keys(store(M, K2, _)) => true          requires K1  ==Int K2
    rule K1 in keys(store(M, K2, _)) => K1 in keys(M) requires K1 =/=Int K2

    //Reduces IMaps where multiple entries share the same key
    rule store(store(M, K0, V0), K1, V1) => store(M, K0, V1)
      requires K0 ==Int K1

    rule store(store(M, K0, V0), K1, V1) => store(store(M, K1, V1), K0, V0)
      requires K0 =/=Int K1 andBool K1 in keys(M)

  // ########################
  // Buffer Reasoning
  // ########################

    rule #noOverflowAux(BUF) => true requires #isBuf(BUF)
    rule #noOverflowAux(WS1 ++ WS2) => #noOverflowAux(WS1) andBool #noOverflowAux(WS2)

    rule #bufSeg(BUF, S0, W0) ++ #bufSeg(BUF, S1, W1) => #bufSeg(BUF, S0, W0 +Int W1)
      requires S1 ==Int S0 +Int W0

    rule #bufSeg(BUF, S0, W0) ++ (#bufSeg(BUF, S1, W1) ++ WS) => #bufSeg(BUF, S0, W0 +Int W1) ++ WS
      requires S1 ==Int S0 +Int W0

    rule WS ++ .WordStack => WS

    rule #sizeWordStack(WS, N) <Int SIZE => #sizeWordStack(WS, 0) +Int N <Int SIZE  requires N =/=Int 0
    rule SIZELIMIT <Int #sizeWordStack(WS, N) +Int DELTA  => SIZELIMIT <Int (#sizeWordStack(WS, 0) +Int N) +Int DELTA  requires N =/=Int 0
    rule SIZELIMIT <Int #sizeWordStack(WS, N)             => SIZELIMIT <Int #sizeWordStack(WS, 0) +Int N               requires N =/=Int 0

    rule #sizeWordStack(selectRange(_, _, WIDTH), SIZE) => SIZE +Int WIDTH


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

    //case 0 is never wrapped into #symEcrec(), corresponds to #ecrecEmpty(DATA) == true
    rule 0 <Int   #symEcrec(DATA)             => true

    //that's because the result in concrete semantics is trimmed to Address range.
    rule          #symEcrec(DATA) <Int pow160 => true

    // Lemmas implied by the above, but still required to match side conditions of #padToWidth rule in lemmas.md
    // General range conversion lemmas like below are not an option, dramatic performance decrease:
    //    rule A < pow256 => true requires A < pow160
    rule 0 <=Int  #symEcrec(DATA)             => true
    rule          #symEcrec(DATA) <Int pow256 => true

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
      requires 0 <=Int V andBool V <Int pow256 andBool #getKLabelString(V) =/=String "#asWord"

    rule #buf(32, #asWord(WS)) => WS  requires #sizeWordStack(WS) ==Int 32
    rule #buf(32, #asWord(#bufSeg(BUF, START, WIDTH))) => #bufSeg(BUF, START +Int WIDTH -Int 32, 32)  requires WIDTH >=Int 32

    rule #asWord(#bufSeg(BUF, START, WIDTH)) &Int 255 => #asWord(#bufSeg(BUF, START +Int WIDTH -Int 1, 1))  requires WIDTH >=Int 1
    rule 255 &Int #asWord(#bufSeg(BUF, START, WIDTH)) => #asWord(#bufSeg(BUF, START +Int WIDTH -Int 1, 1))  requires WIDTH >=Int 1

    rule #bufSeg(BUF, START, 1) => #bufElm(BUF, START) : .WordStack
    rule #asWord(#bufElm(BUF, INDEX) : .WordStack) => #bufElm(BUF, INDEX)

    rule #buf(32, DATA) => #padToWidth(32, #asByteStack(DATA))  [concrete]

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

    rule (A +Int I2) +Int (I3 -Int A) => I2 +Int I3
    rule (A +Int I2) -Int (A +Int I3) => I2 -Int I3
    rule (A +Int I2) -Int (I3 +Int A) => I2 -Int I3

    rule (I1 +Int I2) -Int (I3 +Int I1) => I2 -Int I3

    rule A -Int (A -Int I1) => I1

    rule (A +Int I1) -Int A => I1

    rule ((A +Int I1) +Int B) +Int I2 => (A +Int B) +Int (I1 +Int I2)  requires #isConcrete(I1) andBool #isConcrete(I2)

    // Simplify Cmem(_,_) - Cmem(_, _)
    rule A +Int (I1 -Int A) => I1
    rule (I1 +Int (A -Int I0)) +Int (I2 -Int A) => I1 +Int (I2 -Int I0)

    // safeMath mul check c / a == b where c == a * b
    rule (X *Int Y) /Int X => Y  requires X =/=Int 0
    rule chop(X *Int Y) /Int X ==K Y => false  requires X =/=Int 0 andBool pow256 <=Int X *Int Y

    // TODO: move to builtin
    rule N -Int N => 0
      requires #getKLabelString(N) =/=String "#infinity_VERIFICATION"

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

endmodule
