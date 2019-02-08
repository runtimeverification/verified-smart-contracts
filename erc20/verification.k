requires "evm-symbolic.k"
requires "../lemmas.k"

module VERIFICATION
    imports EVM-SYMBOLIC
    imports EDSL
    imports LEMMAS

    rule #sizeWordStack ( WS , N:Int )
      => N +Int #sizeWordStack ( WS , 0 )
      requires N =/=K 0
      [lemma]

    rule #padToWidth(32, #asByteStack(V)) => #buf(32, V) // #asByteStackInWidth(V, 32)
      requires 0 <=Int V andBool V <Int pow256 andBool #notKLabel(V, "#asWord")

    rule chop ( W0:Int +Int W1:Int ) -Word W1:Int => chop ( W0 )
      requires #rangeUInt(256, W0) andBool #rangeUInt(256, W1)


  // ########################
  // Gas
  // ########################

    rule 0 <=Int X -Int #gas(A, B, C)             => true  requires #gas(A, B, C) <=Int X
    rule         X -Int #gas(A, B, C) <Int pow256 => true  requires X <Int pow256

    rule #gas(A1, B1, C1) -Int #gas(A1, B2, C2) => (B2 +Int C2) -Int (B1 +Int C1)

    rule 0 <=Int #gas(_, _, _)             => true
    rule         #gas(_, _, _) <Int pow256 => true


  // ########################
  // Buffer Reasoning
  // ########################

    rule #noOverflowAux(BUF) => true requires #isBuf(BUF)
    rule #noOverflowAux(WS1 ++ WS2) => #noOverflowAux(WS1) andBool #noOverflowAux(WS2)

    rule WS ++ .WordStack => WS

    rule #sizeWordStack(WS, N) <Int SIZE => #sizeWordStack(WS, 0) +Int N <Int SIZE  requires N =/=Int 0
    rule SIZELIMIT <Int #sizeWordStack(WS, N) +Int DELTA  => SIZELIMIT <Int (#sizeWordStack(WS, 0) +Int N) +Int DELTA  requires N =/=Int 0
    rule SIZELIMIT <Int #sizeWordStack(WS, N)             => SIZELIMIT <Int #sizeWordStack(WS, 0) +Int N               requires N =/=Int 0

    rule #sizeWordStack(WS, N) <=Int SIZE => #sizeWordStack(WS, 0) +Int N <=Int SIZE requires N =/=Int 0

    rule #bufSeg(BUF, 0, WIDTH) => BUF  requires WIDTH ==Int #sizeWordStack(BUF)


  // ########################
  // Memory Reasoning
  // ########################

    rule store(M, K, select(M, K)) => M

    syntax Bool ::= Map "==IMap" Map [function, smtlib(=)]
    syntax Bool ::= Map "==IMap" Map "except" Set [function]
 // --------------------------------------------------------
    rule store(M1, K, _) ==IMap M2 except Ks
      =>       M1        ==IMap M2 except Ks
      requires K in Ks

    rule M1 ==IMap store(M2, K, _) except Ks
      => M1 ==IMap       M2        except Ks
      requires K in Ks

    rule M1 ==IMap M2 except _ => true
      requires M1 ==K M2  // structural equality

    syntax Set ::= keys(Map) [function]
 // -----------------------------------
    rule K1 in keys(store(M, K2, _)) => true          requires K1  ==Int K2
    rule K1 in keys(store(M, K2, _)) => K1 in keys(M) requires K1 =/=Int K2

    //Reduces IMaps where multiple entries share the same key
    rule store(store(M, K0, V0), K1, V1) => store(M, K0, V1)
      requires K0 ==Int K1

    rule store(store(M, K0, V0), K1, V1) => store(store(M, K1, V1), K0, V0)
      requires K0 =/=Int K1 andBool K1 in keys(M)

    rule notBool( hash2(K1,V1) ==K hash2(K2,V2) ) => K1 =/=Int K2 orBool V1 =/=Int V2


  // ########################
  // Arithmetic
  // ########################

    rule A -Int B +Int B => A
    rule A +Int B -Int B => A

endmodule
