require "imap.k"

module DEPOSIT-SYNTAX

imports INT-SYNTAX

// libraries
syntax Int ::= hash(Int, Int) [function, smtlib(hash)]

// functions
syntax Cmd ::= "initConfig"     | initConfigLoop(Int, Int)
             | "init"           | initLoop(Int, Int)
             | "deposit" Int    | depositLoop(Int, Int, Int, Int)
             | "getDepositRoot" | getDepositRootLoop(Int, Int, Int, Int)

// program
syntax Cmds ::= Cmd Cmds | Cmd
rule C:Cmd Cs:Cmds => C ~> Cs

endmodule

module DEPOSIT

imports DEPOSIT-SYNTAX
imports INT
imports IMAP

/*
 * zerohashes: int[TREE_HEIGHT] = \{0\} # zero array
 * branch:     int[TREE_HEIGHT] = \{0\} # zero array
 * deposit_count: int = 0  # max: 2^TREE_HEIGHT - 1
 */

configuration <T>
  <k> initConfig ~> init ~> $PGM:Cmds </k>
  <zerohashes> .IMap </zerohashes>
  <branch>     .IMap </branch>
  <depositCount> 0 </depositCount>
  <treeHeight> $TREEHEIGHT:Int </treeHeight>
</T>

rule <k> initConfig => initConfigLoop(0, TREE_HEIGHT) ... </k>
     <treeHeight> TREE_HEIGHT </treeHeight>

rule <k> initConfigLoop(I, N) => initConfigLoop(I +Int 1, N) ... </k>
     <zerohashes> Z => Z[I <- 0] </zerohashes>
     <branch>     B => B[I <- 0] </branch>
     requires I <Int N

rule initConfigLoop(I, N) => . requires I >=Int N


/*
 * fun init() -> unit:
 *     i: int = 0
 *     while i < TREE_HEIGHT - 1:
 *         zerohashes[i+1] = hash(zerohashes[i], zerohashes[i])
 *         i += 1
 */

rule <k> init => initLoop(0, TREE_HEIGHT -Int 1) ... </k>
     <treeHeight> TREE_HEIGHT </treeHeight>

rule <k> initLoop(I,        N)
      => initLoop(I +Int 1, N) ...</k>
     <zerohashes> Z => Z[I +Int 1 <- hash(Z[I], Z[I])] </zerohashes>
     requires I <Int N

rule initLoop(I, N) => . requires I >=Int N


/*
 * fun deposit(value: int) -> unit:
 *     assert deposit_count < 2^TREE_HEIGHT - 1
 *     deposit_count += 1
 *     size: int = deposit_count
 *     i: int = 0
 *     while i < TREE_HEIGHT - 1:
 *         if size % 2 == 1:
 *             break
 *         value = hash(branch[i], value)
 *         size /= 2
 *         i += 1
 *     branch[i] = value
 */

rule <k> deposit(V) => depositLoop(0, TREE_HEIGHT -Int 1, DC +Int 1, V) ... </k>
     <depositCount> DC => DC +Int 1 </depositCount>
     <treeHeight> TREE_HEIGHT </treeHeight>
     requires DC <Int (2 ^Int TREE_HEIGHT -Int 1)  // maximum # of deposits is (2^TREE_HEIGHT - 1)

rule <k> depositLoop(I,        N, Size,        Value)
      => depositLoop(I +Int 1, N, Size /Int 2, hash(B[I], Value)) ... </k>
     <branch> B </branch>
     requires I <Int N
      andBool Size %Int 2 =/=Int 1

rule <k> depositLoop(I, N, Size, Value) => . ... </k>
     <branch> B => B[I <- Value] </branch>
     requires I <Int N
      andBool Size %Int 2 ==Int 1

rule <k> depositLoop(I, N, Size, Value) => . ... </k>
     <branch> B => B[I <- Value] </branch>
     requires I >=Int N
//     orBool Size %Int 2 ==Int 1


/*
 * fun get_deposit_root() -> int:
 *     root: int = 0
 *     size: int = deposit_count
 *     h: int = 0
 *     while h < TREE_HEIGHT:
 *         if size % 2 == 1: # size is odd
 *             root = hash(branch[h], root)
 *         else:             # size is even
 *             root = hash(root, zerohashes[h])
 *         size /= 2
 *         h += 1
 *     return root
 */

rule <k> getDepositRoot => getDepositRootLoop(0, TREE_HEIGHT, DepositCount, 0) ... </k>
     <depositCount> DepositCount </depositCount>
     <treeHeight> TREE_HEIGHT </treeHeight>

rule <k> getDepositRootLoop(H,        N, Size,        Root)
      => getDepositRootLoop(H +Int 1, N, Size /Int 2, hash(B[H], Root)) ... </k>
     <branch> B </branch>
     requires H <Int N
      andBool Size %Int 2 ==Int 1

rule <k> getDepositRootLoop(H,        N, Size,        Root)
      => getDepositRootLoop(H +Int 1, N, Size /Int 2, hash(Root, Z[H])) ... </k>
     <zerohashes> Z </zerohashes>
     requires H <Int N
      andBool Size %Int 2 =/=Int 1

rule getDepositRootLoop(H, N, _, Root) => Root
     requires H >=Int N

endmodule
