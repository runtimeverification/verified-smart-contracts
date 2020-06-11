_**[DEPRECATED: The result in this directory is outdated. The deposit contract has been reimplemented in Solidity and reverified. The latest result can be found at https://github.com/runtimeverification/deposit-contract-verification.]**_

*2020-01-21*

# End-to-End Formal Verification of Ethereum 2.0 Deposit Contract

This directory provides the result of our end-to-end formal verification of the Ethereum 2.0 [deposit contract].

Documents:
 * Final report: [`deposit-formal-verification.pdf`](deposit-formal-verification.pdf)
 * Blog post: https://runtimeverification.com/blog/end-to-end-formal-verification-of-ethereum-2-0-deposit-smart-contract/

Verification artifacts:
 * [`algorithm-correctness/`](algorithm-correctness): Formalization and correctness proof of incremental Merkle tree algorithm
 * [`bytecode-verification/`](bytecode-verification): Bytecode verification of the deposit contract

## [Resources](/README.md#resources)

## [Disclaimer](/README.md#disclaimer)

[deposit contract]: <https://github.com/ethereum/eth2.0-specs/blob/v0.10.0/deposit_contract/contracts/validator_registration.vy>
