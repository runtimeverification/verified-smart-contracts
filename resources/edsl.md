eDSL: Domain-Specific Language for EVM Specifications
=====================================================

The [K-framework] provides a [reachability logic theorem prover] that is parameterized by the langauge semantics.
Instantiated with the [KEVM], a complete formal semantics of the Ethereum Virtual Machine (EVM),
the K prover yields a correct-by-construction deductive program verifer for the EVM.
The EVM verifier takes an EVM bytecode and a specification as inputs, and automatically proves that the bytecode satisfies the specification, if it is the case.
The EVM specification essentially specifies the pre- and post-conditions of the EVM bytecode in the form of reachability logic claims.

We present a domain-specific language (DSL) for the EVM specifications, called eDSL, to succintly specify the specifications.
The eDSL consists of two parts:

* [eDSL High-Level Notations](https://github.com/kframework/evm-semantics/blob/master/edsl.md)
* [eDSL Specifications](edsl-spec.md)
  * [eDSL Specification Templates](edsl-spec.md#edsl-specification-template)
  * [eDSL Template Parameters](edsl-spec.md#edsl-template-parameters)

[KEVM]: <https://github.com/kframework/evm-semantics>
[K-framework]: <http://www.kframework.org>
[reachability logic theorem prover]: <http://fsl.cs.illinois.edu/index.php/Semantics-Based_Program_Verifiers_for_All_Languages>
