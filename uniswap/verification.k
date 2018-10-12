requires "edsl.k"
requires "../lemmas.k"

module VERIFICATION
    imports EDSL
    imports LEMMAS

    syntax Int ::= "#tokenReserve"  [function, smtlib(smt_token_reserve)]

    syntax Int ::= "#exchangeAddr"  [function, smtlib(smt_exchange_addr)]

    rule <k> EXTCODESIZE ACCTTO => 1 ~> #push ... </k> [trusted]

    // addLiquidity
    // #Line 55: self.token.balanceOf(self)
    rule <k> STATICCALL GCAP TOKEN_ADDR 1020 36 1120 32
           => 1 ~> #push ~> #setLocalMem 1120 32 #asByteStackInWidth(#tokenReserve, 32) ... </k> [trusted]

    // #Line 61: self.token.transferFrom(msg.sender, self, token_amount)
    rule <k> CALL GCAP TOKEN_ADDR 0 1244 100 1408 32
           => 1 ~> #push ~> #setLocalMem 1408 32 #asByteStackInWidth(1, 32) ... </k> [trusted]

    // #Line 67: self.factory.getExchange(self.token)
    rule <k> STATICCALL GCAP FACTORY_ADDR 476 36 576 32
           => 1 ~> #push ~> #setLocalMem 576 32 #asByteStackInWidth(#exchangeAddr, 32) ... </k> [trusted]

    // #Line 72: self.token.transferFrom(msg.sender, self, token_amount)
    rule <k> CALL GCAP TOKEN_ADDR 0 700 100 864 32
           => 1 ~> #push ~> #setLocalMem 864 32 #asByteStackInWidth(1, 32) ... </k> [trusted]

    // removeLiquidity
    // #Line 88: self.token.balanceOf(self)
    rule <k> STATICCALL GCAP TOKEN_ADDR 540 36 640 32
           => 1 ~> #push ~> #setLocalMem 640 32 #asByteStackInWidth(#tokenReserve, 32) ... </k> [trusted]

    // #Line 94: self.token.transfer(msg.sender, token_amount)
    rule <k> CALL GCAP TOKEN_ADDR 0 764 68 896 32
           => 1 ~> #push ~> #setLocalMem 896 32 #asByteStackInWidth(1, 32) ... </k> [trusted]

    rule <k> CALL 0 ACCTTO VALUE 0 0 0 0 => 1 ~> #push ... </k> [trusted]

    // ethToTokenSwapInput
    rule <k> STATICCALL GCAP TOKEN_ADDR 572 36 RETSTART RETWIDTH
           => 1 ~> #push ~> #setLocalMem RETSTART RETWIDTH #asByteStackInWidth(#tokenReserve, 32) ... </k> [trusted]

    rule <k> CALL GCAP TOKEN_ADDR 0 988 68 RETSTART RETWIDTH
           => 1 ~> #push ~> #setLocalMem RETSTART RETWIDTH #asByteStackInWidth(1, 32) ... </k> [trusted]

    // ethToTokenSwapOutput
    // rule <k> STATICCALL GCAP ACCTTO 572 36 RETSTART RETWIDTH
    //       => 1 ~> #push ~> #setLocalMem RETSTART RETWIDTH #asByteStackInWidth(#tokenReserve, 32) ... </k> [trusted]

    // rule <k> CALL GCAP ACCTTO 0 1052 68 RETSTART RETWIDTH
    //       => 1 ~> #push ~> #setLocalMem RETSTART RETWIDTH #asByteStackInWidth(1, 32) ... </k> [trusted]

    //rule <k> CALL 0 ACCTTO VALUE 0 0 0 0 => 1 ~> #push ... </k> [trusted]

    rule 0 <=Int #tokenReserve => true

    rule #tokenReserve <Int pow256 => true

    rule 0 <=Int #exchangeAddr => true

    rule #exchangeAddr <Int pow160 => true

    rule #exchangeAddr <Int pow256 => true

endmodule
