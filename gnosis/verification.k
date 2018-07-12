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

    rule   #signed(X) ==K   #signed(Y) => X ==K Y requires #rangeUInt(256,X) orBool #rangeUInt(256,Y)
    rule #unsigned(X) ==K #unsigned(Y) => X ==K Y requires #rangeSInt(256,X) orBool #rangeSInt(256,Y)




    rule N -Int N => 0

    rule 2 ^%Int X pow256 => 2 ^Int X  requires 0 <=Int X andBool X <Int 256

    rule ((X *Int Y) /Int Z) /Int Y => X /Int Z

    rule X modInt Y => X requires 0 <=Int X andBool X <Int Y


    // TODO: needed?
    rule chop(A *Int B) /Int A ==K B => true
      requires A >=Int 0 andBool B >=Int 0 andBool A =/=Int 0 andBool A *Int B <=Int maxSInt256

    rule A >Int maxUInt256 => true
      requires A >Int maxSInt256 andBool chop(A) <=Int maxSInt256

    rule 1 |Int chop(A xorInt maxUInt256) => 1






/* [[1, 2], [3]] ->
     #array(
        #array(#uint256(_)),
        2,
        (#array(#uint256(_), 2, (#uint256(1), #uint256(2))),
         #array(#uint256(_), 1, #uint256(3))))
*/
//                              vvvvvvvv dummy for element type (empty array?)
    syntax TypedArg ::= #array ( TypedArg , Int , TypedArgs )

    rule #typeName(#array(T, _, _)) => #typeName(T) +String "[]"
    rule #lenOfHead(#array(_, _, _)) => 32
    rule #isStaticType(#array(_, _, _)) => false

    rule #sizeOfDynamicType(#array(T, N, _)) => 32 *Int (1 +Int N)
      requires #isStaticType(T)
    rule #sizeOfDynamicType(#array(T, N, ELEMS)) => 32 *Int (1 +Int N +Int #sizeOfDynamicTypes(ELEMS))
      requires notBool #isStaticType(T)                           //^ offsets

    syntax Int ::= #sizeOfDynamicTypes ( TypedArgs ) [function]
    rule #sizeOfDynamicTypes(E, Es) => #sizeOfDynamicType(E) +Int #sizeOfDynamicTypes(Es)
    rule #sizeOfDynamicTypes(.TypedArgs) => 0

    rule #enc(#array(_, N, DATA)) => #enc(#uint256(N)) ++ #encodeArgs(DATA)

    syntax TypedArg ::= #uint8 ( Int )
    rule #typeName(#uint8( _ )) => "uint8"
    rule #lenOfHead(#uint8( _ )) => 32
    rule #isStaticType(#uint8( _ )) => true
    rule #enc(#uint8( DATA )) => #padToWidth(32, #asByteStack(#getValue(#uint8( DATA ))))
    rule #getValue(#uint8( DATA )) => DATA
      requires 0 <=Int DATA andBool DATA <=Int 255

endmodule
