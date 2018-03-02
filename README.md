# Formally Verified Smart Contracts

This repository contains smart contracts that have been formally verified by
[Runtime Verification](http://runtimeverification.com) and/or collaborators.

To verify a smart contract, we need to first produce a formal specification
stating *what* the smart contract is supposed to do.
This is often the most difficult part of the verification effort, requiring
sometimes several rounds of discussions and meetings with the owners of the
smart contract, to ensure that everybody is on the same page regarding the
intended functionality of the smart contract.
Not surprisingly, many bugs or opportunities for improvement in the smart
contract code are found at this early stage.
Then we need to show that the binary or low-level code
(e.g., [EVM binary](https://github.com/kframework/evm-semantics) or
[IELE code](https://github.com/runtimeverification/iele-semantics)) generated
by the compiler from the smart contract high level code
(e.g., [Solidity](https://solidity.readthedocs.io/en/develop/) or
[Vyper](https://github.com/ethereum/vyper)) indeed satisfies the specification.
In our approach the proofs use
[reachability logic](http://fsl.cs.illinois.edu/index.php/Reachability_Logic),
a generalization of Hoare logic, separation logic and modal logic, and are
performed using the [K framework](http://kframework.org).
The K framework takes a formal semantics of a language as trusted input
(e.g., that of [EVM](https://github.com/kframework/evm-semantics) or
[IELE](https://github.com/runtimeverification/iele-semantics)), and then uses
it to symbolically execute the smart contract exhaustively on all paths,
making use of SMT solvers like [Z3](https://github.com/Z3Prover/z3) to solve
the mathematical domain constraints.

## Pending

(Links to be added soon)

* **2018/??/??** Casper - Ethereum Foundation
* **2018/??/??** Fabian Vogelsteller's ICO contract and ICO schema

## Completed

* **2018/02/28** [Bihu KEY token operation contracts](bihu/README.md)

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

## Resources


We use the [K-framework] and its verification infrastructure throughout the formal verification effort.
All of the formal specifications are mechanized within the K-framework as well.
Therefore, some background knowledge about the K-framework would be necessary for reading and fully understanding the formal specifications and reproducing the mechanized proofs.
We refer the reader to the following resources for background knowledge about the K-framework and its verification infrastructure.

* [K-framework]
  * [Download] and [install]
  * [K tutorial]
  * [K editor support]
* [KEVM]: an executable formal semantics of the EVM in K
  * [Jellowpaper]: reader-friendly formatting of KEVM
  * [KEVM technical report]
* [K reachability logic prover]
  * [eDSL]: domain-specific language for EVM-level specifications
* [ERC20-K](https://github.com/runtimeverification/erc20-semantics):
a formal specification of the high-level business logic of
[ERC20](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md)
* [ERC20-EVM](https://github.com/kframework/evm-semantics/blob/verification/proofs/erc20):
an EVM-level refinement of ERC20-K
* ERC777-K (coming soon): a formal specification of the high-level
business logic of
[ERC777](https://github.com/ethereum/eips/issues/777)



[KEVM]: <https://github.com/kframework/evm-semantics>
[K-framework]: <http://www.kframework.org>
[reachability logic theorem prover]: <http://fsl.cs.illinois.edu/index.php/Semantics-Based_Program_Verifiers_for_All_Languages>
[K reachability logic prover]: <http://fsl.cs.illinois.edu/index.php/Semantics-Based_Program_Verifiers_for_All_Languages>
[Download]: <https://github.com/kframework/k5/releases>
[install]: <https://github.com/kframework/k5/blob/master/README.md>
[K tutorial]: <https://github.com/kframework/k5/tree/master/k-distribution/tutorial>
[K editor support]: <https://github.com/kframework/k-editor-support>
[Jellowpaper]: <https://jellopaper.org/>
[KEVM technical report]: <https://www.ideals.illinois.edu/handle/2142/97207>
[Z3]: <https://github.com/Z3Prover/z3>


## Disclaimer

This repository does not constitute legal or investment advice. The preparers of this repository present it as an informational exercise documenting the due diligence involved in the secure development of the target contract only, and make no material claims or guarantees concerning the contract's operation post-deployment. The preparers of this repository assume no liability for any and all potential consequences of the deployment or use of this contract.

*The formal verification result presented here only shows that the target contract behaviors meet the formal (functional) specifications. Moreover, the correctness of the generated formal proofs is conditioned by the correctness of the specifications and their refinement, by the correctness of the [KEVM], by the correctness of the [K-framework]'s [reachability logic theorem prover], and by the correctness of the [Z3] SMT solver. The presented result makes no guarantee about properties not specified in the formal specification. Importantly, the presented formal specification considers only the behaviors within the EVM, without considering the block/transaction level properties or off-chain behaviors, meaning that the verification result does not completely rule out the possibility of the contract being vulnerable to existing and/or unknown attacks.*

Smart contracts are still a nascent software arena, and their deployment and public offering carries substantial risk. This repository makes no claims that its analysis is fully comprehensive, and recommends always seeking multiple opinions and audits.

This repository is also not comprehensive in scope, excluding a number of components critical to the correct operation of this system.

The possibility of human error in the manual review process is very real, and we recommend seeking multiple independent opinions on any claims which impact a large number of funds.

