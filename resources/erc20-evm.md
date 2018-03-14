# ERC20-EVM: EVM-Specific Formal Specification of ERC20 Token Standard

We present a refinement of [ERC20-K] that captures EVM-specific details. [ERC20-K] is a comprehensive formal specification of the business logic of ERC20 with the goal of supporting high-level reasoning, which therefore intentionally omits EVM-specific details such as gas consumption, data layout in storage, ABI encoding, and byte representation of the program. However, reasoning about the low-level details is critical for contract verification because many security vulnerabilities are related to the EVM quirks.

We refine ERC20-K into the EVM level, called ERC20-EVM, to capture all of the detailed behaviors that can happen in the EVM level. Specifically, we refine it by lowering the [ERC20-K configuration] into the [KEVM configuration]. That includes laying out the high-level data such as `balances` and `allowances` within the EVM storage, encoding the program and the call data in bytes, and specifying additional information such as the gas consumption.

## EVM-Level Specifications of ERC20 Functions

We present EVM-level specifications for each ERC20 standard function.
The specifications are written in [eDSL], a domain-specific language for EVM specifications, which must be known in order to thorougly understand our EVM-level specifications.  Refer to [resources] for background on our technology. We provide the [eDSL] specification template parameters.
The full K reachability logic specifications are automatically derived by instantiating a specification template with these template parameters.

Here we focus on explaining the EVM-specific detailed behaviors, referring to the [ERC20-K] specification for the high-level logic.

### `totalSupply`

Below is the ERC20-EVM specification template parameters for `totalSupply`.

```
[totalSupply]
k: #execute => (RETURN RET_ADDR:Int 32 ~> _)
callData: #abiCallData("totalSupply", .TypedArgs)
localMem: .Map => .Map[ RET_ADDR := #asByteStackInWidth(TOTAL, 32) ] _:Map
gas: {GASCAP} => _
log: _
refund: _
storage:
    #hashedLocation({COMPILER}, {_TOTALSUPPLY}, .IntList) |-> TOTAL
    _:Map
requires:
    andBool 0 <=Int TOTAL andBool TOTAL <Int (2 ^Int 256)
```

`k` specifies that the execution eventually reaches the `RETURN` instruction, meaning that the program will successfully terminate. The `RETURN` instruction says that a 32-byte return value will be stored in the memory at the location `RET_ADDR`. The followed underline means that there will be more computation tasks to be performed (e.g., cleaning up the VM state) but they are not relevant.

`callData` specifies the call data using the `#abiCallData` [eDSL notation]. `.TypedArgs` refers to an empty list of the `#abiCallData`'s typed arguments, meaning that there is no argument for the `totalSupply` function.

`localMem` specifies that the local memory is empty in the beginning, but in the end, it will store the return value `TOTAL`, the total supply of the tokens, at the location `RET_ADDR` among others. The other entries represented by the anonymous variable `_` can be arbitrary and are not relevant.

`gas` specifies the gas consumption limit, `{GASCAP}`, another parameter to be given by the [program-specific parameters], ensuring that the program does not consume more amounts of gas than the limit.

Note that the verifier proves that the actual gas consumption is less than the provided limit, and also reports the exact amount of gas consumed during the execution. Indeed, it reports a set of the amounts since the gas consumption varies depending on the context (i.e., the input parameter values and the state of the storage).

`log` specifies that no log is generated during the execution.

`refund` specifies that no gas refund is issued. Note that it does not mean it consumes all of the provided gas. The gas refund is different from returning the remaining gas after the transaction. It is a notion of gas reimbursement that happens when an unused storage is re-claimed (i.e., re-cycled), or the `SELFDESTRUCT` instruction is executed. This specification ensures that no such event happens during the execution of the current function.

`storage` specifies that the value of `totalSupply` is `TOTAL` and other entries are not relevant (and could be arbitrary values). It refers to another two parameters, `{COMPILER}` and `{_TOTALSUPPLY}`, which are supposed to be given by the [program-specific parameters]. `{COMPILER}` specifies the high-level language in which the token contract is written. `{_TOTALSUPPLY}` specifies the position index of the `totalSupply` variable in the contract.

