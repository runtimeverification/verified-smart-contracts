# Formal Verification of Casper Smart Contract

We present the formal verification of the Casper FFG smart contract.


## Scope

The verification target is the Casper contract implementation `simple_casper.v.py`, a critical component of the entire Casper FFG protocol. Specifically, we consider the version [b2a1189].


The Casper FFG protocol is described in the paper "[Casper the Friendly Finality Gadget]", and its implementation consists of the following two main components:

- The smart contract: It provides the important functionality of the protocol, that is, the registration and withdrawal of validators, the vote and slash functions, maintaining the protocol state (i.e., the current dynasty and epoch number, vote status for each epoch, and the current status of validators), and the reward/penalty computation. Most of the protocol logic is implemented in this contract to minimize the burden of the additional network node support.

- The network node support: It provides certain network-level functionality of the protocol that is hard to be implemented in the contract, e.g., delaying the contract, initializing epochs, and fork choice rule. The details are described in [EIP 1011].


While the correctness of the protocol requires the correctness of both the smart contract and the network node support, the goal of this verification effort is limited to verify the full functional correctness of the smart contract, assuming the correctness of the network node support.

We also note that formal reasoning about the protocol itself is not part of the contract verification, but part of the [protocol verification], which is a separate companion effort by another team.


## Formal Specification of Casper Contract

Following our formal verification methodology, we specified the high-level business logic specification of the contract, and refined it to the EVM-level specification against which we formally verified the contract bytecode using our KEVM verifier.

First, we specified [ABSTRACT-CASPER], the abstract high-level business logic specification of the Casper contract. The purpose of the high-level specification is to formalize the abstract behavior of the contract, which can be used as a communication interface between different parties: the contract verification team, the protocol verification team, and the contract developers. The developers are supposed to confirm that this specification captures all of the intended behaviors. The [protocol verification] uses this specification to formalize and verify the entire protocol. We also formalized the [reward-penalty model].

Then, we refined [ABSTRACT-CASPER] to [CASPER], the concrete functional specification of the Casper contract. While both are high-level specifications, [CASPER] is much closer to the actual behavior of the contract. For example, [ABSTRACT-CASPER] simplifies the reward/penalty computation mechanism, where it computes the reward and/or penalty of all validators at the end of each epoch. However, [CASPER] specifies the actual mechanism implemented in the contract, where the reward/penalty is incrementally computed every time a validator votes.

Finally, we refined [CASPER] to [CASPER-EVM], the EVM-level specification of the contract bytecode. [CASPER-EVM] specifies the additional details of the compiled EVM bytecode: the gas consumption, the storage layout, the arithmetic overflow, the fixed-point number arithmetic, the decimal rounding errors, and other EVM quicks.


## Formal Verification Result: Current Progress and Findings

We provide the current result of the formal verification.


### Current Progress

We compiled the contract source code using the Vyper compiler, and verified the compiled EVM bytecode using the KEVM verifier against the functional correctness specification [CASPER-EVM].

Currently, the following functions are verified:

- Constant functions:
  - `main_hash_voted_frac`
  - `deposit_size`
  - `total_curdyn_deposits_scaled`
  - `total_prevdyn_deposits_scaled`
  - `recommended_source_epoch`
  - `recommended_target_hash`
  - `deposit_exists`

- Private functions:
  - `increment_dynasty`
  - `esf`
  - `collective_reward`
  - `insta_finalize`

- Public functions:
  - `logout`
  - `delete_validator`
  - `proc_reward`
  - `vote`


The verification of the following functions is in progress:

- `sqrt_of_total_deposits`
- `initialize_epoch`
- `deposit`
- `withdraw`
- `slash`


#### Assumption




### Our Findings















[b2a1189]: <https://github.com/ethereum/casper/blob/b2a1189506710c37bbdbbf3dc79ff383dbe13875/casper/contracts/simple_casper.v.py>
[Casper the Friendly Finality Gadget]: <https://arxiv.org/abs/1710.09437>
[ABSTRACT-CASPER]: <https://github.com/runtimeverification/verified-smart-contracts/blob/master/casper/abstract-casper.k>
[EIP 1011]: <https://eips.ethereum.org/EIPS/eip-1011>
[protocol verification]: <https://github.com/palmskog/caspertoychain>
[CASPER]: <https://github.com/runtimeverification/verified-smart-contracts/blob/master/casper/casper.k>
[CASPER-EVM]: <https://github.com/runtimeverification/verified-smart-contracts/blob/master/casper/casper-spec.ini>
[reward-penalty model]: <https://github.com/runtimeverification/verified-smart-contracts/blob/master/casper/reward-penalty-model.pdf>
