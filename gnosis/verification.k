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
      requires START1 +Int WIDTH1 <=Int START0 +Int WIDTH0
        andBool 0 <Int WIDTH0
        andBool 0 <=Int WIDTH1

    rule #memoryUsageUpdate(#memoryUsageUpdate(MU, START0, WIDTH0), START1, WIDTH1) => #memoryUsageUpdate(MU, START1, WIDTH1)
      requires START0 +Int WIDTH0 <Int START1 +Int WIDTH1
        andBool 0 <=Int WIDTH0
        andBool 0 <Int WIDTH1

    rule 0 <=Int #memoryUsageUpdate(MU, START, WIDTH) => true


  // ########################
  // Gas
  // ########################

    rule 0 <=Int X -Int #gas(A, B, C)             => true  requires #gas(A, B, C) <=Int X
    rule         X -Int #gas(A, B, C) <Int pow256 => true  requires X <Int pow256

    rule #gas(A1, B1, C1) -Int #gas(A1, B2, C2) => (B2 +Int C2) -Int (B1 +Int C1)

    rule 0 <=Int #gas(_, _, _)             => true
    rule         #gas(_, _, _) <Int pow256 => true


  // ########################
  // Account Map
  // ########################

    syntax Int ::= "#MASTER_COPY_ID"  [function]
    syntax Int ::= "#PROXY_ID"        [function]
    syntax Int ::= "#ORIGIN_ID"       [function]
    syntax Int ::= "#REFUND_RECEIVER" [function]
    syntax Int ::= "#EXEC_ACCT_TO"    [function]

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

    rule 0 <=Int #EXEC_ACCT_TO             => true
    rule         #EXEC_ACCT_TO <Int pow160 => true
    rule         #EXEC_ACCT_TO <Int pow256 => true

    // address public constant SENTINEL_OWNERS  = address(0x1);
    // address public constant SENTINEL_MODULES = address(0x1);
    syntax Int ::= "#SENTINEL" [function]
    rule #SENTINEL => 1

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

    // storeRange

    rule storeRange(storeRange(M, K0, W0, V0), K1, W1, V1) => storeRange(M, K0, W0, V1)
      requires range(K0, W0) ==Range range(K1, W1)

    rule storeRange(storeRange(M, K0, W0, V0), K1, W1, V1) => storeRange(storeRange(M, K1, W1, V1), K0, W0, V0)
      requires range(K0, W0) <>Range range(K1, W1)
       andBool range(K1, W1) in keys(M)

    syntax Range ::= range(Int, Int)

    rule range(K1, W1) in keys(storeRange(M, K2, W2, _)) => true                     requires range(K1, W1) ==Range range(K2, W2)
    rule range(K1, W1) in keys(storeRange(M, K2, W2, _)) => range(K1, W1) in keys(M) requires range(K1, W1) <>Range range(K2, W2)

    syntax Bool ::= Range "==Range" Range [function]
                  | Range "<>Range" Range [function]

    rule range(K1, W1) ==Range range(K2, W2) => K1 ==Int K2 andBool W1 ==Int W2
    rule range(K1, W1) <>Range range(K2, W2) => K1 +Int W1 <=Int K2 orBool K2 +Int W2 <=Int K1


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

    rule #sizeWordStack(WS, N) <=Int SIZE => #sizeWordStack(WS, 0) +Int N <=Int SIZE requires N =/=Int 0

    rule #sizeWordStack(selectRange(_, _, WIDTH), SIZE) => SIZE +Int WIDTH

    rule #take(#sizeWordStack(WS, 0), WS) => WS


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
      requires 0 <=Int V andBool V <Int pow256 andBool #notKLabel(V, "#asWord")

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

    rule ((A +Int I1) +Int B) +Int I2 => (A +Int B) +Int (I1 +Int I2)
      requires notBool #isConcrete(A) andBool notBool #isConcrete(B) andBool #isConcrete(I1) andBool #isConcrete(I2)

    rule (A +Int I1) +Int (B +Int I2) => (A +Int B) +Int (I1 +Int I2)
      requires notBool #isConcrete(A) andBool notBool #isConcrete(B) andBool #isConcrete(I1) andBool #isConcrete(I2)

    rule (A +Int B) +Int (C -Int B) => A +Int C

    rule (A +Int B +Int C) -Int (A +Int D) => B +Int (C -Int D)

    rule (A +Int B +Int C +Int D +Int E) -Int (A +Int C +Int F) => B +Int D +Int E -Int F

    // Simplify Cmem(_,_) - Cmem(_, _)
    rule A +Int (I1 -Int A) => I1
    rule (I1 +Int (A -Int I0)) +Int (I2 -Int A) => I1 +Int (I2 -Int I0)

    // safeMath mul check c / a == b where c == a * b
    rule (X *Int Y) /Int X => Y  requires X =/=Int 0
    rule chop(X *Int Y) /Int X ==K Y => false  requires X =/=Int 0 andBool pow256 <=Int X *Int Y

    rule I1 *Int A +Int I2 *Int A => (I1 +Int I2) *Int A

    rule I1 *Int A +Int B +Int C +Int D +Int I2 *Int A => (I1 +Int I2) *Int A +Int B +Int C +Int D

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
  // Gnosis
  // ########################

   // checkSignatures is only called once in the executeTransaction, we implicitly assumed the arguments of the following functions
   // have additional arguments of checkSignatures.
    syntax Bool ::= "#enoughValidSigs"  [function]
 // ---------------------------------------------

    syntax Bool ::= "#checkSignaturesException" [function]
 // ------------------------------------------------------

    syntax Int ::= "#checkSigsGasNonMem"  [function]
 // ------------------------------------------------

    syntax Int ::= #checkSigsFinalMemUsed ( Int )  [function]  // previous memory used
 // ----------------------------------------------------------------------------------

   // Constant functions are ground terms in kprover. Constraints on the ground terms will not be considered when evaluating conditions only consisting of ground terms.
   // Thus, #checkSigsNextLoc has to take an argument and this argument should not be a constant.
    syntax Int ::= #checkSigsNextLoc ( Int )  [function]  // previous memory used
 // -----------------------------------------------------------------------------

    syntax Int ::= #loopGas ( Int , Int )  [function]  // startPC, endPC
 // --------------------------------------------------------------------

    syntax KItem ::= "#handlePaymentSpecApplied"
 // --------------------------------------------

