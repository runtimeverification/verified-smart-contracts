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


## Formal Verification Results: Current Progress and Findings

We provide the current results of the formal verification.


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


The verification of the following functions is in progress (but now suspended due to the [deprecated Casper FFG]):

- `sqrt_of_total_deposits`
- `initialize_epoch`
- `deposit`
- `withdraw`
- `slash`


#### Assumption

The formal verification results presented here assumes the following conditions:

- the correctness of the network node support
- the correctness of the low-level [signature validation code]
- the soundness of the refinement between [ABSTRACT-CASPER], [CASPER], and [CASPER-EVM]
- the completeness of the high-level specification: [ABSTRACT-CASPER] and [reward-penalty model]
- the correctness of the domain reasoning [lemmas]

We have not formally verified the above assumptions due to time constraints.


### Our Findings


#### Bugs found

We found several bugs in the contract source code in the course of the verification, which have been fixed by the developers. Refer to the following Github issue pages for more details.

- https://github.com/ethereum/casper/issues/57
- https://github.com/ethereum/casper/issues/67
- https://github.com/ethereum/casper/issues/74
- https://github.com/ethereum/casper/issues/75
- https://github.com/ethereum/casper/issues/83

As a (good) side-effect of the Casper contract verification, we also found several issues in the Vyper compiler that resulted in generating an incorrect bytecode from the contract. These issues have been fixed by the Vyper compiler team. Refer to the following for more details.

- https://github.com/ethereum/vyper/issues/767
- https://github.com/ethereum/vyper/issues/768
- https://github.com/ethereum/vyper/issues/775


#### Concerns

We reported several concerns regarding the overall protocol, and the Casper team confirmed that they are intended.

1. We are concerned that the identity (i.e., either the index or the signature-checker) of a validator could be different across multiple chains, which may be exploitable.

   However, we were answered that:
   > It is OK because a validator has to wait two dynasties (two finalized blocks) to join a validator set, then the case in which he has two different identities for the same ether deposit would mean that there were two different finalized blocks (competing forks) and some previous validators were slashed. In such a case, the community is expected to either choose a chain to rally behind or simply both chains continue to exist (like eth/eth-classic) in which the people not at fault continue to have funds on both.


1. We are concerned that the contract executes the arbitrary external signature validation code provided by validators. Although the external code is checked by the [purity checker], we are still concerned about its security unless we formally verify the [purity checker] is complete (i.e., rejecting all possible malicious behaviors including the reentrancy).

   However, we were answered that:
   > The external validation code is inevitable to allow various different signature schemes to be used by different validators. So, there is a trade-off between security vs flexibility.


1. We are concerned that the accountable safety of the protocol can be violated after many epochs without finalization (e.g., in the "network split" case).

   However, we were answered that:
   > It may be assumed that the maximum ESF (epochs since finalization) is sufficiently bound according to the reward-penalty model parameter values.






[b2a1189]: <https://github.com/ethereum/casper/blob/b2a1189506710c37bbdbbf3dc79ff383dbe13875/casper/contracts/simple_casper.v.py>
[Casper the Friendly Finality Gadget]: <https://arxiv.org/abs/1710.09437>
[ABSTRACT-CASPER]: <https://github.com/runtimeverification/verified-smart-contracts/blob/master/casper/abstract-casper.k>
[EIP 1011]: <https://eips.ethereum.org/EIPS/eip-1011>
[protocol verification]: <https://github.com/palmskog/caspertoychain>
[CASPER]: <https://github.com/runtimeverification/verified-smart-contracts/blob/master/casper/casper.k>
[CASPER-EVM]: <https://github.com/runtimeverification/verified-smart-contracts/blob/master/casper/casper-spec.ini>
[reward-penalty model]: <https://github.com/runtimeverification/verified-smart-contracts/blob/master/casper/reward-penalty-model.pdf>
[lemmas]: <https://github.com/runtimeverification/verified-smart-contracts/blob/master/casper/verification.k>
[signature validation code]: <https://github.com/ethereum/casper/blob/b2a1189506710c37bbdbbf3dc79ff383dbe13875/casper/contracts/simple_casper.v.py#L391-L403>
[purity checker]: <https://github.com/ethereum/casper/blob/master/casper/contracts/purity_checker.py>
[deprecated Casper FFG]: <https://medium.com/@djrtwo/casper-%EF%B8%8F-sharding-28a90077f121>
