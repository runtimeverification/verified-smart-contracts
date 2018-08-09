requires "edsl.k"
requires "../lemmas.k"

module VERIFICATION
    imports EDSL
    imports LEMMAS

 ///////////////////////////////////////////////////////////////////////////////
 /* #stWord, an abstraction for packed storage variables -------------------- */

    syntax Int ::= #stWord(IntList, IntList) [function, smtlib(stWord)]
 //                                    ^ length of each section
 // - listed in order of their declaration, that is, the first entry in #stWord
 //   starts from LSB of that word. FIXME: exchange the order?
 // - implicitly ignore left zero padding
 // e.g. Zilliqa ERC20 contract, #stWord with 3 sections:
 // (#hashedLocation({COMPILER}, 3, .IntList) |->
 //   #stWord(OWNER PAUSED_PUBLIC PAUSED_OWNER_ADMIN,
 //              20             1                  1)
 // where `address owner; bool pausedPublic; bool pausedOwnerAdmin;`
 // -> [0..0][PAUSED_OWNER_ADMIN][PAUSED_PUBLIC][OWNER]
 //        22                  21             20      0 LSB

    rule 0 <=Int #stWord(VS, _)             => true
    rule         #stWord(VS, _) <Int pow256 => true

/* Reading Packed Storage Variables ----------------------------------------- */
// 0. sload to get #stWord(..)
// 1. shift right #stWord(..)
// 2. take the lower bytes by [0..0]+[f..f] &Int #stWord(..)
// 3. then we get #stWord(V 0 .. 0 .IntList, _), and this will be interpreted
//    as an Int when applied to _Int operations
/* -------------------------------------------------------------------------- */

