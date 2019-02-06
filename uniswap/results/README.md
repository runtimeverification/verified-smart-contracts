# Bytecode Symbolic Execution Result

### [addLiquidity-1.txt]

Symbolic exploration of [`addLiquidity`] bytecode when `total_liquidity > 0`.

 1. if `assert deadline > block.timestamp and max_tokens > 0` fails:
    * REVERT
 1. else if `assert min_liquidity > 0` fails:
    * REVERT
 1. else if `self.token.balanceOf(self)` throws/reverts:
    * REVERT
 1. else if `msg.value == 0`:
    * REVERT (since it leads to the failure of `assert liquidity_minted >= min_liquidity` afterwards)
 1. else if `msg.value * token_reserve` overflows:
    * REVERT
 1. else if `msg.value * token_reserve / eth_reserve + 1` overflows (in addition):
    * REVERT
 1. else if `msg.value * total_liquidity` overflows:
    * REVERT
 1. else if `assert max_tokens >= token_amount and liquidity_minted >= min_liquidity` fails:
    * REVERT
 1. else if `self.balances[msg.sender] + liquidity_minted` overflows:
    * REVERT
 1. else if `total_liquidity + liquidity_minted` overflows:
    * REVERT
 1. else if `self.token.transferFrom(msg.sender, self, token_amount)` throws/reverts:
    * REVERT
 1. else if `assert self.token.transferFrom(msg.sender, self, token_amount)` fails:
    * REVERT
 1. else:
    * UPDATE `self.balances[msg.sender] := self.balances[msg.sender] + liquidity_minted`
    * UPDATE `self.totalSupply := total_liquidity + liquidity_minted`
    * RETURN `liquidity_minted`

We have 13 symbolic paths.
Here, *"else if"* implicitly means the negation of all previous conditions, as in the usual programming language semantics.
There are many reverting paths.
Most of them are trivial, falling into the following categories:
 * assertion failure
 * external call failure (i.e., throwing, reverting, or returning false)
 * arithmetic overflows

A non-trivial case is the path #4, where `msg.value == 0` leads to the failure of the assertion `liquidity_minted >= min_liquidity` later.
This case is not trivial to catch without the symbolic execution result.
Indeed, the latest version add [`assert msg.value > 0`] in the beginning to save the unnecessary gas consumption in that case.

Note that here we assume that the existing balance before calling this function is non-zero, that is, `self.balance > msg.value`, thus `eth_reserve` is not zero and no division-by-zero failure occurs.
Let us show that `total_liquidity > 0` implies `eth_reserve > 0`.
We show it by induction:
 * Base case. In the beginning, once the contract is created, `total_liquidity = 0` and `eth_reserve >= 0`.
 * Inductive case: We have four (families) of functions that can update `self.balance`, that is, `addLiquidity`, `removeLiquidity`, `ethToToken*`, and `tokenToEth*`:
   * `addLiquidity`:
     * When `total_liquidity = 0`, we have `total_liquidity > 0` and `eth_reserve > 0` at the end of the function since `msg.value > 0`.
     * When `total_liquidity > 0`, it strictly increases both `total_liquidity` and `eth_reserve` since `msg.value > 0`.
   * `removeLiquidity`: We have `eth_amount < self.balance` if `amount < total_liquidity`. That is, the remaining balance is greater than 0 at the end of the function, as long as it does not burn the whole liquidity.
   * `ethToToken*` family: They always increase the balance.
   * `tokenToEth*` family: The remaining balance is always greater than 0 at the end of the functions. They do not allow to buy the whole amount of the reserved Ether, since `getOutputPrice` reverts when `output_amount >= output_reserve`, and the return value of `getInputPrice` is always less than the balance (i.e., `input_amount_with_fee * output_reserve / ((input_reserve * 1000) + input_amount_with_fee) < output_reserve` because `input_reserve > 0`). In other word, you need the infinite amount of tokens to buy the whole Ether, which is not possible in reality.

### [addLiquidity-2.txt]

Symbolic exploration of [`addLiquidity`] bytecode when `total_liquidity = 0`.

 1. if `assert deadline > block.timestamp and max_tokens > 0` fails:
    * REVERT
 1. else if `assert (self.factory != ZERO_ADDRESS and self.token != ZERO_ADDRESS) and msg.value >= 1000000000` fails:
    * REVERT
 1. else if `self.factory.getExchange(self.token)` throws/reverts:
    * REVERT
 1. else if `assert self.factory.getExchange(self.token) == self` fails:
    * REVERT
 1. else if `self.token.transferFrom(msg.sender, self, token_amount)` throws/reverts:
    * REVERT
 1. else if `assert self.token.transferFrom(msg.sender, self, token_amount)` fails:
    * REVERT
 1. else:
    * UPDATE `self.totalSupply := initial_liquidity`
    * UPDATE `self.balances[msg.sender] := initial_liquidity`
    * RETURN `initial_liquidity`

### [removeLiquidity.txt]

Symbolic exploration of [`removeLiquidity`] bytecode.

 1. if `assert msg.value == 0` (implicit assertion) fails:
    * REVERT
 1. else if `assert (amount > 0 and deadline > block.timestamp) and (min_eth > 0 and min_tokens > 0)` fails:
    * REVERT
 1. else if `assert total_liquidity > 0` fails:
    * REVERT
 1. else if `self.token.balanceOf(self)` throws/reverts:
    * REVERT
 1. else if `amount * self.balance` overflows:
    * REVERT
 1. else if `amount * token_reserve` overflows:
    * REVERT
 1. else if `assert eth_amount >= min_eth and token_amount >= min_tokens` fails:
    * REVERT
 1. else if `self.balances[msg.sender] - amount` overflows:
    * REVERT
 1. else if `total_liquidity - amount` overflows:
    * REVERT
 1. else if `self.token.transfer(msg.sender, token_amount)` throws/reverts:
    * REVERT
 1. else if `assert self.token.transfer(msg.sender, token_amount)` fails:
    * REVERT
 1. else if `send(msg.sender, eth_amount)` throws/reverts:
    * REVERT
 1. else:
    * UPDATE `self.balances[msg.sender] := self.balances[msg.sender] - amount`
    * UPDATE `self.totalSupply := total_liquidity - amount`
    * RETURN `eth_amount, token_amount`

