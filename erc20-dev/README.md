Formal Verification of ERC20 Smart Contracts
============================================

We present full functional correctness verification of ERC20 token contracts.
First, we formalize the high-level business logic, called [ERC20-K], based on the [ERC20] standard document, to provide a precise and comprehensive specification of the desired functional correctness properties.
Then, we refine the specification down to EVM level to capture EVM-specific behaviors, ensuring nothing unexpected happens in the actual execution.
Custom abstractions and lemmas are provided to the K proof engine in the common [verification] lemma file.
Multiple implementations of ERC20 tokens are verified here as examples for future users who wish to verify their own contracts.
We will be publishing a technical report on ERC20 verification soon with more information.

Checking Proofs
---------------

To reproduce the verification results for all of the ERC20 token contracts, simply run the following command in the root directory of this repository:

```sh
make proof-test
```

The above command will automatically build and install the KEVM semantics and the K reachability logic prover if they haven't been, which requires some dependencies installed.

Proof Structure
---------------

The file <tmpl.k> provides the main specification template which is filled in with details from each individual token/function to be verified.
Each of the individual token specifications are broken into two files, at `TOKEN/pgm-TOKEN.ini` and `TOKEN/spec-TOKEN.ini` (eg. `viper/pgm-viper.ini` and `viper/spec-viper.ini`).
This makes it easier to see the differences between the different ERC20 implementations here.

The verification process is broken into several steps (for a given `TOKEN`).

1.  The `TOKEN/pgm-TOKEN.ini` is read to populate the values `{COMPILER}`, `{_BALANCES}`, etc... in the file `TOKEN/spec-TOKEN.ini`.
    If a variables in `*.ini` is called `variable_name`, it is used to populate the `{VARIABLE_NAME}` value in the target file.

2.  Similarly, the resulting fields are read from `TOKEN/spec-TOKEN.ini` and substituted into the file `tmpl.k`, to generate the final specification file.

3.  The K prover is invoked on the resulting file using `./kevm prove path/to/final/filename-spec.k`.

Currently Verified ERC20 Token Contracts
----------------------------------------

We tried to verify the following ERC20 token contract implementations against [ERC20-K] and its refinement [ERC20-EVM], and found deviations as follows:

-   [Viper ERC20 token] `viper/*-viper.ini`: fully *conforming* to the ERC20 standard.
-   [OpenZeppelin ERC20 token] `zeppelin/*-zeppelin.ini`: *conforming* to the standard, but:
    -   Rejecting transfers to address `0`.
-   [HackerGold (HKG) ERC20 token] `hkg/*-hkg.ini`: *deviating* from the standard:
    -   No arithmetic overflow protection.
    -   No `totalSupply` function.
    -   Rejecting transfers of `0` values.
    -   Returning `false` instead of throwing exception in case of failure of `transfer*` functions.
-   An ERC20 token of a personal hobby, called [KidsEducationToken] `hobby/*-hobby.ini`: *buggy* implementation:
    -   Typographical bug: `<=` instead of `>=`.
    -   Incorrect overflow detection for self-transfers
    -   Rejecting transfers of `0` values.
    -   Returning `false` instead of throwing exception in case of failure of `transfer*` functions.

Resources
=========

[ERC20-K]: <https://github.com/runtimeverification/erc20-semantics>
[ERC20]: <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md>
[verification]: <../../verification.md>
[Viper ERC20 token]: <https://github.com/ethereum/vyper/blob/master/examples/tokens/ERC20_solidity_compatible/ERC20.v.py>
[OpenZeppelin ERC20 token]: <https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC20/StandardToken.sol>
[HackerGold (HKG) ERC20 token]: <https://github.com/ether-camp/virtual-accelerator/blob/master/contracts/StandardToken.sol>
[KidsEducationToken]: <https://github.com/ethereum/mist/issues/3301>
