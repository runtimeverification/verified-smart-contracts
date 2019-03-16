requires "edsl.k"

module EVM-SYMBOLIC     [symbolic]
    imports EVM
    imports EDSL

  // ########################
  // Ecrecover
  // ########################

    //Symbolic wrapper over the argument of #ecrec, no implementation.
    syntax Int ::= #symEcrec ( WordStack )   [function]

    //Symbolic predicate representing whether output of #ecrec is empty. No implementation.
    syntax Bool ::= #ecrecEmpty( WordStack ) [function]


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