syntax Int  ::= #fii        ( WordStack ,       Int , WordStack , IMap , Int ) [function, smtlib(fii)] // first-invalid-signature-index
syntax Bool ::= #isValid    ( WordStack , Int , Int , WordStack , IMap , Int , Bool ) [function, smtlib(isValid)]
syntax Bool ::= #isValidSig ( WordStack , Int , Int , WordStack , IMap , Int ) [function, smtlib(isValidSig)]
syntax Bool ::= #isValidSignature ( Int , WordStack , WordStack ) [function, smtlib(isValidSignature)] // ISignatureValidator(currentOwner).isValidSignature(data, contractSignature)
syntax Int  ::= #signer ( WordStack , Int , Int ) [function]
syntax Int  ::= #sigR   ( WordStack , Int ) [function]
syntax Int  ::= #sigS   ( WordStack , Int ) [function]
syntax Int  ::= #sigV   ( WordStack , Int ) [function]

rule 0 <=Int #fii(_,_,_,_,_)             => true
rule         #fii(_,_,_,_,_) <Int pow256 => true

/*
rule 0 <=Int #signer(_,_,_)             => true
rule         #signer(_,_,_) <Int pow160 => true
rule         #signer(_,_,_) <Int pow256 => true
*/

// axiomatization of #fii

rule #isValid(SIGS, I, DATA_HASH, DATA_BUF, STORAGE, MSG_SENDER, _) => true  requires I  <Int #fii(SIGS, DATA_HASH, DATA_BUF, STORAGE, MSG_SENDER)
rule #isValid(SIGS, I, DATA_HASH, DATA_BUF, STORAGE, MSG_SENDER, _) => false requires I ==Int #fii(SIGS, DATA_HASH, DATA_BUF, STORAGE, MSG_SENDER)

// axiomatization of #isValid

rule #isValid   (SIGS, I, DATA_HASH, DATA_BUF, STORAGE, MSG_SENDER, true)
  => #isValidSig(SIGS, I, DATA_HASH, DATA_BUF, STORAGE, MSG_SENDER)
     andBool #signer(SIGS, I, DATA_HASH) >Int #signer(SIGS, I -Int 1, DATA_HASH)
