requires "edsl.k"
requires "../lemmas.k"

module VERIFICATION
    imports EDSL
    imports LEMMAS

    rule 0 <=Int (X modInt Y) => true

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


    // FIXME:(A *Int B /Int A ==Int B or A ==Int 0)
    rule chop(bool2Word((A *Int B) /Word A ==K B) |Int chop(A xorInt maxUInt256)) => 1
    //  requires A *Int B <=Int maxUInt256

    // FIXME:(A *Int B /Int A ==Int B or A ==Int 0)
    rule chop(bool2Word((A *Int B) /Int A ==K B) |Int chop(A xorInt maxUInt256)) => 1
    //  requires A *Int B <=Int maxUInt256

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

endmodule
