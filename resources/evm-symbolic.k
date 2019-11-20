requires "edsl.k"

module EVM-SYMBOLIC     [symbolic]
    imports EVM
    imports EDSL

    syntax Int ::= #symGas(Int, Int, Int, List, Int) [function]
    syntax Int ::= #symMem(Int, Set) [function]

    syntax Int ::= Int "-Gas" Int [function]
    syntax Int ::= Int "+Gas" Int [function]

    syntax Int ::= "pow24"
                 | "pow32"
                 | "pow40"
                 | "pow48"
                 | "pow56"
                 | "pow64"
    rule pow24 => 16777216                  [macro]
    rule pow32 => 4294967296                [macro]
    rule pow40 => 1099511627776             [macro]
    rule pow48 => 281474976710656           [macro]
    rule pow56 => 72057594037927936         [macro]
    rule pow64 => 18446744073709551616      [macro]

    syntax Bool ::= #regularAddress(Schedule, Int)
    rule #regularAddress(SCHEDULE, X) => X >Int 0 andBool (notBool X in #precompiledAccounts(SCHEDULE))  [macro]

  // ########################
  // Ecrecover
  // todo move to ecrec-symbolic.k when K supports it.
  // ########################

    //Symbolic wrapper over the argument of #ecrec, no implementation.
    syntax Int ::= #symEcrec ( WordStack )   [function]

    //Symbolic predicate representing whether output of #ecrec is empty. No implementation.
    syntax Bool ::= #ecrecEmpty( WordStack ) [function]

    // Range for #symEcrec

    //case 0 is never wrapped into #symEcrec(), corresponds to #ecrecEmpty(DATA) == true
    rule 0 <Int   #symEcrec(DATA)             => true

    //that's because the result in concrete semantics is trimmed to Address range.
    rule          #symEcrec(DATA) <Int pow160 => true

    // Lemmas implied by the above, but still required to match side conditions of #padToWidth rule in lemmas.md
    // General range conversion lemmas like below are not an option, dramatic performance decrease:
    //    rule A < pow256 => true requires A < pow160
    rule 0 <=Int  #symEcrec(DATA)             => true
    rule          #symEcrec(DATA) <Int pow256 => true


    syntax Int ::= #sha256 ( WordStack ) [function, smtlib(sha256)]
    rule 0 <=Int  #sha256(_)             => true
    rule          #sha256(_) <Int pow256 => true



  // ########################
  // Symbolic Gas
  // ########################

    syntax Int ::= #gas ( Int , Int , Int )  [function]  // startGas, nonMemory, memory
 // -----------------------------------------------------------------------------------
 /*
  startGas - gas available at the beginning of execution
  nonMemory - gas consumed on non-memory operations
  memory - gas consumed on memory operation

  Concrete semantics:

  rule #gas ( StartGas , NonMemory , Memory ) => StartGas -Int NonMemory -Int Memory
 */

    syntax Int ::= #symCmem ( Int )  [function]
 // -------------------------------------------

 // callSuccess? caputures various cases where a call may fail including out of gas, insufficient balance and etc.
 // TODO: include the calldata as the argument.
    syntax Int ::= #callGas ( Schedule , Int , Int , Int , Bool )  [function]  // schedule, gasCap, accountTo, value, callSuccess?
 // ------------------------------------------------------------------------------------------------------------------------------


  // ########################
  // Symbolic Call
  // ########################

 // PC helps to differentiate different calls to the same account.
 // TODO: include the calldata as the argument.
    syntax Bool ::= #callSuccess ( Int , Int )  [function]  // pc, accountTo
                  | #callFailure ( Int , Int )  [function]  // pc, accountTo
 // ------------------------------------------------------------------------

    syntax Int ::= #callResult ( Int , Int )  [function]  // pc, accountTo
 // ----------------------------------------------------------------------


    syntax Int ::= #extCodeSize ( Int )  [function]
 // -----------------------------------------------

 // ERC20 transfer(address,uint256)
 // pc, to addr
    syntax Bool ::= #tokenTransferCallSuccess ( Int , Int ) [function]
                  | #tokenTransferCallFailure ( Int , Int ) [function]
 // ------------------------------------------------------------------

 // 3rd argument: <timestamp> NOW </timestamp> variable hack to force to generate Z3 query
    syntax Int ::= #tokenTransferCallReturnSize  ( Int , Int , Int ) [function]
                 | #tokenTransferCallReturnValue ( Int , Int , Int ) [function]
 // ---------------------------------------------------------------------------


endmodule
