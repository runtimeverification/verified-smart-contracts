# Formal Verification Methodology

Our methodology for formal verification of smart contracts is as follows.
First, we formalize the high-level business logic of the smart contracts, based on a typically informal specification provided by the client, to provide us with a precise and comprehensive specification of the functional correctness properties of the smart contracts.
This high-level specification needs to be confirmed by the client, possibly after several rounds of discussions and changes, to ensure that it correctly captures the intended behavior of their contract.
Then we refine the specification all the way down to the Ethereum Virtual Machine (EVM) level, often in multiple steps, to capture the EVM-specific details.
The role of the final EVM-level specification is to ensure that nothing unexpected happens at the bytecode level, that is, that only what was specified in the high-level specification will happen when the bytecode is executed.
To precisely reason about the EVM bytecode without missing any EVM quirks, we adopted [KEVM], a complete formal semantics of the EVM, and instantiated the [K-framework]'s [reachability logic theorem prover] to generate a correct-by-construction deductive program verifier for the EVM.
We use the verifier to verify the compiled EVM bytecode of the smart contract against its EVM-level specification.
Note that the Solidity compiler is not part of our trust base, since we directly verify the compiled EVM bytecode.
Therefore, our verification result does not depend on the correctness of the Solidity compiler.




## Disclaimer

This repository does not constitute legal or investment advice. The preparers of this repository present it as an informational exercise documenting the due diligence involved in the secure development of the target contract only, and make no material claims or guarantees concerning the contract's operation post-deployment. The preparers of this repository assume no liability for any and all potential consequences of the deployment or use of this contract.

*The formal verification result presented here only shows that the target contract behaviors meet the formal (functional) specifications. Moreover, the correctness of the generated formal proofs is conditioned by the correctness of the specifications and their refinement, by the correctness of the [KEVM], by the correctness of the [K-framework]'s [reachability logic theorem prover], and by the correctness of the [Z3] SMT solver. The presented result makes no guarantee about properties not specified in the formal specification. Importantly, the presented formal specification considers only the behaviors within the EVM, without considering the block/transaction level properties or off-chain behaviors, meaning that the verification result does not completely rule out the possibility of the contract being vulnerable to existing and/or unknown attacks.*

Smart contracts are still a nascent software arena, and their deployment and public offering carries substantial risk. This repository makes no claims that its analysis is fully comprehensive, and recommends always seeking multiple opinions and audits.

This repository is also not comprehensive in scope, excluding a number of components critical to the correct operation of this system.

The possibility of human error in the manual review process is very real, and we recommend seeking multiple independent opinions on any claims which impact a large number of funds.


## Resources

We use the [K-framework] and its verification infrastructure throughout the formal verification effort as mentioned above.
All of the formal specifications are mechanized within the K-framework as well.
Therefore, some background knowledge about the K-framework would be necessary for reading and fully understanding the formal specifications and reproducing the mechanized proofs.
We refer the reader to existing resources for background knowledge about the K-framework and its verification infrastructure as follows.

* [K-framework]
  * [Download] and [install]
  * [K tutorial]
  * [K editor support]
* [KEVM]: an executable formal semantics of the EVM in K
  * [Jellowpaper]: reader-friendly formatting of KEVM
  * [KEVM technical report]
* [K reachability logic prover]
  * [eDSL]: domain-specific language for EVM-level specifications



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
