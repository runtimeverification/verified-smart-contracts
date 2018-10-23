requires "edsl.k"
requires "../lemmas.k"

module VERIFICATION
    imports EDSL
    imports LEMMAS

    syntax Int ::= #tokenReserve(Int)        [function, smtlib(smt_token_reserve)]

    syntax Int ::= #exchangeAddr(Int)        [function, smtlib(smt_exchange_addr)]

    syntax Int ::= #status(Int)              [function, smtlib(smt_status)]

    syntax Int ::= #transferFromReturn(Int)  [function, smtlib(smt_transfer_from_return)]

    syntax Int ::= #transferReturn(Int)      [function, smtlib(smt_transfer_return)]


    rule <k> EXTCODESIZE ACCTTO => 1 ~> #push ... </k> [trusted]

    // addLiquidity
    // #Line 55: self.token.balanceOf(self)
    rule <k> STATICCALL GCAP TOKEN_ADDR 1020 36 1120 32
           => #status(55) ~> #push ~> #setLocalMem 1120 32 #asByteStackInWidth(#tokenReserve(55), 32) ... </k> [trusted]

    // #Line 61: self.token.transferFrom(msg.sender, self, token_amount)
    rule <k> CALL GCAP TOKEN_ADDR 0 1244 100 1408 32
           => #status(61) ~> #push ~> #setLocalMem 1408 32 #asByteStackInWidth(#transferFromReturn(61), 32) ... </k> [trusted]

    // #Line 67: self.factory.getExchange(self.token)
    rule <k> STATICCALL GCAP FACTORY_ADDR 476 36 576 32
           => #status(67) ~> #push ~> #setLocalMem 576 32 #asByteStackInWidth(#exchangeAddr(67), 32) ... </k> [trusted]

    // #Line 72: self.token.transferFrom(msg.sender, self, token_amount)
    rule <k> CALL GCAP TOKEN_ADDR 0 700 100 864 32
           => #status(72) ~> #push ~> #setLocalMem 864 32 #asByteStackInWidth(#transferFromReturn(72), 32) ... </k> [trusted]

    // removeLiquidity
    // #Line 88: self.token.balanceOf(self)
    rule <k> STATICCALL GCAP TOKEN_ADDR 540 36 640 32
           => #status(88) ~> #push ~> #setLocalMem 640 32 #asByteStackInWidth(#tokenReserve(88), 32) ... </k> [trusted]

    // #Line 94: self.token.transfer(msg.sender, token_amount)
    rule <k> CALL GCAP TOKEN_ADDR 0 764 68 896 32
           => #status(94) ~> #push ~> #setLocalMem 896 32 #asByteStackInWidth(#transferReturn(94), 32) ... </k> [trusted]

    // send()
    rule <k> CALL 0 ACCTTO VALUE 0 0 0 0 => #status(95) ~> #push ... </k> [trusted]

    // ethToTokenSwapInput
    // #Line 130: self.token.balanceOf(self)
    rule <k> STATICCALL GCAP TOKEN_ADDR 572 36 672 32
           => #status(130) ~> #push ~> #setLocalMem 672 32 #asByteStackInWidth(#tokenReserve(130), 32) ... </k> [trusted]

    // #Line 133: self.token.transfer(recipient, tokens_bought)
    rule <k> CALL GCAP TOKEN_ADDR 0 988 68 1120 32
           => #status(133) ~> #push ~> #setLocalMem 1120 32 #asByteStackInWidth(#transferReturn(133), 32) ... </k> [trusted]

    // ethToTokenSwapOutput
    // #Line 170: self.token.balanceOf(self)
    // rule <k> STATICCALL GCAP ACCTTO 572 36 672 32
    //       => 1 ~> #push ~> #setLocalMem 672 32 #asByteStackInWidth(#tokenReserve, 32) ... </k> [trusted]

    // #Line 176: self.token.transfer(recipient, tokens_bought)
    rule <k> CALL GCAP ACCTTO 0 1052 68 1184 32
           => #status(176) ~> #push ~> #setLocalMem 1184 32 #asByteStackInWidth(#transferReturn(176), 32) ... </k> [trusted]

    // send()
    //rule <k> CALL 0 ACCTTO VALUE 0 0 0 0 => 1 ~> #push ... </k> [trusted]

    rule 0 <=Int #tokenReserve(I) => true

    rule #tokenReserve(I) <Int pow256 => true

    rule 0 <=Int #exchangeAddr(I) => true

    rule #exchangeAddr(I) <Int pow160 => true

    rule #exchangeAddr(I) <Int pow256 => true

    rule 0 <=Int #transferReturn(I) => true

    rule #transferReturn(I) <Int pow256 => true

    rule 0 <=Int #transferFromReturn(I) => true

    rule #transferFromReturn(I) <Int pow256 => true

    rule 0 <=Int #status(I) => true

endmodule
