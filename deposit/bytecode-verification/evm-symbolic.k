requires "edsl.k"

module EVM-SYMBOLIC     [symbolic]
    imports EVM
    imports EDSL

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

endmodule
