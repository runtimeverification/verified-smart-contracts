# Formal Verification of Ethereum 2.0 Deposit Contract

This directory contains the intermediate result of our (ongoing) formal verification of the [deposit contract].

Documents:
 * [Formalization of the incremental Merkle tree algorithm and its correctness proof](deposit/formal-incremental-merkle-tree-algorithm.pdf)
 * [Blog post](https://runtimeverification.com/blog/formal-verification-of-ethereum-2-0-deposit-contract-part-i)

Mechanized specifications and proofs in K:
 * [deposit.k](deposit/deposit.k): Formal model of the incremental Merkle tree algorithm
 * [deposit-spec.k](deposit/deposit-spec.k): Correctness specifications
 * [deposit-symbolic.k](deposit/deposit-symbolic.k): Lemmas (trusted)

To prove the specifications:
```
$ ./run.sh
```
Prerequisites:
 * Install K: https://github.com/kframework/k/releases

## [Resources](/README.md#resources)

## [Disclaimer](/README.md#disclaimer)

[deposit contract]: <https://github.com/ethereum/eth2.0-specs/blob/master/deposit_contract/contracts/validator_registration.v.py>
