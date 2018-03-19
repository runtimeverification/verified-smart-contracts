# General Instruction for Reproducing Mechanized Proofs

The formal specifications presented in this repository are written in [eDSL], a domain-specific language for EVM specifications, which must be known in order to thoroughly understand the specifications.
Refer to [resources] for background on our technology.
Each of the specifications provides the [eDSL] specification template parameters.
The full [K] [reachability logic] specifications are automatically derived by instantiating a specification template with these template parameters.

#### Generating Full Reachability Logic Specifications

Run the following command in the root directory of this repository, and it will generate the full [reachability logic] specifications, under the directory `specs`, for all of the verified contracts presented in this repository:

```
$ make
```

#### Reproducing Proofs

To prove that the specifications are satisfied by (the compiled EVM bytecode of) the target contracts, run the EVM verifier (under the [KEVM] root directory, see below) as follows:

```
$ ./kevm prove tests/proofs/specs/<project>/<target>-spec.k
```

where `<project>/<target>` is the target contract (or function) to verify.

<!--
The above command essentially executes the following command:

```
$ kprove specs/<project>/<target>-spec.k -m VERIFICATION --z3-executable -d /path/to/evm-semantics/.build/java
```
-->

#### Installing the EVM Verifier

The EVM verifier is part of the [KEVM] project.  The following commands will successfully install it, provided that all of the dependencies are installed.

```
$ git clone git@github.com:kframework/evm-semantics.git
$ cd evm-semantics
$ make deps
$ make
```

For detailed instructions on installing and running the EVM verifier, see [KEVM]'s [Installing/Building](https://github.com/kframework/evm-semantics/blob/master/README.md#installingbuilding) and [Example Usage](https://github.com/kframework/evm-semantics/blob/master/README.md#example-usage) pages.

## [Resources](/README.md#resources)

## [Disclaimer](/README.md#disclaimer)

[K]: <http://www.kframework.org>
[eDSL]: </resources/edsl.md>
[KEVM]: <https://github.com/kframework/evm-semantics>
[reachability logic]: <http://fsl.cs.illinois.edu/index.php/Semantics-Based_Program_Verifiers_for_All_Languages>
[resources]: </README.md#resources>
