require "deposit-symbolic.k"

module DEPOSIT-SPEC

imports DEPOSIT-SYMBOLIC

// Lemma 7 (deposit).

rule <k> deposit(V) => . ... </k>
     <depositCount> M => M +Int 1 </depositCount>
     <treeHeight> TREE_HEIGHT </treeHeight>
     <branch> Branch1 => Branch2 </branch>
     requires V ==Int tn(M +Int 1, 0, M +Int 1)
      andBool M <Int (2 ^Int TREE_HEIGHT) -Int 1
      andBool isNat(M) andBool isNat(TREE_HEIGHT)
      andBool TREE_HEIGHT >=Int 1
      andBool isValidBranch(Branch1, M)
     ensures  isValidBranch(Branch2, M +Int 1)

rule <k> depositLoop(I, TREE_HEIGHT -Int 1, down(I, M), tn(M, I, down(I, M))) => . ... </k>
     <depositCount> M </depositCount> // M = m + 1
     <treeHeight> TREE_HEIGHT </treeHeight>
     <branch> Branch1 => Branch2 </branch>
     requires I <=Int TREE_HEIGHT -Int 1
      andBool (2 ^Int I) *Int down(I, M) ==Int M
      andBool 1 <=Int M andBool M <Int 2 ^Int TREE_HEIGHT
      andBool isNat(I) andBool isNat(M) andBool isNat(TREE_HEIGHT)
      andBool TREE_HEIGHT >=Int 1
      andBool isValidBranch(Branch1, M -Int 1)
     ensures  isValidBranch(Branch2, M)

// Lemma 9 (get_deposit_root).

rule <k> getDepositRoot => tn(M, TREE_HEIGHT, 1) ... </k>
     <depositCount> M </depositCount>
     <treeHeight> TREE_HEIGHT </treeHeight>
     <branch> Branch </branch>
     <zerohashes> Zeros </zerohashes>
     requires M <Int 2 ^Int TREE_HEIGHT
      andBool isValidBranch(Branch, M)
      andBool isValidZeros(Zeros, M)
      andBool isNat(M) andBool isNat(TREE_HEIGHT)

rule <k> getDepositRootLoop(K, TREE_HEIGHT, down(K, M), tn(M, K, up(K, M +Int 1))) => tn(M, TREE_HEIGHT, 1) ... </k>
     <depositCount> M </depositCount>
     <treeHeight> TREE_HEIGHT </treeHeight>
     <branch> Branch </branch>
     <zerohashes> Zeros </zerohashes>
     requires K <=Int TREE_HEIGHT
      andBool M <Int 2 ^Int TREE_HEIGHT
      andBool isValidBranch(Branch, M)
      andBool isValidZeros(Zeros, M)
      andBool isNat(K) andBool isNat(M) andBool isNat(TREE_HEIGHT)

endmodule
