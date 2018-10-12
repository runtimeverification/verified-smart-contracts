*2018-10-12*

# Uniswap Smart Contract Formal Verification

## Target Contract
The target contract of our formal verification is the following, where we took the Vyper source code from Uniswap's Github repository, commit [cb4308226f](https://github.com/Uniswap/contracts-vyper/tree/cb4308226f07cafa445b2255b01d148e7ab6af9f/contracts):

* [uniswap_exchange.vy](https://github.com/Uniswap/contracts-vyper/blob/cb4308226f07cafa445b2255b01d148e7ab6af9f/contracts/uniswap_exchange.vy)

More specifically, we formally explored all states of the following 4 functions:

* [addLiquidity](https://github.com/Uniswap/contracts-vyper/blob/cb4308226f07cafa445b2255b01d148e7ab6af9f/contracts/uniswap_exchange.vy#L41-L75)
* [removeLiquidity](https://github.com/Uniswap/contracts-vyper/blob/cb4308226f07cafa445b2255b01d148e7ab6af9f/contracts/uniswap_exchange.vy#L77-L98)
* [ethToTokenSwapInput](https://github.com/Uniswap/contracts-vyper/blob/cb4308226f07cafa445b2255b01d148e7ab6af9f/contracts/uniswap_exchange.vy#L145-L153)
* [ethToTokenSwapOutput](https://github.com/Uniswap/contracts-vyper/blob/cb4308226f07cafa445b2255b01d148e7ab6af9f/contracts/uniswap_exchange.vy#L180-L188)

The target contract is complied by the Vyper compiler, commit[35038d20bd](https://github.com/ethereum/vyper/tree/35038d20bd9946a35261c4c4fbcb27fe61e65f78).

## Tools
We used the following version of K and EVM-semantics:

* [K](https://github.com/kframework/k/tree/92d21b60ee087a368038a332ef98535455c26b63)
* [EVM-semantics](https://github.com/kframework/evm-semantics/tree/f9727f67754ba2b292fbe337f9ca9f53fba5b5b5)

## Commands
* Install EVM-Semantics and K
```sh
make kevm
```

* Generate Specs
```sh
make uniswap
```

* Generate Proof Results
```sh
cd ./build/evm-semantics
./kevm prove ../../specs/uniswap/addLiquidity-1-spec.k
```