//   andBool select(STORAGE, #hashedLocation({COMPILER}, {OWNERS}, #signer(SIGS, I, DATA_HASH))) =/=Int 0
     andBool select(STORAGE, #hashedLocation("Solidity", 2,        #signer(SIGS, I, DATA_HASH))) =/=Int 0

rule #signer(_, I, _) => 0 requires I <Int 0  // address lastOwner = address(0);

// axiomatization of #isValidSig for each signature type

rule #isValidSig(SIGS, I, DATA_HASH, DATA_BUF, STORAGE, MSG_SENDER)
  => #isValidSignature(#signer(SIGS, I, DATA_HASH),                                                     // currentOwner
                       DATA_BUF,                                                                        // data
                       #bufSeg(SIGS, #sigS(SIGS,I) +Int 32, #asWord(#bufSeg(SIGS, #sigS(SIGS,I), 32)))) // contractSignature
  requires #sigV(SIGS, I) ==Int 0

rule #isValidSig(SIGS, I, DATA_HASH, DATA_BUF, STORAGE, MSG_SENDER)
  => MSG_SENDER ==Int #sigR(SIGS, I)
//   orBool select(STORAGE, #hashedLocation({COMPILER}, {APPROVED_HASHES}, #sigR(SIGS, I) DATA_HASH)) =/=Int 0
     orBool select(STORAGE, #hashedLocation("Solidity", 8,                 #sigR(SIGS, I) DATA_HASH)) =/=Int 0
  requires #sigV(SIGS, I) ==Int 1

/* in case the above doesn't work
rule #isValidSig(SIGS, I, DATA_HASH, DATA_BUF, STORAGE, MSG_SENDER) => true
  requires #sigV(SIGS, I) ==Int 1 andBool MSG_SENDER ==Int #sigR(SIGS, I)

rule #isValidSig(SIGS, I, DATA_HASH, DATA_BUF, STORAGE, MSG_SENDER)
//=> select(STORAGE, #hashedLocation({COMPILER}, {APPROVED_HASHES}, #sigR(SIGS, I) DATA_HASH)) =/=Int 0
  => select(STORAGE, #hashedLocation("Solidity", 8,                 #sigR(SIGS, I) DATA_HASH)) =/=Int 0
  requires #sigV(SIGS, I) ==Int 1 andBool MSG_SENDER =/=Int #sigR(SIGS, I)
*/

rule #isValidSig(SIGS, I, DATA_HASH, DATA_BUF, STORAGE, MSG_SENDER)
  => notBool #ecrecEmpty(#ecrecData(SIGS, I, DATA_HASH))
  requires #sigV(SIGS, I) =/=Int 0
   andBool #sigV(SIGS, I) =/=Int 1

// definition of #signer

rule #signer(SIGS, I, DATA_HASH) => #symEcrec(#ecrecData(SIGS, I, DATA_HASH)) requires I >=Int 0 andBool   #sigV(SIGS, I) =/=Int 0 andBool #sigV(SIGS, I) =/=Int 1   andBool notBool #ecrecEmpty(#ecrecData(SIGS, I, DATA_HASH))
rule #signer(SIGS, I, DATA_HASH) => 0                                         requires I >=Int 0 andBool   #sigV(SIGS, I) =/=Int 0 andBool #sigV(SIGS, I) =/=Int 1   andBool         #ecrecEmpty(#ecrecData(SIGS, I, DATA_HASH))
rule #signer(SIGS, I, DATA_HASH) => #sigR(SIGS, I)                            requires I >=Int 0 andBool ( #sigV(SIGS, I)  ==Int 0  orBool #sigV(SIGS, I)  ==Int 1 )

syntax WordStack ::= #ecrecData ( WordStack , Int , Int ) [function]
rule #ecrecData(SIGS, I, DATA_HASH) => #encodeArgs(#bytes32(DATA_HASH), #uint8(#sigV(SIGS,I)), #bytes32(#sigR(SIGS,I)), #bytes32(#sigS(SIGS,I)))

// definition of #sigR, #sigS, #sigV

rule #sigR(SIGS, I) => #asWord(#bufSeg(SIGS, 65 *Int I        , 32))
rule #sigS(SIGS, I) => #asWord(#bufSeg(SIGS, 65 *Int I +Int 32, 32))
rule #sigV(SIGS, I) =>         #bufElm(SIGS, 65 *Int I +Int 64)


endmodule
