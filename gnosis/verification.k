requires "evm-symbolic.k"
requires "../lemmas.k"

module VERIFICATION
    imports EVM-SYMBOLIC
    imports EDSL
    imports LEMMAS

  // ########################
  // Gas
  // ########################

    // Temporary solution to avoid reasoning about gas
    syntax Int ::= "#infinity" [function]
 // -------------------------------------
    rule #infinity +Int _ => #infinity
    rule #infinity -Int _ => #infinity
    rule A <=Int #infinity => true
      requires #getKLabelString(A) =/=String "#infinity_VERIFICATION"
    rule #infinity <Int A => false
      requires #getKLabelString(A) =/=String "#infinity_VERIFICATION"

    rule minInt(#infinity, #infinity) => #infinity

  // ########################
  // Account Map
  // ########################

    syntax Int ::= "#MASTER_COPY_ID" [function]
    syntax Int ::= "#PROXY_ID" [function]
    syntax Int ::= "#ORIGIN_ID" [function]


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
      requires         notBool #isConcrete(hash2(A,B)) andBool #isConcrete(I)
               andBool I <Int 1000000000 //random small-ish number bigger than any fixed storage location

    rule I ==K hash2(A,B) => hash2(A,B) ==K I
      requires #isConcrete(I)

    rule hash2(A1,B1) ==K hash2(A2,B2) => A1 ==Int A2 andBool B1 ==Int B2

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


  // ########################
  // Range
  // ########################

    //todo should not be needed since #bufSeg(_,_,1) is converted to #bufElm
    rule #asWord(#bufSeg(_, _, WIDTH)) <Int 256 => true requires WIDTH ==Int 1

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

    rule 0 <=Int #bufElm(_, _)  => true
    rule #bufElm(_, _) <Int 256 => true

  // ########################
  // Simplification
  // ########################

    rule #padToWidth(32, #asByteStack(V)) => #buf(32, V) // #asByteStackInWidth(V, 32)
      requires 0 <=Int V andBool V <Int pow256

    rule #buf(32, #asWord(#bufSeg(BUF, START, WIDTH))) => #bufSeg(BUF, START +Int WIDTH -Int 32, 32)  requires WIDTH >=Int 32

    rule #asWord(#bufSeg(BUF, START, WIDTH)) &Int 255 => #asWord(#bufSeg(BUF, START +Int WIDTH -Int 1, 1))  requires WIDTH >=Int 1
    rule 255 &Int #asWord(#bufSeg(BUF, START, WIDTH)) => #asWord(#bufSeg(BUF, START +Int WIDTH -Int 1, 1))  requires WIDTH >=Int 1

    rule #bufSeg(BUF, START, 1) => #bufElm(BUF, START) : .WordStack

    rule #asWord(WS0 ++ #buf(MASKWIDTH0, 0)) |Int #asWord(#buf(MASKWIDHT1, 0) ++ WS1)
      => #asWord(WS0 ++ WS1)
      requires #sizeWordStack(WS0) +Int MASKWIDTH0 ==Int 32
       andBool #sizeWordStack(WS0) ==Int MASKWIDHT1
       andBool MASKWIDTH0 ==Int #sizeWordStack(WS1)

    // Arithmetic
    rule (A +Int I2) +Int (I3 -Int A) => I2 +Int I3
    rule (A +Int I2) -Int (A +Int I3) => I2 -Int I3
    rule (A +Int I2) -Int (I3 +Int A) => I2 -Int I3

    // TODO: move to builtin
    rule N -Int N => 0
      requires #getKLabelString(N) =/=String "#infinity_VERIFICATION"

    rule 2 ^%Int X pow256 => 2 ^Int X
      requires 0 <=Int X andBool X <Int 256

    rule X modInt Y => X
      requires 0 <=Int X andBool X <Int Y

    rule ((X *Int Y) /Int Z) /Int Y => X /Int Z
      requires Y =/=Int 0

    rule 1 |Int chop(A xorInt maxUInt256) => 1

    rule chop((ADDR &Int maxUInt160) modInt pow160) => ADDR
      requires #rangeAddress(ADDR)

    // 2^256 - 2^160 = 0xff..ff00..00 (96 1's followed by 160 0's)
    rule 115792089237316195423570985007226406215939081747436879206741300988257197096960 &Int ADDR => 0
      requires #rangeAddress(ADDR)

    // x &Int (NOT 31)
    rule X &Int 115792089237316195423570985008687907853269984665640564039457584007913129639904 => (X /Int 32) *Int 32  requires 0 <=Int X

    rule (X /Int 32) *Int 32 => X  requires X modInt 32 ==Int 0

    rule #ceil32(X) => X requires X modInt 32 ==Int 0

    rule #buf(32, #asWord(WS)) => WS  requires #sizeWordStack(WS) ==Int 32

    rule #buf(32, DATA) => #padToWidth(32, #asByteStack(DATA))  [concrete]

    // 0xff..ff00..00 (16 1's followed by 240 0's)
    rule 115790322390251417039241401711187164934754157181743688420499462401711837020160 &Int #asWord(WS1 ++ WS2)
        => #asWord(WS1 ++ #buf(30, 0))
      requires #sizeWordStack(WS1) ==Int 2
       andBool #sizeWordStack(WS2) ==Int 30

    // following lemmma is required for solidty 0.4.25
    rule (X *Int 32) +Int 192 ==K (Y *Int 32) +Int 160 => X +Int 1 ==K Y

    rule (X *Int 32) +Int 32 ==K Y *Int 32             => X +Int 1 ==K Y

    rule 192 ==K (X *Int 32) +Int 160                  => X ==K 1

    rule maxInt(maxInt(A, B), C) => maxInt(A, C)  requires B <=Int C

    rule (31 +Int X) /Int 32 *Int 32 => #ceil32(X)

    rule (X +Int 31) /Int 32 *Int 32 => #ceil32(X)

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

endmodule
