requires "edsl.k"
requires "../lemmas.k"

module VERIFICATION
    imports EDSL
    imports LEMMAS

    rule #sizeWordStack ( WS , N:Int )
      => N +Int #sizeWordStack ( WS , 0 )
      requires N =/=K 0
      [lemma]

    //Rules for #padToWidth with non-regular symbolic arguments.
    rule #padToWidth(32, #asByteStack(V)) => #asByteStackInWidth(V, 32)
      requires 0 <=Int V andBool V <Int pow256 andBool #notKLabel(V, "#asWord")

    rule 0 <=Int (X modInt Y) => true
    rule (X modInt Y) >=Int 0 => true

    //for % operator on int128, failure case

    rule 0 -Int (A modInt B) => 0
        requires 0 <Int (A modInt B) ==K false

    //Required to rewrite the path condition, but K doesn't support this.
    //rule 0 <Int A modInt B ==K false => A modInt B ==K 0

    //Alternative to above, also unsupported by K because side condition uses vars that are not on LHS.
    //rule A &Int 1 => 1
    //    requires #rangeUInt(256, A)
    //     andBool ((A &Int (2 ^Int B)) ==K 0) ==K false
    //     andBool (0 ==K B) ==K false

    //lemmas for proc_reward.
    rule C:Bool andBool A <Int B => false
        requires chop( 1 &Int bool2Word ( A <Int B ) ) ==K 0

    rule C:Bool andBool A <Int B => C
        requires (chop( 1 &Int bool2Word ( A <Int B ) ) ==K 0) ==K false

    //lemmas for vote
    rule bool2Word(E) &Int 1 => bool2Word(E)
    rule 1 &Int bool2Word(E) => bool2Word(E)
    rule bool2Word(_) |Int 1 => 1
    rule 1 |Int bool2Word(_) => 1

    rule (X modInt Y) <Int Y  => true

    rule 0 <=Int 2 ^Int X => true

    rule 2 ^Int X <Int pow256 => true  requires X <Int 256

    rule 0 <=Int X &Int Y => true  requires 0 <=Int X andBool X <Int pow256
                                    andBool 0 <=Int Y andBool Y <Int pow256

    rule X &Int Y <Int pow256 => true  requires 0 <=Int X andBool X <Int pow256
                                        andBool 0 <=Int Y andBool Y <Int pow256

    rule 0 <=Int X |Int Y => true  requires 0 <=Int X andBool X <Int pow256
                                    andBool 0 <=Int Y andBool Y <Int pow256

    rule X |Int Y <Int pow256 => true  requires 0 <=Int X andBool X <Int pow256
                                        andBool 0 <=Int Y andBool Y <Int pow256

    rule A *Int VYPER_DEC_MULTIPLIER /Int B *Int C <Int pow256 => true
      requires 0 <=Int A andBool 0 <Int B andBool A <=Int B andBool C <=Int maxDecimal

    rule A *Int VYPER_DEC_MULTIPLIER /Int B *Int C <Int pow255 => true
      requires 0 <=Int A andBool 0 <Int B andBool A <=Int B andBool C <=Int maxDecimal

    rule A *Int VYPER_DEC_MULTIPLIER /Int B *Int C /Int VYPER_DEC_MULTIPLIER <Int pow256 => true
      requires 0 <=Int A andBool 0 <Int B andBool A <=Int B andBool C <=Int maxDecimal

    rule A *Int VYPER_DEC_MULTIPLIER /Int B *Int C /Int VYPER_DEC_MULTIPLIER <Int pow255 => true
      requires 0 <=Int A andBool 0 <Int B andBool A <=Int B andBool C <=Int maxDecimal

    rule A *Int VYPER_DEC_MULTIPLIER /Int B *Int C /Int VYPER_DEC_MULTIPLIER /Int 2 <Int pow256 => true
      requires 0 <=Int A andBool 0 <Int B andBool A <=Int B andBool C <=Int maxDecimal

    rule A *Int VYPER_DEC_MULTIPLIER /Int B *Int C /Int VYPER_DEC_MULTIPLIER /Int 2 <Int pow255 => true
      requires 0 <=Int A andBool 0 <Int B andBool A <=Int B andBool C <=Int maxDecimal

    rule A *Int VYPER_DEC_MULTIPLIER /Int B *Int C /Int VYPER_DEC_MULTIPLIER /Int 2 <=Int maxDecimal => true
      requires 0 <=Int A andBool 0 <Int B andBool A <=Int B andBool C <=Int maxDecimal

    rule 0 <=Int (A -Word B) => true

    rule (A -Word B) <Int pow256 => true

    rule (0 <=Int #blockhash(_, _, _, _)) => true

    rule (#blockhash(_, _, _, _) <Int pow256) => true

    syntax Int ::= symkeccak ( Int ) [function, smtlib(smt_symkeccak)]
 // -------------------------------------------------------------------
    rule keccak(WS) => symkeccak(#asWord(WS))  requires notBool #isConcrete(WS)

    rule 0 <=Int symkeccak(N) => true

    rule symkeccak(N) <Int pow256 => true

    rule   #signed(X) ==K   #signed(Y) => X ==K Y requires #rangeUInt(256,X) orBool #rangeUInt(256,Y)
    rule #unsigned(X) ==K #unsigned(Y) => X ==K Y requires #rangeSInt(256,X) orBool #rangeSInt(256,Y)


///////////////////////////////////////////////////////////////////////////////
// Arithmetic
///////////////////////////////////////////////////////////////////////////////


    rule N -Int N => 0

    rule 2 ^%Int X pow256 => 2 ^Int X  requires 0 <=Int X andBool X <Int 256

    rule ((X *Int Y) /Int Z) /Int Y => X /Int Z

    rule X modInt Y => X requires 0 <=Int X andBool X <Int Y

    syntax Int ::= "minInt128_2s"  [function]
                 | "minDecimal"    [function]
                 | "minDecimal_2s" [function]
                 | "maxDecimal"    [function]
 // ----------------------------------------
    rule minInt128_2s  => 115792089237316195423570985008687907853099843482180094807725896704197245534208  [macro]  /* pow256 - 2^127 */
    rule minDecimal    => -1701411834604692317316873037158841057280000000000  [macro]  /* (-2^127) * 10^10 */
    rule minDecimal_2s => 115792089237316195423570985006986496018665292348323691002298742950633129639936  [macro] /* pow256 - (2^127 * 10^10) */
    rule maxDecimal    => 1701411834604692317316873037158841057270000000000   [macro]  /* (2^127 - 1) * 10^10 */


    //Multiplication overflow check - success case
    // FIXME:(A *Int B /Int A ==Int B or A ==Int 0)
    rule chop(bool2Word((A *Int B) /Word A ==K B) |Int chop(A xorInt maxUInt256)) => 1
    //  requires A *Int B <=Int maxUInt256

    // FIXME:(A *Int B /Int A ==Int B or A ==Int 0)
    rule chop(bool2Word((A *Int B) /Int A ==K B) |Int chop(A xorInt maxUInt256)) => 1
    //  requires A *Int B <=Int maxUInt256

    rule chop(A *Int B) /Int A ==K B => true
      requires A >=Int 0 andBool B >=Int 0 andBool A =/=Int 0 andBool A *Int B <=Int maxSInt256

    rule A >Int maxUInt256 => true
      requires A >Int maxSInt256 andBool chop(A) <=Int maxSInt256

    /* Proof: If A*B results in overflow, A and B being non-negative, then
        A != 0 and B != 0, also:
        chop(A*B) != A*B   =>  chop(A*B)/A != A*B/A   =>   chop(A*B)/A != B.
    */
    rule chop(A *Int B) /Int A ==K B => false
      requires #range(0 <= A < maxSInt256) andBool #range(0 <= B < maxSInt256)
               andBool A *Int B >Int maxUInt256

    /* Proof:
        A>0 and B>0 and chop( A *Int B ) > maxSInt256
            => A *Int B > maxSInt256
            => [pow256 -Int chop( A *Int B ) <= maxSInt256] and [pow256 -Int chop( A *Int B ) != A * B]
        => [(pow256 -Int chop( A *Int B )) / A <= maxSInt256] and [(pow256 -Int chop( A *Int B )) / A != B]
            also [(pow256 -Int chop( A *Int B )) / A] >= 0, because all operations above produce non-negatives
            from non-negatives.
            Let's use: W1 = (pow256 -Int chop( A *Int B )) / A (for consistency with evm rules for -Word)

        next, 0 -Word (W1 <= maxSInt256) will evaluate into either:
            chop( pow256 -Int W1 ), when W1 > 0.
            0, when W1 == 0.
        Case W1 >0:
            W1 <= maxSInt256 => chop( pow256 -Int W1 ) > maxSInt256
            together with B < maxSInt256    => chop( pow256 -Int W1 ) != B. q.e.d.
        Case W1 == 0:
            suppose lemma is false. Then B = 0, but this is impossible because chop(A *Int B) >Int maxSInt256
            q.e.d.
    */
    rule 0 -Word ((pow256 -Int chop( A *Int B )) /Int A) ==K B => false
      requires #range(0 <= A < maxSInt256) andBool #range(0 <= B < maxSInt256)
               andBool chop(A *Int B) >Int maxSInt256

    //Reduntant 2 lemmas, but without them z3 does not finish when proving decimal multiplication failure-1 case.
    rule A *Int B /Int A ==K B => true
      requires A =/=Int 0

    //FIXME incorrect temp lemmas until Vyper compiler gets fixed.
    rule chop(A xorInt maxUInt256) => 1
      requires A ==Int 0

    rule chop(A xorInt maxUInt256) => 0
      requires A =/=Int 0
    // End of multiplication overflow lemmas

    // Required to solve -Word expressions, when subtraction result may be either positive or negative.
    rule maxDecimal s<Word (A -Word B) => bool2Word(false)
      requires  #rangeSFixed(128, 10, A -Int B)

    rule maxSInt256 s<Word (A -Word B) => bool2Word(false)
      requires  #rangeSInt(128, A -Int B)

    rule (A -Word B) s<Word minDecimal_2s => bool2Word(false)
      requires  #rangeSFixed(128, 10, A -Int B)

    rule (A -Word B) s<Word minInt128_2s => bool2Word(false)
      requires  #rangeSInt(128, A -Int B)
    //end of -Word lemmas

    rule 1 |Int chop(A xorInt maxUInt256) => 1

    rule C s<Word (A -Word B) => 0  requires 0 <=Int A andBool A <=Int maxSInt256
                                     andBool 0 <=Int B andBool B <=Int maxSInt256
                                     andBool 0 <=Int C andBool C <=Int maxSInt256
                                     andBool (A -Int B) <=Int C

//    rule maxSInt128 s<Word (A -Word B) => 0  requires 0 <=Int A andBool A <=Int maxSInt128
//                                              andBool 0 <=Int B andBool B <=Int maxSInt128


    rule (A -Word B) s<Word minInt128_2s => 0  requires 0 <=Int A andBool A <=Int maxSInt128
                                                andBool 0 <=Int B andBool B <=Int maxSInt128


    rule (#unsigned(A) -Word B) => #unsigned(A -Int B)  requires minSInt256 <=Int A andBool A <=Int maxSInt256
                                                         andBool          0 <=Int B andBool B <=Int maxSInt256
                                                         andBool minSInt256 <=Int (A -Int B)
                                                         andBool (A -Int B) <=Int maxSInt256

    rule C s<Word #unsigned(A -Int B) => 0  requires 0 <=Int C andBool C <=Int maxSInt256
                                             andBool minSInt256 <=Int (A -Int B)
                                             andBool (A -Int B) <=Int C

    rule #unsigned(A -Int B) s<Word minDecimal_2s => 0  requires minDecimal <=Int (A -Int B)
                                                         andBool (A -Int B) <=Int maxSInt256


///////////////////////////////////////////////////////////////////////////////
// Macros
///////////////////////////////////////////////////////////////////////////////


    syntax Int ::= "#expectedBlockNumber" "(" Int "," Int ")"  [function]
 // ---------------------------------------------------------------------
    rule #expectedBlockNumber(EPOCH, EPOCHLEN) => EPOCH *Int EPOCHLEN -Int 1


    syntax Int ::= "#recommendedBlockHash" "(" List "," Int "," Int "," Int ")"  [function]
 // ---------------------------------------------------------------------------------------
    rule #recommendedBlockHash(HASHES, BLOCKNUM, EPOCH, EPOCHLEN)
        => #blockhash(HASHES, #expectedBlockNumber(EPOCH, EPOCHLEN), BLOCKNUM -Int 1, 0)


    syntax Int ::= "#setVoteBit" "(" Int "," Int ")"  [function]
 // ------------------------------------------------------------
    rule #setVoteBit(BITVECTOR, VID) => BITVECTOR |Int (2 ^Int (VID modInt 256))



///////////////////////////////////////////////////////////////////////////////
// Predicates
///////////////////////////////////////////////////////////////////////////////


    syntax Bool ::= "#notVoteBefore" "(" Int "," Int ")"  [function]
 // ----------------------------------------------------------------
    rule #notVoteBefore(BITVECTOR, VID)
        => (BITVECTOR &Int (2 ^Int (VID modInt 256))) ==Int 0


    syntax Bool ::= "#inCurDynasty" "(" Int "," Int "," Int ")"  [function]
 // -----------------------------------------------------------------------
    rule #inCurDynasty(START, END, CUR) => (START <=Int CUR) andBool (CUR <Int END)


    syntax Bool ::= "#inPrevDynasty" "(" Int "," Int "," Int ")"  [function]
 // ------------------------------------------------------------------------
    rule #inPrevDynasty(START, END, CUR) => (START <=Int (CUR -Int 1)) andBool ((CUR -Int 1) <Int END)


    syntax Bool ::= "#isJustified" "(" Int "," Int "," Int "," Int ")"  [function]
 // ------------------------------------------------------------------------------
    rule #isJustified(CURDYNVOTES, CURDYNDEPOSITS, PREVDYNVOTES, PREVDYNDEPOSITS)
        => (CURDYNVOTES >=Int CURDYNDEPOSITS *Int 2 /Int 3) andBool (PREVDYNVOTES >=Int PREVDYNDEPOSITS *Int 2 /Int 3)

    syntax Int ::= "VYPER_DEC_MULTIPLIER"   [function]
 // ------------------------------------------------------------------------------
    rule VYPER_DEC_MULTIPLIER => 10000000000 [macro]

endmodule
