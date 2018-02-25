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

## Resources

* [KEVM](https://github.com/kframework/evm-semantics/):
formal semantics of the EVM in K
   * [Jellowpaper](https://jellopaper.org/): a more readable variant of KEVM
   * [KEVM technical report](http://hdl.handle.net/2142/97207)
* [ERC20-K](https://github.com/runtimeverification/erc20-semantics):
a formal specification of the high-level business logic of
[ERC20](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md)
* [ERC20-EVM](https://github.com/kframework/evm-semantics/blob/verification/proofs/erc20):
an EVM-level refinement of ERC20-K
* ERC777-K (coming soon): a formal specification of the high-level
business logic of
[ERC777](https://github.com/ethereum/eips/issues/777)
