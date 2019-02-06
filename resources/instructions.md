# General Instruction for Reproducing Mechanized Proofs

The formal specifications presented in this repository are written in [eDSL], a domain-specific language for EVM specifications, which must be known in order to thoroughly understand the specifications.
Refer to [resources] for background on our technology.
Each of the specifications provides the [eDSL] specification template parameters.
The full [K] [reachability logic] specifications are automatically derived by instantiating a specification template with these template parameters.

#### Generating Full Reachability Logic Specifications

Run the following command in the root directory of this repository, and it will generate the full [reachability logic] specifications, under the directory `specs`, for the smart contract(s) in the `<project>` directory:

```
$ make -C <project> split-proof-tests
```

#### Reproducing Proofs

To prove that the specifications are satisfied by (the compiled EVM bytecode of) the target contracts, run the EVM verifier as follows:

```
$ make -C <project> test
```

#### Installing the EVM Verifier

The EVM verifier is part of the [KEVM] project.  The following commands will successfully install it, provided that all of the dependencies are installed.

```
$ make -C <project> deps
```

For detailed instructions on installing and running the EVM verifier, see [KEVM]'s [Installing/Building](https://github.com/kframework/evm-semantics/blob/master/README.md#installingbuilding) and [Example Usage](https://github.com/kframework/evm-semantics/blob/master/README.md#example-usage) pages.

## [Resources](/README.md#resources)

## [Disclaimer](/README.md#disclaimer)

[K]: <http://www.kframework.org>
[eDSL]: </resources/edsl.md>
[KEVM]: <https://github.com/kframework/evm-semantics>
[reachability logic]: <http://fsl.cs.illinois.edu/index.php/Semantics-Based_Program_Verifiers_for_All_Languages>
[resources]: </README.md#resources>
