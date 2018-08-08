requires "edsl.k"
requires "../lemmas.k"

module VERIFICATION
    imports EDSL
    imports LEMMAS

 // some treatments for solidity bool variables
    syntax Bool ::= #rangeBool(Int)  [function]
                  | #isBoolWord(Int) [function, smtlib(isBoolWord)]

    rule #rangeBool(B) => #range(0 <= B <= 1) andBool #isBoolWord(B)
 // b != false -> b
    rule bool2Word(notBool(B ==K 0)) => B        requires #isBoolWord(B)
 // b != true  -> !b
    rule bool2Word(notBool(B ==K 1)) => 1 -Int B requires #isBoolWord(B)

 // SafeMath overflow check
    rule chop(A +Int B) <Int A => A +Int B >Int maxUInt256
      requires #rangeUInt(256, A) andBool #rangeUInt(256, B)

endmodule
