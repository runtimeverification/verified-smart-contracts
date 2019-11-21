
    //////////////////////////
    // Macros
    //////////////////////////

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

    syntax Bool ::= #notKLabel ( K , String ) [function]
    rule #notKLabel(T, L) => #getKLabelString(T) =/=String L orBool #isVariable(T)

    // normalization

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

