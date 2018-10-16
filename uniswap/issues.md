We list all the issues we found in the inital version ([commit fddd25e](https://github.com/Uniswap/contracts-vyper/blob/fddd25e9ab5602535bb00e3f5d44296e08d9a0fc/contracts/uniswap_exchange.vy)) and
subsequent commits.

# Rounding errors
we found several rounding error issues in the code.
* In `addLiquidity` function, `token_amount` computed on [line 51](https://github.com/Uniswap/contracts-vyper/blob/fddd25e9ab5602535bb00e3f5d44296e08d9a0fc/contracts/uniswap_exchange.vy#L51)
is less than the actual value. 
The issue was fixed in [commit 2c29ee8](https://github.com/Uniswap/contracts-vyper/commit/2c29ee8943bc12a4f3cfaad58c2092396aa579c1)

* In `ethToToken`([line 92](https://github.com/Uniswap/contracts-vyper/blob/fddd25e9ab5602535bb00e3f5d44296e08d9a0fc/contracts/uniswap_exchange.vy#L92)) and `ethToTokenExact`([line 110](https://github.com/Uniswap/contracts-vyper/blob/fddd25e9ab5602535bb00e3f5d44296e08d9a0fc/contracts/uniswap_exchange.vy#L110)) functions,
the way to compute final results uses two integer divisions, and thus the error can notbe bounded. 
We proposed a better way to compute the results and reduced the error to at most 1.
The issue was fixed in [commit 2c29ee8](https://github.com/Uniswap/contracts-vyper/commit/7b23a2e60a1c8ff5d4b88fd4f83e74467256f8da).

# Issues in Implementation
* On [line 28](https://github.com/Uniswap/contracts-vyper/blob/fddd25e9ab5602535bb00e3f5d44296e08d9a0fc/contracts/uniswap_exchange.vy#L28),
return value of `setup` function is not necessary. The issue was fixed in [commit (3cdbb98)](https://github.com/Uniswap/contracts-vyper/commit/3cdbb9881331a494c090edf5e7920a39b2fbec8f).

* In `getEthToToken`([line 104](https://github.com/Uniswap/contracts-vyper/blob/fddd25e9ab5602535bb00e3f5d44296e08d9a0fc/contracts/uniswap_exchange.vy#L104)) and `getTokenToEth`([line 120](https://github.com/Uniswap/contracts-vyper/blob/fddd25e9ab5602535bb00e3f5d44296e08d9a0fc/contracts/uniswap_exchange.vy#L120)) functions,
since no call value is passed to the two functions, `self.balance` is not modified. As a result, they should not directly call `ethToToken` and `ethToTokenExact` functions.
The issue was fixed in [commit 0612ebf](https://github.com/Uniswap/contracts-vyper/commit/0612ebf7621b886f7178fafd9a8ac41026a37296) and was further fixed in [commit 2c29ee8](https://github.com/Uniswap/contracts-vyper/commit/7b23a2e60a1c8ff5d4b88fd4f83e74467256f8da).

* Several uncessary assertions were removed in [commit ae2aec9](https://github.com/Uniswap/contracts-vyper/commit/ae2aec9a6128c6f28e7acfa793b9a647822179b8).

* We noticed that when comparing the computed value with user defined min/max value, `<` and `>` were used instead of `<=` and `>=`.
The issue was fixed in [commit fa912634](https://github.com/Uniswap/contracts-vyper/commit/fa91263460d3f4fc5482c2d9e9c89d93fe43708f).

* In `tokenToTokenExact`function([line 269](https://github.com/Uniswap/contracts-vyper/blob/d4cfffd2eb5dda71dbb0a35a23d9f6425bd345a2/contracts/uniswap_exchange.vy#L269)), the developer
wrongly used `min_eth_bought` instead of `max_eth_bought` to bound the ratio from eth to target token. 
The issue was fixed in [commit 07e86fb](https://github.com/Uniswap/contracts-vyper/commit/07e86fbfad9834ce4288a2704fcd3987c49ab550).

* We suggested adding `assert msg.value > 0` in the `addLiquidity` function. The issue was fixed in [commit 3956e9a](https://github.com/Uniswap/contracts-vyper/commit/3956e9a493b182ec408cd9d118e2ff4f1ff628ab).
