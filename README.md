# Formally Verified Smart Contracts

This repository contains all the smart contracts that have heen formally verified by [Runtime Verification](http://runtimeverification.com) and/or collaborators.

To verify a smart contract, you need to first produce a specification that the smart contract must satisfy, which is often the most difficult part of the verification effort.
Then you need to show that the binary or low-level code (e.g., EVM binary) geneated by the compiler from the smart contract high level code (e.g., Solidity) indeed satisfies the specification.
The proofs use reachability logic, a generalization of Hoare logic and separation logic, and are performed using the [K framework](http://kframework.org).
The K framework takes a formal semantics of a language as trusted input (e.g., of the EVM), and then uses it to symbolically execute the smart contract exhaustively on all paths, making use of SMT solvers like [Z3](https://github.com/Z3Prover/z3) to solve the mathematical domain constraints.

## Pending

(Links to be added soon)

* **2018/??/??** Casper - Ethereum Foundation
* **2018/??/??** Fabian Vogelsteller's ICO contract and ICO schema
* **2018/02/??** Bihu

## Completed

(Links and completion dates to be added soon)

* Philip Daian's Viper ERC20 token: fully conforming to the ERC20 standard
* OpenZeppelin ERC20 token: conforming to the standard, but:
   * Rejecting transfers to address 0
* ConsenSys ERC20 token: conforming to the standard, but:
   * No arithmetic overflow protection
   * Supporting infinite allowances variant
* HackerGold (HKG) ERC20 token: deviating from the standard:
   * No arithmetic overflow protection
   * No totalSupply function
   * Rejecting transfers of 0 values
   * Returning false in failure
* KidsEducationToken (personal hobby ERC20 token): buggy implementation:
   * Typographical bug: <= instead of >=
   * Incorrect overflow detection for self-transfers
   * Rejecting transfers of 0 values
   * Returning false in failure