/* Updating Packed Storage Variables ---------------------------------------- */
// 0. sload to get #stWord(..)
// 1. erase corresponding section by [f..f]*[0..0][f..f]* &Int #stWord(..)
// 2. shift left the new value to fit in the section
// 3. [0..0]*[NEW_VALUE][0..0]* |Int #stWord(..)
//    ^^^^^^^^^^^^^^^^^^^^^^^^^ -> NEW_VALUE *Int (256 ^Int OFFSET)
/* -------------------------------------------------------------------------- */

 // shift right
    rule #stWord(V VS, L LS) /Int OFFSET_POW => #stWord(VS, LS) /Int (OFFSET_POW /Int (256 ^Int L))
      requires L <=Int log256Int(OFFSET_POW) andBool OFFSET_POW ==Int 256 ^Int log256Int(OFFSET_POW)
       andBool #isConcrete(OFFSET_POW)

    rule #stWord(VS, LS) /Int 1 => #stWord(VS, LS)

 // &Int
    rule M &Int #stWord(VS, LS) => #stWord(#int2IntList(M, LS) &IntList VS, LS)
 // NOTE: &Int on #stWord is used for: 1. reading, 2. erasing(resetting) a section
 // If your intention is reading, the result of M &Int #stWord(..) should be a
 // non-#stWord Int, while you want it to remain as #stWord when you are erasing
 // a section. The problem is that you cannot know the intention only by looking
 // at the mask in some cases. For example, let M = 0x00..00ff..ff. It is highly
 // likely that M is used to read a variable. However, M can also be used to
 // reset 2nd(upper bits) section of #stWord(..) consisting of 2 uint128 sections.
 // Because of this ambiguity, I deferred the conversion of #stWord into Int 
 // until the time we can confirm that it is an Int.

    syntax IntList ::= #int2IntList(Int, IntList) [function]
    rule #int2IntList(M, L LS) => (M modInt (256 ^Int L)) #int2IntList(M /Int (256 ^Int L), LS)
    rule #int2IntList(_, .IntList) => .IntList

    syntax IntList ::= IntList "&IntList" IntList [function]
    rule (L1 LS1) &IntList L2 LS2 => (L1 &Int L2) (LS1 &IntList LS2)
    rule .IntList &IntList .IntList => .IntList

 // |Int
 // FIXME: merge cases 1 and 2
 // 1. simbolic I, zero offset
    rule I |Int #stWord(0 VS, L LS) => #stWord(I VS, L LS)
      requires 0 <=Int I andBool I <=Int (256 ^Int L) -Int 1 andBool notBool #isConcrete(I)

 // 2. symbolic I, non zero offset
    rule (I *Int OFFSET_POW) |Int #stWord(VS, LS)
      => #stWord(#updateIntList(VS, I, log256Int(OFFSET_POW), LS), LS)
      requires OFFSET_POW ==Int 256 ^Int log256Int(OFFSET_POW)

    syntax IntList ::= #updateIntList(IntList, Int, Int, IntList) [function]
    rule #updateIntList(V VS, I, OFFSET, L LS) => V #updateIntList(VS, I, OFFSET -Int L, LS)
      requires OFFSET >Int 0
    rule #updateIntList(0 VS, I, 0, L LS) => I VS
      requires 0 <=Int I andBool I <=Int ((256 ^Int L) -Int 1)

 // 3.concrete I
    rule I |Int #stWord(VS, LS) => #stWord(#int2IntList(I, LS) |IntList VS, LS)
      requires #isConcrete(I)

    syntax IntList ::= IntList "|IntList" IntList [function]
    rule (L1 LS1) |IntList L2 LS2 => (L1 |Int L2) (LS1 |IntList LS2)
    rule .IntList |IntList .IntList => .IntList


 // #stWord with left zeros can be interpreted as an Int when needed
    rule #stWord(V VS, _) +Int   I => V +Int   I requires #zeroIntList(VS)
    rule #stWord(V VS, _) -Int   I => V -Int   I requires #zeroIntList(VS)
    rule #stWord(V VS, _) *Int   I => V *Int   I requires #zeroIntList(VS)
    rule #stWord(V VS, _) /Int   I => V /Int   I requires #zeroIntList(VS)  // TODO: vs shift right?
    rule #stWord(V VS, _) %Int   I => V %Int   I requires #zeroIntList(VS)
    rule #stWord(V VS, _) modInt I => V modInt I requires #zeroIntList(VS)
    rule #stWord(V VS, _) ==K    I => V ==K    I  andBool #zeroIntList(VS)
    rule I +Int   #stWord(V VS, _) => I +Int   V requires #zeroIntList(VS)
    rule I -Int   #stWord(V VS, _) => I -Int   V requires #zeroIntList(VS)
    rule I *Int   #stWord(V VS, _) => I *Int   V requires #zeroIntList(VS)
    rule I /Int   #stWord(V VS, _) => I /Int   V requires #zeroIntList(VS)
    rule I %Int   #stWord(V VS, _) => I %Int   V requires #zeroIntList(VS)
    rule I modInt #stWord(V VS, _) => I modInt V requires #zeroIntList(VS)
    rule I ==K    #stWord(V VS, _) => I ==K    V  andBool #zeroIntList(VS)
    // TODO: bitwise ops?

    syntax Bool ::= #zeroIntList(IntList) [function]
    rule #zeroIntList(.IntList) => true
    rule #zeroIntList(V VS) => V ==Int 0 andBool #zeroIntList(VS)

 /* End of #stWord rules  --------------------------------------------------- */
 ///////////////////////////////////////////////////////////////////////////////


 ///////////////////////////////////////////////////////////////////////////////
 /* Supplementary lemmas for #stWord ---------------------------------------- */

 // #stWord is just a simple abstracted representation for a bitvector of length
 // 256. That is one bitvector value can have multiple representation: #stWord,
 // an Int value, symbolic computation of Int values, and so on. For example,
 // chop(chop(bool2Word(notBool(notBool(notBool(B ==K 0)))) *Int (256 *Int 21)) |Int #stWord(I B' 0, 20 1 1))
 // must be equal to #stWord(I B' B, 20 1 1), and we want this equivalence check
 // to be automated by Z3. This requires SMTLib translation of all rules related
 // to #stWord, which will lead to a lot of complexity. Rather than doing so, I
 // used some ad-hoc lemmas so that equivalence can be checked simply by
 // AST matching.

    rule bool2Word(notBool(B ==K 0)) => B requires #rangeBool(B)

 // SafeMath overflow check
    rule chop(A +Int B) <Int A => A +Int B >Int maxUInt256
      requires #rangeUInt(256, A) andBool #rangeUInt(256, B)

 ///////////////////////////////////////////////////////////////////////////////

 // range definition for bool
    syntax Bool ::= #rangeBool(Int)  [function]
    rule #rangeBool(B) => #range(0 <= B <= 1) [macro]

endmodule
