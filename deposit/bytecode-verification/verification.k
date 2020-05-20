requires "edsl.k"
requires "lemmas.k"

module VERIFICATION-L1
imports VERIFICATION

rule [node]:
     #node(I +Int 1, N, M) => #if 1 &Int #size(I, N) ==Int 1
                              #then #sha256(#buf(32, select(M, I)) ++ #buf(32, #node(I, N, M)))
                              #else #sha256(#buf(32, #node(I, N, M)) ++ #buf(32, select(M, 33 +Int I)))
                              #fi
requires 0 <=Int I andBool I <Int 32

rule [size]:
     #size(I +Int 1, N) => #size(I, N) /Int 2
requires 0 <=Int I andBool I <Int 32

endmodule

module VERIFICATION
    imports EVM
    imports EDSL
    imports LEMMAS

// function signature extraction
rule #asWord(B1 : B2 : B3 : B4 : WS) >>Int 224 => #asWord(B1 : B2 : B3 : B4 : .WordStack)
requires #sizeWordStack(WS) ==Int 28

// for to_little_endian_64()

// masking first 8 bits
rule 115339776388732929035197660848497720713218148788040405586178452820382218977280 &Int
     chop(X <<Int 248)
  => chop(X <<Int 248)
requires X >=Int 0

// masking first 64 bits
rule 115792089237316195417293883273301227089434195242432897623355228563449095127040 &Int
     #asWord(V0 : V1 : V2 : V3 : V4 : V5 : V6 : V7 : WS)
  => #asWord(V0 : V1 : V2 : V3 : V4 : V5 : V6 : V7 : WS)
requires WS ==K #buf(24, 0)
 andBool #rangeUInt(8, V0)
 andBool #rangeUInt(8, V1)
 andBool #rangeUInt(8, V2)
 andBool #rangeUInt(8, V3)
 andBool #rangeUInt(8, V4)
 andBool #rangeUInt(8, V5)
 andBool #rangeUInt(8, V6)
 andBool #rangeUInt(8, V7)

rule (chop(X <<Int 248) >>Int 248) modInt 256 => X
requires #rangeUInt(8, X)

rule (chop(X <<Int 192) >>Int 192) modInt 256 =>  X           modInt 256 requires X >=Int 0
rule (chop(X <<Int 192) >>Int 200) modInt 256 => (X >>Int  8) modInt 256 requires X >=Int 0
rule (chop(X <<Int 192) >>Int 208) modInt 256 => (X >>Int 16) modInt 256 requires X >=Int 0
rule (chop(X <<Int 192) >>Int 216) modInt 256 => (X >>Int 24) modInt 256 requires X >=Int 0
rule (chop(X <<Int 192) >>Int 224) modInt 256 => (X >>Int 32) modInt 256 requires X >=Int 0
rule (chop(X <<Int 192) >>Int 232) modInt 256 => (X >>Int 40) modInt 256 requires X >=Int 0
rule (chop(X <<Int 192) >>Int 240) modInt 256 => (X >>Int 48) modInt 256 requires X >=Int 0
rule (chop(X <<Int 192) >>Int 248) modInt 256 => (X >>Int 56) modInt 256 requires X >=Int 0

rule
selectRange(
    store(store(store(store(store(store(store(store(M,
        X0, V0),
        X1, V1),
        X2, V2),
        X3, V3),
        X4, V4),
        X5, V5),
        X6, V6),
        X7, V7),
    START, WIDTH)
=>
V0 : V1 : V2 : V3 : V4 : V5 : V6 : V7 : selectRange(M, START +Int 8, WIDTH -Int 8)
requires WIDTH >=Int 8
 andBool X0 ==Int START
 andBool X1 ==Int START +Int 1
 andBool X2 ==Int START +Int 2
 andBool X3 ==Int START +Int 3
 andBool X4 ==Int START +Int 4
 andBool X5 ==Int START +Int 5
 andBool X6 ==Int START +Int 6
 andBool X7 ==Int START +Int 7
 andBool #rangeUInt(8, V0)
 andBool #rangeUInt(8, V1)
 andBool #rangeUInt(8, V2)
 andBool #rangeUInt(8, V3)
 andBool #rangeUInt(8, V4)
 andBool #rangeUInt(8, V5)
 andBool #rangeUInt(8, V6)
 andBool #rangeUInt(8, V7)

