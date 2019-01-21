# Security Audit of GnosisSafe contract

## Methodology

In this section we analyzed for security issues the core GnosisSafe contract.
The version audited is [commit 14495428954366dcf812acfa11e54c81b186332d](https://github.com/gnosis/safe-contracts/commit/14495428954366dcf812acfa11e54c81b186332d)
, compiled with Solidity v0.5.0. 
We only analyzed the core contract, without extensions, e.g. 
[Proxy.sol](https://github.com/gnosis/safe-contracts/blob/14495428954366dcf812acfa11e54c81b186332d/contracts/proxies/Proxy.sol)
acting as proxy for [GnosisSafe.sol](https://github.com/gnosis/safe-contracts/blob/bfb8abac580d76dd44f68307a5356a919c6cfb9b/contracts/GnosisSafe.sol) .

We used as reference the [Sigmaprime Collection](https://blog.sigmaprime.io/solidity-security.html)
of common security vulnerabilities and bugs in EVM and Solidity.
In addition, we inspected the code for vulnerabilities not present in the list, 
with focus on external contract calls.

Next we present the list of discovered security issues, followed by our 
assessment of vulnerabilities.

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
The main external call managed by this transaction (hereafter referred as "payload") is performed 
[here](https://github.com/gnosis/safe-contracts/blob/bfb8abac580d76dd44f68307a5356a919c6cfb9b/contracts/GnosisSafe.sol#L95).
After payload is executed, the original caller or another account specified in transaction data is refunded for gas cost
[here](https://github.com/gnosis/safe-contracts/blob/bfb8abac580d76dd44f68307a5356a919c6cfb9b/contracts/GnosisSafe.sol#L102).
Both these calls are performed after the nonce is incremented.
Consequently, it is not possible to execute the same transaction multiple times
from within these calls.

However, there is one more external call possible during 
[check signatures](https://github.com/gnosis/safe-contracts/blob/bfb8abac580d76dd44f68307a5356a919c6cfb9b/contracts/GnosisSafe.sol#L90) 
phase, which calls [an external contract](https://github.com/gnosis/safe-contracts/blob/bfb8abac580d76dd44f68307a5356a919c6cfb9b/contracts/GnosisSafe.sol#L161) 
managed by an owner to validate the signature using 
[EIP-1271](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1271.md) signature validation mechanism.
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
For the external call that sends the refund in token, gas is limited to remaining gas for transaction minus 10000: 
[source](https://github.com/gnosis/safe-contracts/blob/14495428954366dcf812acfa11e54c81b186332d/contracts/common/SecuredTokenTransfer.sol#L23).
This looks like a poor limit, but in order to be abused, the transaction initiator must have control over token account,
which looks like an unlikely scenario.

The biggest concern is again in the call to `ISingatureValidator`. This call is under the control of transaction initiator,
and the gas for it is not limited.
Thus, the attacking owner may use a malicious `ISignatureValidator` that consumes almost all allocated gas, in order to receive
a large refund. The amount of benefit the attacker my receive is limited by (1) block gas limit and (2) ratio between `gasPrice`
and market cost of the token. However, we should allow for the possibility that block gas limit will increase in future.
Thus this remains a valid vulnerability.

**Recommendation:**
Considering the specific functionality of `ISignatureValidator`, we recommend limiting the gas when calling `ISignatureValidator` to a small predetermined value. Careful gas limits on external contract calls are a common security practice. For example when tokens are sent in Solidity through `msg.sender.send(ethAmt)`, gas is automatically limited to `2300`([source](https://medium.com/@JusDev1988/reentrancy-attack-on-a-smart-contract-677eae1300f2)).

## List of Analyzed Common Attack Vectors
In this section we enumerate all attack vectors from
[Sigmaprime Collection](https://blog.sigmaprime.io/solidity-security.html)
and describe how we analyzed them in GnosisSafe. The numbering correspond to that in Sigmaprime List.
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