NOTE: The path #1 is due to the implicit assertion of a non @payable function.

### [ethToTokenSwapInput.txt]

Symbolic exploration of [`ethToTokenSwapInput`] bytecode.

 Inside `ethToTokenInput` function:
 1. else if `assert deadline >= block.timestamp and (eth_sold > 0 and min_tokens > 0)` fails:
    * REVERT
 1. else if `self.token.balanceOf(self)` throws/reverts:
    * REVERT
 1. Inside `getInputPrice` function:
    1. else if `assert input_reserve > 0 and output_reserve > 0` fails:
       * REVERT
    1. else if `input_amount * 997` overflows:
       * REVERT
    1. else if `input_amount_with_fee * output_reserve` overflows:
       * REVERT
    1. else if `input_reserve * 1000` overflows:
       * REVERT
    1. else if `(input_reserve * 1000) + input_amount_with_fee` overflows (in addition):
       * REVERT
 1. else if `assert tokens_bought >= min_tokens` fails:
    * REVERT
 1. else if `self.token.transfer(recipient, tokens_bought)` throws/reverts:
    * REVERT
 1. else if `assert self.token.transfer(recipient, tokens_bought)` fails:
    * REVERT
 1. else:
    * RETURN `msg.value * 997 * token_reserve / ((self.balance - msg.value) * 1000 + msg.value * 997)`

### [ethToTokenSwapOutput.txt]

Symbolic exploration of [`ethToTokenSwapOutput`] bytecode.

 Inside `ethToTokenOutput` function:
 1. if `assert deadline >= block.timestamp and (tokens_bought > 0 and max_eth > 0)` fails:
    * REVERT
 1. else if `self.token.balanceOf(self)` throws/reverts:
    * REVERT
 1. Inside `getOutputPrice` function:
    1. else if `assert input_reserve > 0 and output_reserve > 0` fails:
       * REVERT
    1. else if `input_reserve * output_amount` overflows:
       * REVERT
    1. else if `(input_reserve * output_amount) * 1000` overflows (in the second multiplication):
       * REVERT
    1. else if `output_reserve - output_amount` overflows:
       * REVERT
    1. else if `output_reserve == output_amount`:
       * REVERT (since this leads to the division-by-zero failure of `numerator / denominator` afterwards)
    1. else if `(output_reserve - output_amount) * 997` overflows (in multiplication):
       * REVERT
    1. else if `numerator / denominator + 1` overflows (in addition):
       * REVERT
 1. else if `max_eth - as_wei_value(eth_sold, 'wei')` overflows (in subtraction):
    * REVERT
 1. else:
    1. if `eth_refund > 0`:
       1. if `send(buyer, eth_refund)` throws/reverts:
          * REVERT
       1. else if `self.token.transfer(recipient, tokens_bought)` throws/reverts:
          * REVERT
       1. else if `assert self.token.transfer(recipient, tokens_bought)` fails:
          * REVERT
       1. else:
          * RETURN `((self.balance - msg.value) * token_bought * 1000) / ((token_reserve - token_bought) * 997) + 1`
    1. else:
       1. if `self.token.transfer(recipient, tokens_bought)` throws/reverts:
          * REVERT
       1. else if `assert self.token.transfer(recipient, tokens_bought)` fails:
          * REVERT
       1. else:
          * RETURN `((self.balance - msg.value) * token_bought * 1000) / ((token_reserve - token_bought) * 997) + 1`

NOTE: The path #3.v reverts due to the division-by-zero failure of `numerator / denominator`, where `denominator` becomes zero.
In other word, you are not allowed to buy the whole amount of reserved tokens.



[`addLiquidity`]:           <https://github.com/Uniswap/contracts-vyper/blob/cb4308226f07cafa445b2255b01d148e7ab6af9f/contracts/uniswap_exchange.vy#L41-L75>
[`removeLiquidity`]:        <https://github.com/Uniswap/contracts-vyper/blob/cb4308226f07cafa445b2255b01d148e7ab6af9f/contracts/uniswap_exchange.vy#L77-L98>
[`ethToTokenSwapInput`]:    <https://github.com/Uniswap/contracts-vyper/blob/cb4308226f07cafa445b2255b01d148e7ab6af9f/contracts/uniswap_exchange.vy#L145-L153>
[`ethToTokenSwapOutput`]:   <https://github.com/Uniswap/contracts-vyper/blob/cb4308226f07cafa445b2255b01d148e7ab6af9f/contracts/uniswap_exchange.vy#L180-L188>

[addLiquidity-1.txt]:       <addLiquidity-1.txt>
[addLiquidity-2.txt]:       <addLiquidity-2.txt>
[removeLiquidity.txt]:      <removeLiquidity.txt>
[ethToTokenSwapInput.txt]:  <ethToTokenSwapInput.txt>
[ethToTokenSwapOutput.txt]: <ethToTokenSwapOutput.txt>

[`assert msg.value > 0`]: <https://github.com/Uniswap/contracts-vyper/commit/3956e9a493b182ec408cd9d118e2ff4f1ff628ab>