Specifying the irrelevant entries implicitly expresses the non-interference property. That is, the `totalSupply` value will be returned regardless of what the other entires of the storage are. This representation of the irrelevant part is used throughout the entire specification, ensuring one of the principal security properties.

`requires` specifies the range of the symbolic values based on their types.

### `balanceOf`

Below is the specification (template parameters) of `balanceOf`, defined similarly to that of `totalSupply`.

```
[balanceOf]
k: #execute => (RETURN RET_ADDR:Int 32 ~> _)
callData: #abiCallData("balanceOf", #address(OWNER))
localMem: .Map => ( .Map[ RET_ADDR := #asByteStackInWidth(BAL, 32) ] _:Map )
gas: {GASCAP} => _
log: _
refund: _
storage:
    #hashedLocation({COMPILER}, {_BALANCES}, OWNER) |-> BAL
    _:Map
requires:
    andBool 0 <=Int OWNER andBool OWNER <Int (2 ^Int 160)
    andBool 0 <=Int BAL   andBool BAL   <Int (2 ^Int 256)
```

Notable differences are as follows:

`storage` specifies that the value of `balances[OWNER]` is `BAL`, which will be returned as described in `localMem`.

`requires` specifies the range of symbolic values.
Note that the maximum possible value of `OWNER` is `2**160` exclusive, since it is of the address type.

### `allowance`

The specification of `allowance` is similar to that of `totalSupply` as well.

```
[allowance]
k: #execute => (RETURN RET_ADDR:Int 32 ~> _)
callData: #abiCallData("allowance", #address(OWNER), #address(SPENDER))
localMem: .Map => ( .Map[ RET_ADDR := #asByteStackInWidth(ALLOWANCE, 32) ] _:Map )
gas: {GASCAP} => _
log: _
refund: _
storage:
    #hashedLocation({COMPILER}, {_ALLOWANCES}, OWNER SPENDER) |-> ALLOWANCE
    _:Map
requires:
    andBool 0 <=Int OWNER     andBool OWNER     <Int (2 ^Int 160)
    andBool 0 <=Int SPENDER   andBool SPENDER   <Int (2 ^Int 160)
    andBool 0 <=Int ALLOWANCE andBool ALLOWANCE <Int (2 ^Int 256)
```

Notable differences are as follows:

`storage` specifies that the value of `allowances[OWNER][SPENDER]` is `ALLOWANCE`, which will be returned as described in `localMem`.

### `approve`

Below is the specification of `approve`.

```
[approve]
k: #execute => (RETURN RET_ADDR:Int 32 ~> _)
callData: #abiCallData("approve", #address(SPENDER), #uint256(VALUE))
localMem: .Map => ( .Map[ RET_ADDR := #asByteStackInWidth(1, 32) ] _:Map )
gas: {GASCAP} => _
log: _:List ( .List => ListItem(#abiEventLog(ACCT_ID, "Approval", #indexed(#address(CALLER_ID)), #indexed(#address(SPENDER)), #uint256(VALUE))) )
refund: _ => _
storage:
    #hashedLocation({COMPILER}, {_ALLOWANCES}, CALLER_ID SPENDER) |-> (_:Int => VALUE)
    _:Map
requires:
    andBool 0 <=Int SPENDER andBool SPENDER <Int (2 ^Int 160)
    andBool 0 <=Int VALUE   andBool VALUE   <Int (2 ^Int 256)
```

Notable differences with the previous ones are as follows:

`log` specifies that an event is logged during the execution, using the `#abiEventLog` [eDSL notation]. The log data contains the current contract account address, the signature of the event `Approval`, the caller's account address, the spender's account address, and the approved value.

`refund` specifies that a refund may be issued. This function will refund a gas if the value to approve is 0 while the existing approved value is greater than 0, re-claiming the corresponding entry of the storage. Note that, however, we have not specified the refund details since it is not essential for the functional correctness.
<!-- We can specify that upon request. -->

`storage` specifies that the value of `allowances[CALLER_ID][SPENDER]` will be updated to `VALUE` after the transaction.

