# Formally Verified Smart Contracts

This repository contains all the smart contracts that have heen formally verified by [Runtime Verification](http://runtimeverification.com) and/or collaborators.

To verify a smart contract, you need to first produce a specification that the smart contract must satisfy, which is often the most difficult part of the effrot.
Then you need to show that the binary or low-level code (e.g., EVM binary) geneated by the compiler from the smart contract high level code (e.g., Solidity) indeed satisfies the specification.
The proofs use reachability logic, a generalization of Hoare logic and separation logic, and are performed using the [K framework](http://kframework.org).
The K framework takes a formal semantics of a language as trusted input (e.g., of the EVM), and then uses it to symbolically execute the smart contract exhaustively on all paths, making use of SMT solvers like [Z3](https://github.com/Z3Prover/z3) to solve the mathematicaldomain constraints.

* **2018/02/24** Bihu
