# Formal Specification and Verification of Gnosis MultiSigWallet Smart Contract

We propose to formally verify the Gnosis MultiSigWallet implementation in Solidity. We refer to the implementation at https://github.com/gnosis/safe-contracts/tree/feature/optimize_personal_edition/contracts

Specifically, we propose to define a formal K specification of the MultiSigWallet code, addressing the *what* question: what is the MultiSigWallet code precisely supposed to do?  Or more rigorously, what is each of its functions supposed to do?  The specification will consist of a set of rules stating pre-/post-conditions for the functions, and the (contract-level) invariants maintained by those functions.  We will take the MultiSigWallet code and the specification, and verify the code against the specification using the K program verifier.



## Scope of Verification

Our verification target contract is GnosisSafePersonalEdition, which inherits other sub-contracts as follows.

```
+ GnosisSafePersonalEdition
  + MasterCopy
    + SelfAuthorized
  + GnosisSafe
    + ModuleManager
    + OwnerManager
  + SignatureValidator
+ Proxy
```


## Verification Properties

We outline the properties we consider to verify.

Most importantly, we will formally specify and verify the *full functional correctness* of the following safety-critical functions:
- The public authorized functions,
- The internal functions, and
- The `execTransaction*` family of functions.

We will also consider both the security-related properties, and ￼￼the correctness of certain safety-critical Solidity language features on which the security properties are highly reliant. These will be incorporated into the functional correctness specification.

Examples of the security-related properties are:

- Integrity of the internal state variables:
  - The internal state variables are updated only by the authorized functions.
  - The authorized functions are never (internally) called by the non-authorized functions except the `execute*` family.
  - The `execute*` family of functions can be called only by either `setup`, `requireTxGas`, or the `execTransaction*` family.
- `setup` cannot be called more than once.
- `threshold` is greater than 0 after `setup`.
- `nonce` never decreases. (important for the reentrancy blocking mechanism)

Examples of the compilation correctness of the safety-critical Solidity features are:

- The `authorized` functions can be called only when `this == msg.sender`.
- The internal functions cannot be called from outside (i.e., via the message-call).
- The internal state variables have no getter.
- The public state variables (including constants) have a getter.
- The view/pure functions do not modify the storage (and possibly hold more desirable properties).
- The overwritten constants are not accessible.


### Assumptions

Our formal proofs will be built on the top of the following assumptions about the execution environment outside the contract:

- The correctness of the cryptographic primitives (e.g., the elliptic curve signature algorithm) and their practical assumptions (e.g., no hash collision during the operation): This assumption is orthogonal to the MultiSigWallet implementation, and required in general for the security of the entire blockchain ecosystem.
- The correctness of the client code and its usage scenario of the MultiSigWallet contract: The client code is a moving target, and beyond the scope of the proposed verification effort.


**NOTE**: There must exist a discrepancy between the intended business logic and the formal specification model, since it is inevitable to make an assumption about certain unknowns of the execution environment (e.g., the correctness of the network node implementations). While we can extend our formal model to capture more of those unknowns, in general, extending a formal model is open-ended and cannot be absolutely complete. Thus, we note that it is critical for Gnosis team to carefully review and confirm if the formal model sufficiently captures the important details.




## Proposed Work

### Task 1. Define a high-level formal specification of GnosisSafePersonalEdition in K.

First, we will formalize the high-level business logic of the smart contracts, based on the contract source code and the informal discussion with the Gnosis team, to provide us with a precise and comprehensive specification of the functional correctness properties of the smart contracts. This high-level specification will be confirmed by the Gnosis team, possibly after several rounds of discussions and changes, to ensure that it correctly captures the intended behavior of the contract.

We would like to re-emphasize the importance of having the right specification of the contract, and that we will need the Gnosis team's willingness to help revise it as early as possible after the start of the project, since the final verification effort is only as good as the formal specification is.


### Task 2. Refine the high-level specification to the EVM level.

We will refine the high-level specification all the way down to the EVM level, often in multiple steps, to capture the EVM-specific details. The role of the final EVM-level specification is to ensure that nothing unexpected happens at the bytecode level, that is, that only what was specified in the high-level specification will happen when the bytecode is executed.


### Task 3. Verify the compiled EVM bytecode against the EVM-level specification.

Finally, we will verify the compiled EVM bytecode of the contract against the EVM-level specification, using the KEVM verifier.

