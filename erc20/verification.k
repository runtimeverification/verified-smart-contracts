requires "evm-symbolic.k"
requires "evm-data-map-symbolic.k"
requires "edsl.k"
requires "../lemmas-buf.k"

module VERIFICATION
    imports EVM-SYMBOLIC
    imports EVM-DATA-MAP-SYMBOLIC
    imports EDSL
    imports LEMMAS

    rule #buf(N, #asWord(WS)) => WS
      requires #noOverflow(WS) andBool N ==Int #sizeByteArray(WS)

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

    // #buf unfolding, for concrete DATA
    rule #buf(SIZE, DATA) => #padToWidth(SIZE, #asByteStack(DATA)) requires #range(0 <= DATA < (2 ^Int (SIZE *Int 8))) [concrete]

    // #buf folding, for symbolic DATA - todo test - might apply in too many places
    rule #padToWidth(SIZE, #asByteStack(DATA)) => #buf(SIZE, DATA) requires notBool #isConcrete(DATA)

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

    rule A ==K hash2(K,V) => hash2(K,V) ==K A
      requires #isConcrete(A)

    //Assumption of non-collision between hashes and small constants that likely represent memory addresses or offsets.
    rule notBool( hash2(_,_) ==K A ) => true
      requires #isConcrete(A) andBool A <=Int 20

  // ########################
  // Arithmetic
  // ########################

    rule A -Int B +Int B => A
    rule A +Int B -Int B => A
    rule A +Int B -Int A => B
    rule A +Int (B -Int A) => B

endmodule
