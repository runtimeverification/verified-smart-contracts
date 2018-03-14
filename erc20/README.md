Formal Verification of ERC20 Token Contracts
============================================

We present full formal verification of functional correctness of ERC20 token contracts.
First, we developed a formalization of the high-level business logic, called [ERC20-K], based on the [ERC20] standard document, to provide us with a precise and comprehensive specification of the desired functional correctness properties of the smart contracts.
Then we refined the specification down to the Ethereum Virtual Machine (EVM) level to capture the EVM-specific details.
The role of the EVM-level specification is to ensure that nothing unexpected happens at the bytecode level, that is, that only what was specified in the high-level specification will happen when the bytecode is executed.
To precisely reason about the EVM bytecode without missing any EVM quirks we adopted [KEVM], a complete formal semantics of the EVM, and instantiated the [K-framework]'s [reachability logic theorem prover] to generate a correct-by-construction deductive program verifier for the EVM.
We used this verifier to verify the compiled EVM bytecode of the smart contract against its EVM-level specification.
Note that the compiler of a high-level contract language (such as Solidity or Vyper) is not part of our trust base, since we directly verify the compiled EVM bytecode.
Therefore, our verification results do not depend on the correctness of the compilers.

Currently Verified ERC20 Token Contracts
----------------------------------------

We took the following ERC20 token contract implementations as targets for formal verification against [ERC20-K] and its refinement [ERC20-EVM], and found deviations as follows:

-   [Vyper ERC20 token](vyper/README.md): fully *conforming* to the ERC20 standard.
-   [OpenZeppelin ERC20 token](zeppelin/README.md): *conforming* to the standard, but:
    -   Rejecting transfers to address `0`.
-   [HackerGold (HKG) ERC20 token](hkg/README.md): *deviating* from the standard:
    -   No arithmetic overflow protection.
    -   No `totalSupply` function.
    -   Rejecting transfers of `0` values.
    -   Returning `false` instead of throwing exception in case of failure of `transfer*` functions.
-   [MyKidsEducationToken ERC20 token](hobby/README.md) (written as a personal hobby): *buggy* implementation:
    -   Typographical bug: `<=` instead of `>=`.
    -   Inadequate overflow detection for self-transfers
    -   Rejecting transfers of `0` values.
    -   Returning `false` instead of throwing exception in case of failure of `transfer*` functions.

## [Resources](/README.md#resources)

## [Disclaimer](/README.md#disclaimer)


[KEVM]: <https://github.com/kframework/evm-semantics>
[K-framework]: <http://www.kframework.org>
[reachability logic theorem prover]: <http://fsl.cs.illinois.edu/index.php/Semantics-Based_Program_Verifiers_for_All_Languages>

[ERC20]: <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md>
[ERC20-K]: <https://github.com/runtimeverification/erc20-semantics>
[ERC20-EVM]: </resources/erc20-evm.md>
<!--
[Vyper ERC20 token]: <https://github.com/ethereum/vyper/blob/master/examples/tokens/ERC20_solidity_compatible/ERC20.v.py>
[OpenZeppelin ERC20 token]: <https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC20/StandardToken.sol>
[HackerGold (HKG) ERC20 token]: <https://github.com/ether-camp/virtual-accelerator/blob/master/contracts/StandardToken.sol>
[KidsEducationToken]: <https://github.com/ethereum/mist/issues/3301>
-->