// for get_deposit_root

rule (X +Int I) -Int X => I requires notBool #isConcrete(X) andBool #isConcrete(I)

rule (X +Int I1) -Int (X +Int I2) => I1 -Int I2 requires notBool #isConcrete(X) andBool #isConcrete(I1) andBool #isConcrete(I2)

rule X |Int Y => Y requires X ==Int 0

rule #bufSeg(V0 : V1 : V2 : V3 : V4 : V5 : V6 : V7 : _, 0, 8) => V0 : V1 : V2 : V3 : V4 : V5 : V6 : V7 : .WordStack

// masking first 64 bits
rule #asWord(V0 : V1 : V2 : V3 : V4 : V5 : V6 : V7 : WS) &Int 115792089237316195417293883273301227089434195242432897623355228563449095127040
  => #asWord(V0 : V1 : V2 : V3 : V4 : V5 : V6 : V7 : #buf(24, 0))
requires #sizeWordStack(WS) ==Int 24
 andBool #rangeUInt(8, V0)
 andBool #rangeUInt(8, V1)
 andBool #rangeUInt(8, V2)
 andBool #rangeUInt(8, V3)
 andBool #rangeUInt(8, V4)
 andBool #rangeUInt(8, V5)
 andBool #rangeUInt(8, V6)
 andBool #rangeUInt(8, V7)

syntax Int ::= #node(Int, Int, Map) [function, smtlib(nodeD)]
rule #node(0, _, _) => 0
/*
rule #node(I +Int 1, N, M) => #if 1 &Int #size(I, N) ==Int 1
                              #then #sha256(#buf(32, select(M, I)) ++ #buf(32, #node(I, N, M)))
                              #else #sha256(#buf(32, #node(I, N, M)) ++ #buf(32, select(M, 33 +Int I)))
                              #fi
requires 0 <=Int I andBool I <Int 32
*/

rule 0 <=Int #node(_, _, _)             => true
rule         #node(_, _, _) <Int pow256 => true

syntax Int ::= #size(Int, Int) [function, smtlib(sizeD)]
rule #size(0, N) => N
/*
rule #size(I +Int 1, N) => #size(I, N) /Int 2
requires 0 <=Int I andBool I <Int 32
*/

rule 0 <=Int #size(_, _)             => true
rule         #size(_, _) <Int pow256 => true

// to_little_endian_64

syntax Map ::= ".IMap" [function, smtlib(emptyIMap), smt-prelude]
rule select(.IMap, _) => 0
rule selectRange(.IMap, _, W) => #buf(W, 0) requires W >=Int 0

// deposit

// masking last 24 bytes
rule #bufSeg(#buf(32, #asWord(V0 : V1 : V2 : V3 : V4 : V5 : V6 : V7 : WS) |Int (X &Int 6277101735386680763835789423207666416102355444464034512895)), 0, 8)
  => V0 : V1 : V2 : V3 : V4 : V5 : V6 : V7 : .WordStack
requires WS ==K #buf(24, 0) // relaxed: #sizeWordStack(WS) ==Int 24
 andBool #rangeUInt(256, X)

rule 1 &Int X => X modInt 2 [concrete, smt-lemma]

rule isStorage(store(M, _, _)) => true
requires isStorage(M)



    // for [revert-invalid_function_identifier-0_4]

    rule #bufSeg(#buf(N, 0), 0, M) => #buf(M, 0) requires 0 <Int M andBool M <Int N

    // for [deposit-init-calldata]

    rule #take(X, #take(Y, WS)) => #take(X, WS)
      requires X <=Int Y

    // for addition overflow check

    rule X +Int Y <Int X => false requires X >=Int 0 andBool Y >=Int 0 // #range(0 <= (X +Int Y) < pow256)

    // for to_little_endian_64()

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

    // for zero-padding

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

    rule selectRange(store(store(store(store(store(store(store(store(store(store(store(store(store(store(store(store(M,
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
        K, W)
      => selectRange(storeRange(M, K1, 16, #buf(16, 0)), K, W)
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
       andBool #getKLabelString(M) =/=String "store"

endmodule