Unlike the [ERC20-K] specification, we do not specify the case when `VALUE` is less than 0 because it is not possible; the `VALUE` parameter is of type `uint256`, an unsigned 256-bit integer. Indeed, the ABI call mechanism will reject a call to this function if the `VALUE` is negative, which is out of the scope of the EVM-level specification since it happens in the network layer outside the virtual machine.

### `transfer`

Below is the specification of `transfer`.

```
[transfer]
callData: #abiCallData("transfer", #address(TO_ID), #uint256(VALUE))
gas: {GASCAP} => _
refund: _ => _
requires:
    andBool 0 <=Int TO_ID     andBool TO_ID     <Int (2 ^Int 160)
    andBool 0 <=Int VALUE     andBool VALUE     <Int (2 ^Int 256)
    andBool 0 <=Int BAL_FROM  andBool BAL_FROM  <Int (2 ^Int 256)
    andBool 0 <=Int BAL_TO    andBool BAL_TO    <Int (2 ^Int 256)

[transfer-success]
k: #execute => (RETURN RET_ADDR:Int 32 ~> _)
localMem: .Map => ( .Map[ RET_ADDR := #asByteStackInWidth(1, 32) ] _:Map )
log: _:List ( .List => ListItem(#abiEventLog(ACCT_ID, "Transfer", #indexed(#address(CALLER_ID)), #indexed(#address(TO_ID)), #uint256(VALUE))) )

[transfer-success-1]
storage:
    #hashedLocation({COMPILER}, {_BALANCES}, CALLER_ID) |-> (BAL_FROM => BAL_FROM -Int VALUE)
    #hashedLocation({COMPILER}, {_BALANCES}, TO_ID)     |-> (BAL_TO   => BAL_TO   +Int VALUE)
    _:Map
+requires:
    andBool CALLER_ID =/=Int TO_ID
    andBool VALUE <=Int BAL_FROM
    andBool BAL_TO +Int VALUE <Int (2 ^Int 256)

[transfer-success-2]
storage:
    #hashedLocation({COMPILER}, {_BALANCES}, CALLER_ID) |-> BAL_FROM
    _:Map
+requires:
    andBool CALLER_ID ==Int TO_ID
    andBool VALUE <=Int BAL_FROM

[transfer-failure]
k: #execute => #exception
localMem: .Map => _:Map
log: _

[transfer-failure-1]
storage:
    #hashedLocation({COMPILER}, {_BALANCES}, CALLER_ID) |-> (BAL_FROM => _)
    #hashedLocation({COMPILER}, {_BALANCES}, TO_ID)     |->  BAL_TO
    _:Map
+requires:
    andBool CALLER_ID =/=Int TO_ID
    andBool ( VALUE >Int BAL_FROM
     orBool   BAL_TO +Int VALUE >=Int (2 ^Int 256) )

[transfer-failure-2]
storage:
    #hashedLocation({COMPILER}, {_BALANCES}, CALLER_ID) |-> BAL_FROM
    _:Map
+requires:
    andBool CALLER_ID ==Int TO_ID
    andBool VALUE >Int BAL_FROM
```

Faithfully following [ERC20-K], it exhibits the four cases, identified by the four sections, `[transfer-success-1]`, `[transfer-success-2]`, `[transfer-failure-1]`, and `[transfer-failure-2]`. Each section corresponds to each of the four cases of [ERC20-K], respectively.

The above specification is written using the section inheritance feature of [eDSL] to avoid duplication and highlight the differences between the four cases. Refer to the eDSL specification [template parameters] for more details.

### `transferFrom`

Below is the specification of `transferFrom`, which is similar to that of `transfer`, faithfully capturing the high-level logic of [ERC20-K].

