## Formal Verification Methodology

Our methodology for formal verification of smart contracts is as follows.
First, we formalize the high-level business logic of the smart contracts, based on a typically informal specification provided by the client, to provide us with a precise and comprehensive specification of the functional correctness properties of the smart contracts.
This high-level specification needs to be confirmed by the client, possibly after several rounds of discussions and changes, to ensure that it correctly captures the intended behavior of their contracts.
Then we refine the specification all the way down to the Ethereum Virtual Machine (EVM) level, often in multiple steps, to capture the EVM-specific details.
The role of the final EVM-level specification is to ensure that nothing unexpected happens at the bytecode level, that is, that only what was specified in the high-level specification will happen when the bytecode is executed.
To precisely reason about the EVM bytecode without missing any EVM quirks, we adopted [KEVM], a complete formal semantics of the EVM, and instantiated the [K-framework]'s [reachability logic theorem prover] to generate a correct-by-construction deductive program verifier for the EVM.
We use the verifier to verify the compiled EVM bytecode of the smart contract against its EVM-level specification.
Note that the Solidity compiler is not part of our trust base, since we directly verify the compiled EVM bytecode.
Therefore, our verification result does not depend on the correctness of the Solidity compiler.
