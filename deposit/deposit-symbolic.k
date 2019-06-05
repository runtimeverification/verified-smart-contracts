require "deposit.k"

module DEPOSIT-SYMBOLIC

imports DEPOSIT

syntax Bool ::= isNat(Int) [function]
rule isNat(I) => I >=Int 0 [macro]

syntax Int ::= tn(Int, Int, Int) /* tn(m,l,i) := T_m(l,i)  */ [function, smtlib(tn)]
             | up(Int, Int)      /* up(k,x)   := \up^k x   */ [function, smtlib(up)]
             | down(Int, Int)    /* down(k,x) := \down^k x */ [function, smtlib(down)]

/*
 * By Equation 6. (\ref{eq:def:partial-merkle-tree})
 */
rule tn(M, 0, I) => 0  requires I >Int M
   andBool isNat(M) andBool isNat(I)
// andBool M <=Int 2 ^Int TREE_HEIGHT
// andBool I <=Int 2 ^Int TREE_HEIGHT

/*
 * By Equations 1 and 2. (\ref{eq:def:up}, \ref{eq:def:down})
 */
rule up(0, M) => M  requires true
   andBool isNat(M)

rule down(0, M) => M  requires true
   andBool isNat(M)

rule down(K, M) /Int 2 => down(K +Int 1, M)  requires true
   andBool isNat(K) andBool isNat(M)

rule up(H, M) => 1  requires M <=Int 2 ^Int H
   andBool isNat(H) andBool isNat(M)

/*
 * Lemma 8 (Contract Invariant).
 * isValidBranch(branch, m)
 * iff
 * for all k >= 0: branch[k] = T_m(k, \down^k m) if \down^k m is odd
 */
syntax Bool ::= isValidBranch(IMap, Int) [function, smtlib(isValidBranch)]

/*
 * Lemma 3. (\ref{lem:zero})
 * isValidZeros(zeros, m)
 * iff
 * for all k >= 0: zeros[k] = T_m(k, i) if i > \up^k m
 */
syntax Bool ::= isValidZeros(IMap, Int) [function, smtlib(isValidZeros)]

// Proof of Lemma 9 (get_deposit_root)

/*
 * By Lemma 8 (Contract Invariant).
 */
rule hash(Branch[K], tn(M, K, up(K, M +Int 1))) => tn(M, K +Int 1, up(K +Int 1, M +Int 1))
     requires isValidBranch(Branch, M)
      andBool down(K, M) %Int 2 ==Int 1
      andBool isNat(K) andBool isNat(M)
//    andBool K <Int TREE_HEIGHT
//    andBool M <Int 2 ^Int TREE_HEIGHT

/*
 * By Lemmas 3 and 8. (\ref{lem:zero}, \ref{lem:contract-invariant})
 */
rule hash(tn(M, K, up(K, M +Int 1)), Zeros[K])  => tn(M, K +Int 1, up(K +Int 1, M +Int 1))
     requires isValidZeros(Zeros, M)
      andBool down(K, M) %Int 2 =/=Int 1
      andBool isNat(K) andBool isNat(M)
//    andBool K <Int TREE_HEIGHT
//    andBool M <Int 2 ^Int TREE_HEIGHT

// Proof of Lemma 7 (deposit)

/*
 * By Equation 10, (\ref{eq:deposit:claim-lt-l})
 * By Lemmas 1 & 2 and Equation 28, (\ref{lem:up-down}, \ref{lem:difference}, \ref{eq:deposit:second-loop-invariant-value})
 * By Equations 16 & 10. (\ref{eq:deposit:pre-branch}, \ref{eq:deposit:claim-lt-l})
 */
rule hash(Branch[I], tn(M, I, down(I, M))) => tn(M, I +Int 1, down(I +Int 1, M))
     requires isValidBranch(Branch, M -Int 1)
      andBool down(I, M) %Int 2 =/=Int 1
      andBool (2 ^Int I) *Int down(I, M) ==Int M
      andBool isNat(I) andBool isNat(M)
//    andBool I <Int TREE_HEIGHT
//    andBool M <Int 2 ^Int TREE_HEIGHT

/*
 * By Lemma 5. (\ref{lem:two-chains})
 */
rule isValidBranch(B[I <- tn(M, I, down(I, M))], M) => true
     requires isValidBranch(B, M -Int 1)
      andBool (2 ^Int I) *Int down(I, M) ==Int M
      andBool down(I, M) %Int 2 ==Int 1
      andBool isNat(I) andBool isNat(M)
//    andBool I <Int TREE_HEIGHT
//    andBool M <Int 2 ^Int TREE_HEIGHT

rule isValidBranch(B[I <- tn(M, I, down(I, M))], M) => true
     requires isValidBranch(B, M -Int 1)
      andBool (2 ^Int I) *Int down(I, M) ==Int M
      andBool 1 <=Int M andBool M <Int 2 ^Int (I +Int 1)
      andBool isNat(I) andBool isNat(M)
//    andBool I <Int TREE_HEIGHT
//    andBool M <Int 2 ^Int TREE_HEIGHT

//rule down(K, M) => 1
//     requires M <Int 2 ^Int (K +Int 1)
//      andBool (2 ^Int K) *Int down(K, M) ==Int M
//      andBool M >Int 0

/*
 * By Equation 2. (\ref{eq:def:down})
 */
rule (2 ^Int (I +Int 1)) *Int down(I +Int 1, M) => M
     requires (2 ^Int I) *Int down(I, M) ==Int M
      andBool down(I, M) %Int 2 =/=Int 1
      andBool isNat(I) andBool isNat(M)
//    andBool I <Int TREE_HEIGHT
//    andBool M <Int 2 ^Int TREE_HEIGHT

endmodule
