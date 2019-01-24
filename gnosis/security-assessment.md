# Security Audit of GnosisSafe contract

## Methodology

In this section we analyzed for security issues the core GnosisSafe contract.
The version audited is [commit 14495428954366dcf812acfa11e54c81b186332d](https://github.com/gnosis/safe-contracts/commit/14495428954366dcf812acfa11e54c81b186332d)
, compiled with Solidity v0.5.0. 
We only analyzed the core contract, without extensions, e.g. 
[Proxy.sol](https://github.com/gnosis/safe-contracts/blob/14495428954366dcf812acfa11e54c81b186332d/contracts/proxies/Proxy.sol)
acting as proxy for [GnosisSafe.sol](https://github.com/gnosis/safe-contracts/blob/bfb8abac580d76dd44f68307a5356a919c6cfb9b/contracts/GnosisSafe.sol) .

We used as reference [an extensive list](https://github.com/runtimeverification/verified-smart-contracts/wiki/List-of-Security-Vulnerabilities).
of common security vulnerabilities and bugs in EVM and Solidity.
In addition, we inspected the code for vulnerabilities not present in the list, 
with focus on external contract calls.

Next we present the list of discovered security issues, followed by our 
assessment of vulnerabilities.


## Scope

The scope of the current engagement is the GnosisSafe contract without enabling any add-on modules. Specifically, this includes the following functions:

* `executeTransaction` of `GnosisSafe.sol`:
  * only for the case of `operation == CALL` and payment in Ether.
  * including `encodeTransactionData`, `checkSignatures`, and `handlePayment` functions.
* `changeMasterCopy` of `MasterCopy.sol`
* `addOwner`, `removeOwner`, and `swapOwner` of `OwnerManager.sol`
* `enableModule`, and `disableModule` of `ModuleManager.sol`
* `execTransactionFromModule` of `ModuleManager.sol`
  * only for the case that `modules` is empty.

The security assessment is limited in scope within the boundary of the Solidity contract only.


## Disclaimers

This report does not constitute legal or investment advice. The preparers of this report
present it as an informational exercise documenting the due diligence involved in the secure
development of the target contract only, and make no material claims or guarantees concerning
the contract’s operation post-deployment. The preparers of this report assume no
liability for any and all potential consequences of the deployment or use of this contract.

Smart contracts are still a nascent software arena, and their deployment and public
offering carries substantial risk. This report makes no claims that its analysis is fully comprehensive,
and recommends always seeking multiple opinions and audits.

The possibility of human error in the manual review process is very real, and we recommend
seeking multiple independent opinions on any claims which impact a large number of
funds.

## Security Vulnerabilities

### Reentrancy attack in `execTransaction`

To protect from reentrancy attacks, GnosisSafe uses storage field `nonce`, 
which is incremented during each transaction. 
However, there are 3 external calls performed during a transaction, 
which all have to be guarded from reentrancy.

Below is the code for `execTransacion`, the main function of GnosisSafe:
```
function execTransaction(
    address to,
    uint256 value,
    bytes calldata data,
    Enum.Operation operation,
    uint256 safeTxGas,
    uint256 dataGas,
    uint256 gasPrice,
    address gasToken,
    address payable refundReceiver,
    bytes calldata signatures
)
    external
    returns (bool success)
{
    uint256 startGas = gasleft();
    bytes memory txHashData = encodeTransactionData(
        to, value, data, operation, // Transaction info
        safeTxGas, dataGas, gasPrice, gasToken, refundReceiver, // Payment info
        nonce
    );
    require(checkSignatures(keccak256(txHashData), txHashData, signatures, true), 
        "Invalid signatures provided");
    // Increase nonce and execute transaction.
    nonce++;
    require(gasleft() >= safeTxGas, "Not enough gas to execute safe transaction");
    // If no safeTxGas has been set and the gasPrice is 
    // 0 we assume that all available gas can be used
    success = execute(to, value, data, operation, 
        safeTxGas == 0 && gasPrice == 0 ? gasleft() : safeTxGas);
    if (!success) {
        emit ExecutionFailed(keccak256(txHashData));
    }

    // We transfer the calculated tx costs to the tx.origin 
    // to avoid sending it to intermediate contracts that have made calls
    if (gasPrice > 0) {
        handlePayment(startGas, dataGas, gasPrice, gasToken, refundReceiver);
    }
}
```

The main external call managed by this transaction (hereafter referred as "payload") is performed in function
[execute](https://github.com/gnosis/safe-contracts/blob/bfb8abac580d76dd44f68307a5356a919c6cfb9b/contracts/GnosisSafe.sol#L95).
After payload is executed, the original caller or another account specified in transaction data is refunded for gas cost in 
[handlePayment](https://github.com/gnosis/safe-contracts/blob/bfb8abac580d76dd44f68307a5356a919c6cfb9b/contracts/GnosisSafe.sol#L102).
Both these calls are performed after the nonce
[is incremented](https://github.com/gnosis/safe-contracts/blob/bfb8abac580d76dd44f68307a5356a919c6cfb9b/contracts/GnosisSafe.sol#L92).
Consequently, it is not possible to execute the same transaction multiple times
from within these calls.

However, there is one more external call possible inside
[checkSignatures](https://github.com/gnosis/safe-contracts/blob/bfb8abac580d76dd44f68307a5356a919c6cfb9b/contracts/GnosisSafe.sol#L90) 
phase, which calls [an external contract](https://github.com/gnosis/safe-contracts/blob/bfb8abac580d76dd44f68307a5356a919c6cfb9b/contracts/GnosisSafe.sol#L161) 
managed by an owner to validate the signature using 
[EIP-1271](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1271.md) signature validation mechanism:
```
function checkSignatures(bytes32 dataHash, bytes memory data, 
                         bytes memory signatures, bool consumeHash)
    public
    returns (bool)
{
    for (i = 0; i < threshold; i++) {
        (v, r, s) = signatureSplit(signatures, i);
        // If v is 0 then it is a contract signature
        if (v == 0) {
            // When handling contract signatures the address of the contract 
            // is encoded into r
            currentOwner = address(uint256(r));
            bytes memory contractSignature;
            // solium-disable-next-line security/no-inline-assembly
            assembly {
                // The signature data for contract signatures is appended to the 
                // concatenated signatures and the offset is stored in s
                contractSignature := add(add(signatures, s), 0x20)
            }
            if (!ISignatureValidator(currentOwner)
              .isValidSignature(data, contractSignature)) {
                return false;
            }
        } else
            ...
        }
        if (currentOwner <= lastOwner || owners[currentOwner] == address(0)) {
            return false;
        }
        lastOwner = currentOwner;
    }
    return true;
}
```


This call is performed BEFORE nonce is incremented 
[here](https://github.com/gnosis/safe-contracts/blob/bfb8abac580d76dd44f68307a5356a919c6cfb9b/contracts/GnosisSafe.sol#L92),
thus is not guarded for reentrancy.

An owner using EIP-1271 signature validation may use this vulnerability to
run the same payload multiple times, although it was approved by other owners to run only once.
The limit of how many times a transaction can run recursively is given by call gas and block gas limit,
thus the malicious owner will call this transaction with a lot of gas allocated.
The most likely beneficiary of this attack is the owner who initiated the transaction.
Yet if a benign owner calls another malicious contract for the signature validation, 
the malicious contract can exploit it even if he is not an owner.

#### Attack Scenario

1. Suppose we have a Gnosis safe managed by several owners, which controls access to an account that holds ERC20 tokens. At some point they agree to transfer X tokens from the safe to the personal account of owner 1.

Conditions required for this attack to be possible:
(a). Owner 1 is a contract that uses [EIP-1271](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1271.md) signature validation mechanism.
(b). All other owners use either EIP-1271 or ECSDA signatures. (See [this page](https://gnosis-safe.readthedocs.io/en/latest/contracts/signatures.html) for the 3 types of signature validation.)

2. Owner 1 generates the transaction data for this transfer and ensures that allocated gas is 10x required amount to complete the transaction.

3. Owner 1 requests signatures for this transaction from the other owners.

4. Owner 1 registers a malicious `ISignatureValidator` contract into his own account, that once invoked, will call the Gnosis Safe with the same call data as long as there is enough gas, then return true.

5. Owner 1 generates a signature for the transaction, of type [EIP-1271](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1271.md), e.g. it will call the `ISignatureValidator`.

6. Owner 1 calls the Gnosis Safe with the transaction data and all the signatures.

7. During signature verification phase, Gnosis Safe invokes the malicious ISignatureValidator, that successfully calls the safe again with the same data, recursively, 9 more times.

8. In the end, Owner 1 receives into his account 10X the amount of tokens approved by the other owners.

**Recommendation:**
Increment `nonce` before calling `checkSignatures`.

### `ISignatureValidator` gas and refund abuse
The account that initiated the transaction can consume large amounts of gas for free, unnoticed by other owners, and possibly receive a refund larger than the amount of gas consumed.
This vulnerability is specific to GnosisSafe; it is not listed in our reference list of known vulnerabilities.

The attack is possible due to a combination of factors.
First, GnosisSafe emits a refund at the end of transaction, for the amount of gas consumed.
The target of the refund is either transaction initiator `tx.origin` (by default) or some other account
given by transaction parameter `refundReceiver`.
This currency of the refund may be either Ether by default, or some ERC20 token with a specified price per unit.
Refund token is given by transaction parameters `gasPrice`, `gasToken`.
All those transaction parameters must be signed by the required amount of owners, just like the payload. 

The second factor is that gas allocated for the whole `execTransaction` is not part of transaction data.
(Yet gas for individual external calls is, as we show below.)

This refund mechanism may in principle be abused, if the transaction initiator can
spend a large amount of gas without the knowledge of other owners.
The original owner may receive a benefit from such an abuse in case (1)
refund is emitted in token, and (2) the gas price in token is much higher than market price of Ether
in that token.
The latter is plausible, for example because: (1) the gas price is outdated, (2) market price changed a lot since gas price
was initially set, and (3) owners did not care to adjust the gas price because gas consumption was always small and thus irrelevant.

We again have to analyze the situation on all 3 external call sites.
For the payload external call, gas is limited by transaction parameter `safeTxGas`.
This parameter must be set and validated by other owners when token refund is used, thus abuse is not possible.
For the external call that sends the refund in token, gas is limited to remaining gas for transaction minus 10000
[source](https://github.com/gnosis/safe-contracts/blob/14495428954366dcf812acfa11e54c81b186332d/contracts/common/SecuredTokenTransfer.sol#L23):
```
 let success := call(sub(gas, 10000), token, 0, add(data, 0x20), mload(data), 0, 0)
```
This looks like a poor limit, but in order to be abused, the transaction initiator must have control over token account,
which looks like an unlikely scenario.

The biggest concern is again in the call to `ISingatureValidator`. This call is under the control of transaction initiator,
and the gas for it is not limited (see code for `checkSignatures`).
Thus, the attacking owner may use a malicious `ISignatureValidator` that consumes almost all allocated gas, in order to receive
a large refund. The amount of benefit the attacker my receive is limited by (1) block gas limit and (2) ratio between `gasPrice`
and market cost of the token. However, we should allow for the possibility that block gas limit will increase in future.
Thus this remains a valid vulnerability.

**Recommendation:**
Considering the specific functionality of `ISignatureValidator`, we recommend limiting the gas when calling `ISignatureValidator` to a small predetermined value. Careful gas limits on external contract calls are a common security practice. For example when tokens are sent in Solidity through `msg.sender.send(ethAmt)`, gas is automatically limited to `2300`([source](https://medium.com/@JusDev1988/reentrancy-attack-on-a-smart-contract-677eae1300f2)).


# Other Issues/Recommendations



## zero and precompiled contract addresses

`execTransaction` does not reject the case of `to` being the zero address `0x0`, which may lead to an *internal* transaction to the zero address, via the following function call sequence:

* https://github.com/gnosis/safe-contracts/blob/v0.1.0/contracts/GnosisSafe.sol#L95
* https://github.com/gnosis/safe-contracts/blob/v0.1.0/contracts/base/Executor.sol#L17
* https://github.com/gnosis/safe-contracts/blob/v0.1.0/contracts/base/Executor.sol#L33

Unlike a regular transaction to the zero address, which creates a new account, an internal transaction to the zero address behaves the same as other transactions to non-zero addresses, i.e., sending the ether to the zero address account (which indeed exists: https://etherscan.io/address/0x0000000000000000000000000000000000000000) and executing the code associated to it (which is empty in this case).

Although it is the users' responsibility that ensures correctness of the transaction data, it is quite possible that a certain user may not be aware of the difference between regular and internal transactions to the zero address, sending a transaction data to `execTransaction` with `to == 0x0`, expecting that it creates a new account.  Since an internal transaction to the zero address mostly succeeds (note that it spends a little gas, without needing to pay the `G_newaccount` (25,000) gas fee since the zero-address account already exists), it may cause the ether stuck at 0x0, which could be serious when the user attaches a large amount of ether as a startup fund for the new account.

Recommendation:
- reject `execTransaction` when `to == address(0)`.





#### Minor Related Note:

`handlePayment` may send the ether to `receiver`:

* https://github.com/gnosis/safe-contracts/blob/v0.1.0/contracts/GnosisSafe.sol#L120

where `receiver` is non-zero, since `tx.origin` cannot be zero.
But, `receiver` could be still a non-owned account, especially one of the precompiled (0x1 - 0x8) contract addresses.
Here `receiver.send(amount)` will succeed even with the small gas stipend 2300 for some precompiled contracts (at least, for 0x2, 0x3, 0x4, and 0x6). Below is the gas cost for executing each precompiled contract.

- 0x1: ECREC: 3000
- 0x2: SHA256: 60 + 12 * (byte-size-of-call-data)
- 0x3: RIP160: 600 + 120 * (byte-size-of-call-data)
- 0x4: ID: 15 + 3 * (byte-size-of-call-data)
- 0x5: MODEXP: (complex-gas-cost-model)
- 0x6: ECADD: 500
- 0x7: ECMUL: 40000
- 0x8: ECPAIRING: 100000 + ...


## Missing check of contract existence

`execTransaction` misses the contract existence check for `to`, and thus it can cause lost ethers.

According to the [Solidity document](https://solidity.readthedocs.io/en/v0.5.0/control-structures.html?highlight=non-existent#error-handling-assert-require-revert-and-exceptions):

> The low-level functions `call`, `delegatecall` and `staticcall` return `true` as their first return value if the called account is non-existent, as part of the design of EVM. Existence must be checked prior to calling if desired.

That is, if the user transaction is supposed to call an external contract with the ether payment `value > 0`, but makes a mistakes of referring to a non-existing address, the `execute` function silently returns true after transferring `value` to the non-existing account, resulting in the loss of the ethers.

However, it is understood that simply adding the contract existence check is not a solution, since there exists a use case that the user transaction is meant to send ethers to a non-contract account, in which case the existence check is not trivial.

Recommendation:
Differentiate two types of user transactions, i.e., contract call transaction and send transaction, and implement the contract existence check for the contract call transaction. For the send transaction, explicitly mention this limitation in the document of `execTransaction`, and/or implement an existence check for regular accounts at the client side.





## `checkSignatures`

### Local validity check

`checkSignatures` checks only the first `threshold` number of signatures.
Thus, the validity of the remaining signatures does not matter.
Also, the sortedness of the whole signatures is not required, as long as the first `threshold` number of signatures are locally sorted.
However, we have not found an attack exploiting this.

Another questionable behavior is in the case where there are `threshold` valid signatures in total, but some of them at the beginning are invalid. Currently, `checkSignatures` fails in this case.
A potential issue for this behavior is that a *bad* owner intentionally sends an invalid signature to *veto* the transaction. He can *always* veto if his address is the first (the smallest) among the owners. On the other hand, a *good* owner is hard to veto some bad transaction if his address is the last (the lartest) among the owners.
Is this intended?

### No explicit check for the case `2 <= v <= 26`

According to the signature encoding scheme, a signature with `2 <= v <= 26` is not valid, but the code does not have an explicit check for the case, relying on `ecrecover` to implicitly reject the case.  It may be considered to have the explicit check for the robustness, if the additional gas cost is affordable, since we have not verified the underlying C implementation of secp256k1, and there might exist unknown zero-day vulnerabilities (especially for the unusual cases).



### `signatures` size limit

Considering the [current max block gas limit] (~8M) and the gas cost for the local memory usage (i.e., `n^2/512 + 3n` for `n` bytes), the size of `signatures` must be (much) less than 2^16 (i.e., 64KB). 


[current max block gas limit]: <https://etherscan.io/blocks>



## OwnerManager

### `addOwnerWithThreshold`

Although it is very unlikely, but if `ownerCount` is corrupted (possibly due to the hash collision), `ownerCount++` may have the overflow, resulting in `ownerCount` being zero, provided that `threshold == _threshold`.  In the case of `threshold != _threshold`, however, if `ownerCount++` has the overflow, `changeThreshold` will always revert since the following two requirements cannot be satisfied at the same time, where `ownerCount` is zero:
```
        // Validate that threshold is smaller than number of owners.
        require(_threshold <= ownerCount, "Threshold cannot exceed owner count");
        // There has to be at least one Safe owner.
        require(_threshold >= 1, "Threshold needs to be greater than 0");
```



### Lazy enum type check

The `operation` argument value must be with the range of `Enum.Operation`, i.e., [0,2] inclusive, and the Solidity compiler is supposed to generate the range check in the compiled bytecode.  But it turns out that the range check does not appear in the `execTransaction` function, but it appears only inside the `execute` function.  We have not found yet any exploit of this missing range check, but it is a potential vulnerability that needs an extra examination whenever the new bytecode is generated.

Recommendation: examine bytecode whenever the bytecode is updated.


### Potential overflow if contract invariant is not met

There are several places where SafeMath is not used for the arithmetic operations.

https://github.com/gnosis/safe-contracts/blob/v0.1.0/contracts/GnosisSafe.sol#L92
https://github.com/gnosis/safe-contracts/blob/v0.1.0/contracts/GnosisSafe.sol#L139

https://github.com/gnosis/safe-contracts/blob/v0.1.0/contracts/base/OwnerManager.sol#L62
https://github.com/gnosis/safe-contracts/blob/v0.1.0/contracts/base/OwnerManager.sol#L79
https://github.com/gnosis/safe-contracts/blob/v0.1.0/contracts/base/OwnerManager.sol#L85

The following contract invariants are needed to rule out the possibility of overflow:
- `nonce` is small enough to avoid overflow in `nonce++`.
- `threshold` is small enough to avoid overflow in `threshold * 65`.
- `ownerCount >= 1` is small enough to avoid overflow in `ownerCount++`, `ownerCount - 1`, and `ownerCount--`.

In the current GnosisSafe contract, assuming the above invariants are practically reasonable considering the resource limitation (such as gas), but this assessment should be repeated whenever the contract is updated.


### transaction reordering issue.

this function allows to update `threshold`, which introduces an usability issue similar to the [ERC20 approve function issue](https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM).

the common usage scenario of this function is to add a new owner with *increasing* the threshold value (or keeping the value as is).  it is very unlikely the case of decreasing the threshold value while adding a new owner.  if there still exists such a use case, one can split the task into two transactions: adding a new owner, and decreasing threshold. that is, we have not found a reason for such a task, if any, to be executed atomically.


exploit scenario:

suppose there are five owners with threshold of three. suppose alice proposes a transaction of `addOwnerWithThreshold(o1,4)` and immediately bob proposes a transaction of `addOwnerWithThreshold(o2,5)`. if the bob's transaction is approved before the alice's transaction, the final threshold will be 4, while it should be 5.


recommendation:
- reject addOwnerWithThreshold if it tries to decrease threshold
- have two more functions: increaseThreshold and decreaseThreshold


recommendation:
removeOwner:
it may be considered to check that _threshold <= threshold



### `changeMasterCopy` missing contract existence check

`changeMasterCopy` misses the contract account existence check for the new master copy address.
if the non-contract address is set to the master copy, then the proxy fall back function will silently returns.

recommend:
implement the existence check, e.g., using EXTCODESIZE.




## signatureSplit index of ouf bound

The `signatureSplit` function does not check the index is within the bound of the `signatures` sequence. Although no out-of-bound index is passed to the function throughout the current GnosisSafe contract, it is recommended to either add the index bound check or mention the implicit requirement in the document to prevent any future implementation from violating this condition.


## address range

all the address arguments are assumed to be within the range of addresses, i.e., its first 96 (= 256 - 160) bits are zero. otherwise, the fist 96 bits are simply ignored, without any exception. thus, any client of this function should check the validity of addresses before passing them to the functions.


## signature encoding well-formedness




no validity check for the signature encoding
- when `v` is 0 or 1, the owner `r` should be within the range of `address`: otherwise, the upper bits are truncated
- when `v` is 0,
  - the offset `s` should be within the bound, i.e., s + 32 <= signatures.length: otherwise, it will read some garbage value from the memory
  - the dynamic signature data pointed by `s` should be well-formed:
    - the first 4 bytes denote the length of the dynamic data, i.e., dynamic-data-length := mload(signatures + s + 32): otherwise, it may try to read a large memory chunk
    - the `signatures` buffer should be large enough to hold the dynamic data, i.e., signatures.length >= s + 32 + dynamic-data-length: otherwise, it will read some garbage value from the memory
  - (optional) each dynamic data should not be pointed by different signatures: otherwise, the same dynamic data will be used to check the validity of different signatures
  - (optional) different dynamic data should not be overlapped



for example, 
in general, when a `bytes`-type argument is provided, the following checks are performed:


1. CALLDATASIZE >= 4 ?  // checks if the function signature is provided

2. CALLDATASIZE >= 4 + 32 * NUM_OF_ARGS  // checks if the headers of all parameters are provided

3. .... // load static type args and checks range

4. startLOC := CALLDATALOAD(4 + 32 * IDX)

5. startLOC <= 2^32 ?

6. startLOC + 4 + 32 <= CALLDATASIZE ?  // checks if the length is provided

7. dataLen := CALLDATALOAD(startLoc + 4)

8. startLoc + 4 + 32 + dataLen <= CALLDATASIZE ?  // checks if the actual data is provided

9. dataLen <= 2^32 ?




## screening for `isValidSignature` of each owner


it may be considered to scan the isValidSignature function whenever adding a new owner (either in the contract or the client side), to ensure that it has no dangerous opcode.













## List of Analyzed Common Attack Vectors
In this section we enumerate all attack vectors from our
[reference list](https://github.com/runtimeverification/verified-smart-contracts/wiki/List-of-Security-Vulnerabilities) 
of known attack vectors,
and describe how we analyzed them in GnosisSafe. The numbering correspond to that in the reference list.
Please consult the link above for details.

**1. Re-entrancy vulnerability** is present, as described in previous section.

**2. Arithmetic over/undeflows**. All `+/-/*` operations in GnosisSafe are performed using `SafeMath` library,
which reverts whenever an overflow/underflow occurs. Thus GnosisSafe does not have this issue.

**3. Unexpected Ether.** The default function in `Proxy.sol` is payable, and Ether is used by GnosisSafe to emit refunds.
The contract does not have issues related to presence of a specific amount of ether.
    
**4. Delegatecall.**
The payload call performed by GnosisSafe may be not only the regular `call`, but also a `delegatecall` or `create`.
The call type is managed by transaction parameter `operation`, e.g. must be signed by other owners.
However, `delegatecall` is a dangerous type of transaction that can alter the GnosisSafe persistent data in unexpected ways.
This danger is properly described in the GnosisSafe documentation.
An earlier security audit [for GnosisSafe](https://github.com/gnosis/safe-contracts/blob/68685cd811398ef229c719de0a108732443f71c1/docs/Gnosis_Safe_Audit_Report.pdf)
recommends disabling `delegatecall` and `create` entirely unless there is an important use case for it.
As it currently stands, it depends on the GnosisSafe client application to properly communicate to the owners
the type of call performed, and the dangers involved.
This is outside the scope of the present audit.

**5. Default Visibilities.** All functions have the visibility explicitly declared, and only functions that *must* be
    `public/external` are declared as such. Thus no functions use the default public visibility.

**6. Entropy Illusion.** GnosisSafe does not try to simulate random events. Thus the issue is unrelated to GnosisSafe.

**7. Delegating functionality to external contracts.** 
GnosisSafe uses the [proxy pattern](https://blog.gnosis.pm/solidity-delegateproxy-contracts-e09957d0f201).
Each instantiation of the safe deploys only the lightweight `Proxy.sol` contract, which delegates (via `delegatecall`) almost all calls
to the proper `GnosisSafe.sol` deployed in another account. This reduces the cost of instantiating the safe and allows
future upgrades.
The contract account can upgrade the implementation by calling `GnosisSafe.changeMasterCopy()` with the address
where the updated GnosisSafe code is deployed.
This function can only be called from the proxy account, thus is secure.
This pattern presents a security issue when the address of the master cannot be inspected by the contract users,
and they have no way to audit its security.
In GnosisSafe, master copy can be publicly accessed via `Proxy.implementation()`, so the issue is not present.

**8. Short address/parameter attack.**
The transaction payload in GnosisSafe is received via transaction parameter `data`,
and then used without changes to initiate an external call.
Other external calls are performed using standard methods from Solidity, thus the call data has the correct format.
The issue is not present.

**9. Unchecked CALL Return Values.**
Solidity methods `call()` and `send()` do not revert when the external call reverts, instead they return `false`.
Some smart contracts naively expect such calls to revert, leading to bugs and potentially security issues.
In GnosisSafe, the return value of all such calls is correctly checked.

**10. Race Conditions / Front Running.** 
This vulnerability may be present in contracts in which the amount of some ether/token transfer
depends on a sequence of transactions. Thus, an attacker may gain an advantage by manipulating the order of transactions.
In GnosisSafe, all the data from which refund token and amount are computed is given as parameters to `execTransaction`,
thus the issue is not present.

**11. Denial of Service.**
Non-owners cannot alter the persistent state of this contract, or use it to call
external contracts. Thus no external DoS attack is possible.
In principle if an owner loses the private key to his contract and can no longer exercise his duties to
sign transactions, this would result in some hindrance. However, the list of owners can always
be edited from the contract account, thus it will be a temporary issue.

**12. Block Timestamp manipulation.** The contract does not use block timestamp.

**13. Constructors with Care.** Before Solidity `v0.4.22`, 
constructor name was the same as the 
name of the contract. This posed the risk to introduce a dangerous bug if
between versions contract would be renamed but constructor would not.
GnosisSafe is compiled with Solidity `v5.0`, where constructors are declared with keyword `constructor`, 
thus the issue is not present.

**14. Uninitialised local storage variables.** Not used in GnosisSafe.

**15. Floating Points and Numerical Precision.** Floating point numbers are not used in GnosisSafe.

**16. Tx.Origin Authentication.** In GnosisSafe `tx.origin` is not used for authentication.

**17. Constantinople gas issue**
The issue may appear only in contracts without explicit protection for re-entrancy.
We already discussed re-entrancy on point 1.
