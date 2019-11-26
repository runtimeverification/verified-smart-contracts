requires "edsl.k"
requires "lemmas.k"

module VERIFICATION
    imports EVM
    imports EDSL
    imports LEMMAS

    rule W0 s<Word W1 => W0 <Word W1           requires sgn(W0) ==K 1  andBool sgn(W1) ==K 1
    rule W0 s<Word W1 => bool2Word(false)      requires sgn(W0) ==K 1  andBool sgn(W1) ==K -1
    rule W0 s<Word W1 => bool2Word(true)       requires sgn(W0) ==K -1 andBool sgn(W1) ==K 1
    rule W0 s<Word W1 => abs(W1) <Word abs(W0) requires sgn(W0) ==K -1 andBool sgn(W1) ==K -1

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
