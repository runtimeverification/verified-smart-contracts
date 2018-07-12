# Formal Verification of Casper Protocol

Author: [Karl Palmskog](http://setoid.com/)

Date: July 2018

---

This document describes the protocol verification effort for the Casper smart contract in the proof assistants Coq and Isabelle/HOL. The effort was initially made in concert with lower-level [verification in the K Framework of smart contract code] written in the Vyper language.

## Background

Our (unfinished) model of the Casper contract behavior is an adaptation of a general model, called Toychain, of a blockchain distributed system in Coq, originally written by Pirlea and Sergey and described in a 2017 paper in the conference on Certified Proofs and Programs (CPP). The advantage of using this model is that it captures the concept of forks in a tree of blocks (different choices of canonical blockchain), which is necessary to fully specify what Casper is supposed to accomplish.

- Paper: <http://ilyasergey.net/papers/toychain-cpp18.pdf>
- GitHub repository: <https://github.com/certichain/toychain>

We only used some of the core components from Toychain:

- datatypes for blocks of transactions, blockchains, and block forest, and accompanying functions and lemmas (e.g., block validation)

- datatypes and functions for (abstract) network node state

- message processing functions and node/network behavior semantics

Among other things, we removed messages exchanged between nodes that are irrelevant to Casper, and many Toychain lemmas (theory) with no bearing on Casper correctness.

We were also basing our work on Yoichi Hirai's abstract Casper protocol model in Isabelle/HOL that verified accountable safety (earlier, less complete models also verified plausible liveness).

## Original plan of work

We planned to verify the Casper contract by working from both ends of the spectrum of abstraction:

1. connecting (instantiating) Yoichi Hirai's most detailed abstract protocol model in Isabelle/HOL to the Coq blockchain model

2. capturing [ABSTRACT-CASPER], the abstraction in K of the Casper contract code written in Vyper 

The rationale was that if Yoichi's proofs capture the informal results in Vitalik's paper "[Casper the Friendly Finality Gadget]", and there is a direct, mostly formal, connection between the high-level abstract protocol model down to Vyper code via Coq and ABSTRACT-CASPER, the protocol and its implementation is adequately verified. 

Yoichi was primarily using Isabelle/HOL, transferring key blockchain definitions from Coq to instantiate his high-level protocol abstraction, while Karl Palmskog and Lucas Pena were encoding ABSTRACT-CASPER in Coq.

## Current state of work

The current Casper contract Coq model can be found in the following GitHub repository: <https://github.com/palmskog/caspertoychain>

The following Isabelle/HOL tasks were finished by Yoichi:

- basic "smoke test" of instantiation of environments in Isabelle/HOL

- basic instantiation of blockchain definitions in Coq for the abstract Casper model

We do not currently have access to Yoichi's Isabelle/HOL code instantiating the blockchain definitions.

The following Isabelle/HOL tasks were in progress but are unfinished:

- formal proof of plausible liveness for the most up-to-date and detailed model of Casper behavior

- transfer/translation of definitions and results from the Coq model of Casper

- full instantiation in Isabelle/HOL of all relevant blockchain definitions, including of (low-level) Casper state and behavior, giving end-to-end proofs of accountable safety and plausible liveness

The following Coq tasks were finished by Karl and Lucas:

- encoding of (datatypes for) the Casper contract state, recording, e.g., which validator has voted in an epoch

- encoding of Casper contract transactions (voting, slashing, etc.)

- definition of basic structure for computing the Casper contract state for a network node (processing transactions in a blockchain from the initial Casper state)

- incomplete but executable definitions of functions for updating the Casper contract state when receiving new transactions/messages, and accompanying lemmas that describe more abstractly how the state can change

Coq tasks that were in progress but are unfinished:

- axiomatization of operations related to rewards for validators (and slashing of their Ether contributions/deposits when they misbehave)

- complete definition of Casper contract behavior as Coq functions and accompanying characterizing lemmas for those functions

- instantiation of reward/slashing operations and datatype with something realistic, such as fixed-decimal numbers

- establishment of a connection between the Coq model and the K abstraction, e.g., through differential testing of particular contract state instances

- transfer/translation of accountable safety and plausible liveness from the Isabelle/HOL protocol model



[verification in the K Framework of smart contract code]: <https://github.com/runtimeverification/verified-smart-contracts/blob/master/casper/README.md>
[ABSTRACT-CASPER]: <https://github.com/runtimeverification/verified-smart-contracts/blob/master/casper/abstract-casper.k>
[Casper the Friendly Finality Gadget]: <https://arxiv.org/abs/1710.09437>


