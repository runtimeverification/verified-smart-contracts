_**[DEPRECATED: The result in this directory is outdated. The deposit contract has been reimplemented in Solidity and reverified. The latest result can be found at https://github.com/runtimeverification/deposit-contract-verification.]**_

# Formalization and Correctness Proof of Incremental Merkle Tree Algorithm of Deposit Contract

This directory presents our formalization of the [incremental Merkle tree algorithm], especially the one employed in the [deposit contract], and prove its correctness w.r.t. the [original full-construction Merkle tree algorithm].

Documents:
 * [Formalization of the incremental Merkle tree algorithm and its correctness proof](../formal-incremental-merkle-tree-algorithm.pdf)
 * [Blog post](https://runtimeverification.com/blog/formal-verification-of-ethereum-2-0-deposit-contract-part-1)

Mechanized specifications and proofs in K:
 * [deposit.k](deposit.k): Formal model of the incremental Merkle tree algorithm
 * [deposit-spec.k](deposit-spec.k): Correctness specifications
 * [deposit-symbolic.k](deposit-symbolic.k): Lemmas (trusted)

To prove the specifications:
```
$ ./run.sh
```
Prerequisites:
 * Install K: https://github.com/kframework/k/releases

## [Resources](/README.md#resources)

## [Disclaimer](/README.md#disclaimer)

[deposit contract]: <https://github.com/ethereum/eth2.0-specs/blob/v0.10.0/deposit_contract/contracts/validator_registration.vy>
[incremental Merkle tree algorithm]: <https://github.com/ethereum/research/blob/master/beacon_chain_impl/progressive_merkle_tree.py>
[original full-construction Merkle tree algorithm]: <https://en.wikipedia.org/wiki/Merkle_tree>
