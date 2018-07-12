requires "edsl.k"
requires "../lemmas.k"

module VERIFICATION
    imports EDSL
    imports LEMMAS


    rule chop((ADDR &Int maxUInt160) modInt pow160) => ADDR
      requires #rangeAddress(ADDR)

    rule 115792089237316195423570985007226406215939081747436879206741300988257197096960 &Int ADDR => 0
      requires #rangeAddress(ADDR)





    // TODO: true even if Y < 0 ?
    rule 0 <=Int (X modInt Y)        => true
    rule         (X modInt Y) <Int Y => true

    rule 0 <=Int 2 ^Int X             => true
    rule         2 ^Int X <Int pow256 => true  requires X <Int 256

    // TODO: use #range notation
    rule 0 <=Int X &Int Y             => true  requires 0 <=Int X andBool X <Int pow256 andBool 0 <=Int Y andBool Y <Int pow256
    rule         X &Int Y <Int pow256 => true  requires 0 <=Int X andBool X <Int pow256 andBool 0 <=Int Y andBool Y <Int pow256

    rule 0 <=Int X |Int Y             => true  requires 0 <=Int X andBool X <Int pow256 andBool 0 <=Int Y andBool Y <Int pow256
    rule         X |Int Y <Int pow256 => true  requires 0 <=Int X andBool X <Int pow256 andBool 0 <=Int Y andBool Y <Int pow256

    rule 0 <=Int #blockhash(_, _, _, _)             => true
    rule         #blockhash(_, _, _, _) <Int pow256 => true







    syntax Int ::= symkeccak ( Int ) [function, smtlib(smt_symkeccak)]
 // -------------------------------------------------------------------
    rule keccak(WS) => symkeccak(#asWord(WS))  requires notBool #isConcrete(WS)

    rule 0 <=Int symkeccak(N) => true

    rule symkeccak(N) <Int pow256 => true

    rule symkeccak(N) <=Int maxUInt256 => true

 // rule   #signed(X) ==K   #signed(Y) => X ==K Y requires #rangeUInt(256,X) orBool #rangeUInt(256,Y)
 // rule #unsigned(X) ==K #unsigned(Y) => X ==K Y requires #rangeSInt(256,X) orBool #rangeSInt(256,Y)




    rule N -Int N => 0

    rule 2 ^%Int X pow256 => 2 ^Int X  requires 0 <=Int X andBool X <Int 256

    rule ((X *Int Y) /Int Z) /Int Y => X /Int Z

    rule X modInt Y => X requires 0 <=Int X andBool X <Int Y


    rule 1 |Int chop(A xorInt maxUInt256) => 1






/* [[1, 2], [3]] ->
     #array(
        #array(#uint256(_)),
        2,
        (#array(#uint256(_), 2, (#uint256(1), #uint256(2))),
         #array(#uint256(_), 1, #uint256(3))))
*/

endmodule