The KEVM verifier is a correct-by-construction deductive program verifier for the EVM, automatically derived from the KEVM, a complete formal semantics of the EVM, by instantiating the K framework's reachability logic theorem prover.
We adopted the KEVM to precisely reason about the EVM bytecode without missing any EVM quirks.
Note that the Solidity compiler is not part of our trust base, since we directly verify the compiled EVM bytecode. Our verification results do not depend on the correctness of the compiler. Indeed, we will verify the compiled bytecode provided by the Gnosis team: https://github.com/gnosis/safe-contracts/releases/tag/v0.0.1



## Milestones

We plan to complete this project in 12 weeks.

We will internally schedule our effort to complete the entire project in 8 weeks. This way, we will have 4 weeks to deal with unexpected issues.  Below we list our intended internal milestones, with our target dates which may differ from the actual final dates.

- Milestone 1. By end of 2nd week. Have Task 1 done. Have ~50% of Task 2 done. Have ~25% of Task 3 done.
- Milestone 2. By end of 4th week. Have Task 2 done. Have ~50% of Task 3 done.
- Milestone 3. By end of 8th week. Have Task 3 done.

Throughout the project we will stay in close contact with the Gnosis team and promptly report any bug that we find.  It is in our interest that these bugs are fixed as quickly as possible, because otherwise we will not be able to complete our project.


# Appendix

## Contract Components

GnosisSafePersonalEdition, the target of our verification effort, consists of the following components:


Modifier:

```
    modifier authorized()
```

Events:

```
    event ContractCreation(address newContract);
    event ExecutionFailed(bytes32 txHash);
```

State variables:

```
    address masterCopy;
    mapping (address => address) internal modules;
    mapping (address => address) internal owners;
    uint256 ownerCount;
    uint256 internal threshold;
    uint256 public nonce;
```

Constants

```
    address public constant SENTINEL_MODULES = address(0x1);
    address public constant SENTINEL_OWNERS = address(0x1);
    string public constant NAME = "Gnosis Safe Personal Edition";
    string public constant VERSION = "0.0.1";
```


Setup functions:

```
    function setup(address[] _owners, uint8 _threshold, address to, bytes data) public

    function setupModules(address to, bytes data) internal
    function setupOwners(address[] _owners, uint8 _threshold) internal
```

Execution functions:

```
    function execTransactionFromModule(address to, uint256 value, bytes data, Enum.Operation operation) public returns (bool success)
    function execTransactionAndPaySubmitter(address to, uint256 value, bytes data, Enum.Operation operation, uint256 safeTxGas, uint256 dataGas, uint256 gasPrice, address gasToken, bytes signatures) public returns (bool success)

    function execute(address to, uint256 value, bytes data, Enum.Operation operation, uint256 txGas) internal returns (bool success)
    function executeCall(address to, uint256 value, bytes data, uint256 txGas) internal returns (bool success)
    function executeDelegateCall(address to, bytes data, uint256 txGas) internal returns (bool success)
    function executeCreate(bytes data) internal returns (address newContract)
```

Authorized functions

```
    function changeMasterCopy(address _masterCopy) public authorized

    function enableModule(Module module) public authorized
    function disableModule(Module prevModule, Module module) public authorized

    function addOwnerWithThreshold(address owner, uint8 _threshold) public authorized
    function removeOwner(address prevOwner, address owner, uint8 _threshold) public authorized
    function swapOwner(address prevOwner, address oldOwner, address newOwner) public authorized
    function changeThreshold(uint8 _threshold) public authorized

    function requiredTxGas(address to, uint256 value, bytes data, Enum.Operation operation) public authorized returns (uint256)
```

View/pure functions

```
    function getModules() public view returns (address[])
    function getThreshold() public view returns (uint8)
    function isOwner(address owner) public view returns (bool)
    function getOwners() public view returns (address[])

    function getTransactionHash(address to, uint256 value, bytes data, Enum.Operation operation, uint256 safeTxGas, uint256 dataGas, uint256 gasPrice, address gasToken, uint256 _nonce) public view returns (bytes32)
    function recoverKey(bytes32 txHash, bytes messageSignature, uint256 pos) pure public returns (address) 
    function signatureSplit(bytes signatures, uint256 pos) pure public returns (uint8 v, bytes32 r, bytes32 s)
    function checkHash(bytes32 txHash, bytes signatures) internal view
```
