requires "edsl.k"
requires "../lemmas.k"

module VERIFICATION
    imports EDSL
    imports LEMMAS


///////////////////////////////////////////////////////////////////////////////
// Macros
///////////////////////////////////////////////////////////////////////////////


    syntax Int ::= "#expectedBlockNumber" "(" Int "," Int ")"  [function]
 // ---------------------------------------------------------------------
    rule #expectedBlockNumber(EPOCH, EPOCHLEN) => EPOCH *Int EPOCHLEN -Int 1



endmodule
