# Bihu Smart Contract Formal Verification

We present a formal verification of Bihu KEY token operation contracts, upon request from the [Bihu] team represented by Dr. Bin Lu (Gulu) and Mr. Huafu Bao.

Bihu is a blockchain-based ID system, and [KEY] is the utility token for the Bihu ID system and community.

The smart contracts requested to be formally verified are the ones for operating the KEY tokens.
The [Solidity source code][src] of those contracts and their [informal specification] are publicly available.

For more details, refer to our [formal verification report].


## Scope

The target contracts of our formal verification are the following, where we took the Solidity source code from Bihu's Github repository, https://github.com/bihu-id/bihu-contracts, commit [f9a7ab65](https://github.com/bihu-id/bihu-contracts/tree/f9a7ab65181cc204332e17df30406612d5d350ef/src):

* [KeyRewardPool.sol](https://github.com/bihu-id/bihu-contracts/blob/f9a7ab65181cc204332e17df30406612d5d350ef/src/KeyRewardPool.sol)
* [WarmWallet.sol](https://github.com/bihu-id/bihu-contracts/blob/f9a7ab65181cc204332e17df30406612d5d350ef/src/WarmWallet.sol)

More specifically, we formally verified the functional correctness of the following two functions:

* [KeyRewardPool.collectToken()](https://github.com/bihu-id/bihu-contracts/blob/f9a7ab65181cc204332e17df30406612d5d350ef/src/KeyRewardPool.sol#L50-L85)
* [WarmWallet.forwardHotWallet()](https://github.com/bihu-id/bihu-contracts/blob/f9a7ab65181cc204332e17df30406612d5d350ef/src/WarmWallet.sol#L69-L81)

## Mechanized Specifications and Proofs

Following our [formal verification methodology], we formalized the high-level specification of the smart contracts, based on the [informal specification], and Bihu team confirmed that the specification correctly captures the intended behavior of their contract.
Then, we refined the specification all the way down to the Ethereum Virtual Machine (EVM) level to capture the EVM-specific details.
The EVM-level specification is fully mechanized within and automatically verified by our EVM verifier, a correct-by-construction deductive program verifier derived from [KEVM] and [K-framework]'s [reachability logic prover].

The following are the mechainized EVM-level specifications of the two target functions:

* EVM specification of `collectToken`: [collectTokens-spec.ini]
* EVM specification of `forwardHotWallet`: [forwardToHotWallet-spec.ini]

To prove that the specification is satisfied by (the compiled EVM bytecode of) each of the target function, run our EVM verifier as follows:

```
$ kprove collectTokens-spec.k    -m VERIFICATION-LEMMAS --z3-executable -d /path/to/evm-semantics/.build/java
$ kprove forwardHotWallet-spec.k -m VERIFICATION-LEMMAS --z3-executable -d /path/to/evm-semantics/.build/java
```

For the detailed instruction of installing and running the EVM verifier, refer to [INSTRUCTION](INSTRUCTION.md).


## [Resources](methodology.md#resources)

[Bihu]: <https://bihu.com/>
[KEY]: <https://etherscan.io/address/0x4cd988afbad37289baaf53c13e98e2bd46aaea8c#code>
[formal verification methodology]: <methodology.md>
[KEVM]: <https://github.com/kframework/evm-semantics>
[K-framework]: <http://www.kframework.org>
[reachability logic prover]: <http://fsl.cs.illinois.edu/index.php/Semantics-Based_Program_Verifiers_for_All_Languages>
[collectTokens-spec.ini]: <collectTokens-spec.ini>
[forwardToHotWallet-spec.ini]: <forwardToHotWallet-spec.ini>
[informal specification]: <https://docs.google.com/document/d/1-PilHhInQxGod7FZNbtfv2bbgV1045ROT5TO3WLhDOE>
[src]: <https://github.com/bihu-id/bihu-contracts/tree/f9a7ab65181cc204332e17df30406612d5d350ef/src>
[formal verification report]: <bihu-contracts-verification-report.pdf>