```
[transferFrom]
callData: #abiCallData("transferFrom", #address(FROM_ID), #address(TO_ID), #uint256(VALUE))
gas: {GASCAP} => _
refund: _ => _
requires:
    andBool 0 <=Int FROM_ID   andBool FROM_ID   <Int (2 ^Int 160)
    andBool 0 <=Int TO_ID     andBool TO_ID     <Int (2 ^Int 160)
    andBool 0 <=Int VALUE     andBool VALUE     <Int (2 ^Int 256)
    andBool 0 <=Int BAL_FROM  andBool BAL_FROM  <Int (2 ^Int 256)
    andBool 0 <=Int BAL_TO    andBool BAL_TO    <Int (2 ^Int 256)
    andBool 0 <=Int ALLOW     andBool ALLOW     <Int (2 ^Int 256)

[transferFrom-success]
k: #execute => (RETURN RET_ADDR:Int 32 ~> _)
localMem: .Map => ( .Map[ RET_ADDR := #asByteStackInWidth(1, 32) ] _:Map )
log: _:List ( .List => ListItem(#abiEventLog(ACCT_ID, "Transfer", #indexed(#address(FROM_ID)), #indexed(#address(TO_ID)), #uint256(VALUE))) )

[transferFrom-success-1]
storage:
    #hashedLocation({COMPILER}, {_BALANCES},   FROM_ID)           |-> (BAL_FROM => BAL_FROM -Int VALUE)
    #hashedLocation({COMPILER}, {_BALANCES},   TO_ID)             |-> (BAL_TO   => BAL_TO   +Int VALUE)
    #hashedLocation({COMPILER}, {_ALLOWANCES}, FROM_ID CALLER_ID) |-> (ALLOW    => ALLOW    -Int VALUE)
    _:Map
+requires:
    andBool FROM_ID =/=Int TO_ID
    andBool VALUE <=Int BAL_FROM
    andBool BAL_TO +Int VALUE <Int (2 ^Int 256)
    andBool VALUE <=Int ALLOW

[transferFrom-success-2]
storage:
    #hashedLocation({COMPILER}, {_BALANCES},   FROM_ID)           |-> BAL_FROM
    #hashedLocation({COMPILER}, {_ALLOWANCES}, FROM_ID CALLER_ID) |-> (ALLOW => ALLOW -Int VALUE)
    _:Map
+requires:
    andBool FROM_ID ==Int TO_ID
    andBool VALUE <=Int BAL_FROM
    andBool VALUE <=Int ALLOW

[transferFrom-failure]
k: #execute => #exception
localMem: .Map => _:Map
log: _

[transferFrom-failure-1]
storage:
    #hashedLocation({COMPILER}, {_BALANCES},   FROM_ID)           |-> (BAL_FROM => _)  // BAL_FROM
    #hashedLocation({COMPILER}, {_BALANCES},   TO_ID)             |-> (BAL_TO   => _)  // BAL_TO
    #hashedLocation({COMPILER}, {_ALLOWANCES}, FROM_ID CALLER_ID) |-> ALLOW
    _:Map
+requires:
    andBool FROM_ID =/=Int TO_ID
    andBool ( VALUE >Int BAL_FROM
     orBool   BAL_TO +Int VALUE >=Int (2 ^Int 256)
     orBool   VALUE >Int ALLOW )

[transferFrom-failure-2]
storage:
    #hashedLocation({COMPILER}, {_BALANCES},   FROM_ID)           |-> BAL_FROM
    #hashedLocation({COMPILER}, {_ALLOWANCES}, FROM_ID CALLER_ID) |-> ALLOW
    _:Map
+requires:
    andBool FROM_ID ==Int TO_ID
    andBool ( VALUE >Int BAL_FROM
     orBool   VALUE >Int ALLOW )
```


[K-framework]: <http://www.kframework.org>
[reachability logic theorem prover]: <http://fsl.cs.illinois.edu/index.php/Semantics-Based_Program_Verifiers_for_All_Languages>

[ERC20]: <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md>
[ERC20-K]: <https://github.com/runtimeverification/erc20-semantics>

[resources]: </README.md#resources>
[eDSL]: </resources/edsl.md>
[eDSL notation]: </resources/edsl-notations.md>
[program-specific parameters]: </resources/edsl-spec.md#program-specific-parameters>
[template parameters]: </resources/edsl-spec.md#edsl-template-parameters>
[specification template]: </resources/edsl-spec.md#edsl-specification-template>

[ERC20-K configuration]: <https://github.com/runtimeverification/erc20-semantics/blob/master/erc20.k#L26-L48>
[KEVM configuration]: <https://github.com/kframework/evm-semantics/blob/master/evm.md#configuration>
