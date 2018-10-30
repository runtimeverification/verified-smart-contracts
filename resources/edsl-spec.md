# eDSL Specifications

Even with the [eDSL high-level notations](edsl-notations.md), the refined EVM specification is still quite large due to the sheer size of the KEVM configuration, but large part of that is the same across the different specifications.
The eDSL specification template allows the common part to be reused and shared between different specifications, avoiding duplication.
The template is essentially a reachability logic specification but contains several parameters which are place-holders to be filled with parameter values when being instantiated.
The template is instantiated with suitable parameter values for each specification.

## eDSL Specification Template

EVM specifications are written over the full KEVM configuration.
However, large part of the configuration is not relevant for functional correctness specification and can be shared across the different specifications.
eDSL allows capturing these common portions in a template specification that can instantiate for each specification.

Below is the template specification.
Essentially, it is a reachability claim over the KEVM configurations.
The configurations are generalized as much as possible to capture arbitrary contexts in which contract functions are called.
The underline (`_`) is an anonymous/nameless variable (with no constraint) that matches any value, denoting an arbitrary state.
The constant values and the `requires` condition represent the pre-condition.
The upper-case variables enclosed by the curly braces (`{`, `}`) are the template parameters, i.e., place-holders to be replaced with parameter values when being instantiated.
Note that there are only a few of parameters, meaning that the larger part of the specification is shared across the different specifications.

```k
  rule
    <k> {K} </k>
    <exit-code> 1 </exit-code>
    <mode> NORMAL </mode>
    <schedule> BYZANTIUM </schedule>
    <ethereum>
      <evm>
        <output> {OUTPUT} </output>
        <memoryUsed> {MEMORYUSED} </memoryUsed>
        <callDepth> CALL_DEPTH </callDepth>
        <callStack> _ => _ </callStack>
        <interimStates> _ </interimStates>
        <substateStack> _ </substateStack>
        <callLog> .Set </callLog> // for vmtest only
        <txExecState>
          <program> #asMapOpCodes(#dasmOpCodes(#parseByteStack({CODE}), BYZANTIUM)) </program>
          <programBytes> #parseByteStack({CODE}) </programBytes>
          <id> ACCT_ID </id>
          <caller> CALLER_ID </caller> // msg.sender
          <callData> {CALLDATA} </callData> // msg.data
          <callValue> {CALLVALUE} </callValue> // msg.value
          <wordStack> {WORDSTACK} </wordStack>
          <localMem> {LOCALMEM} </localMem>
          <pc> {PC} </pc>
          <gas> {GAS} </gas>
          <previousGas> _ => _ </previousGas>
          <static> false </static> // NOTE: non-static call
        </txExecState>
        <substate>
          <selfDestruct> _ </selfDestruct>
          <log> {LOG} </log>
          <refund> {REFUND} </refund>
        </substate>
        <gasPrice> _ </gasPrice>
        <origin> ORIGIN_ID </origin> // tx.origin
        <previousHash> _ </previousHash>
        <ommersHash> _ </ommersHash>
        <coinbase> _ </coinbase>
        <stateRoot> _ </stateRoot>
        <transactionsRoot> _ </transactionsRoot>
        <receiptsRoot> _ </receiptsRoot>
        <logsBloom> _ </logsBloom>
        <difficulty> _ </difficulty>
        <number> _ </number>
        <gasLimit> _ </gasLimit>
        <gasUsed> _ </gasUsed>
        <timestamp> NOW </timestamp> // now
        <extraData> _ </extraData>
        <mixHash> _ </mixHash>
        <blockNonce> _ </blockNonce>
        <ommerBlockHeaders> _ </ommerBlockHeaders>
        <blockhash> _ </blockhash>
      </evm>
      <network>
        <activeAccounts> ACCT_ID |-> false _:Map </activeAccounts>
        <accounts>
          <account>
            <acctID> ACCT_ID </acctID>
            <balance> _ </balance>
            <code> #parseByteStack({CODE}) </code>
            <storage> {STORAGE} </storage>
            <origStorage> _ </origStorage>
            <nonce> _ </nonce>
          </account>
          ...
        </accounts>
        <txOrder> _ </txOrder>
        <txPending> _ </txPending>
        <messages> _ </messages>
      </network>
    </ethereum>
    requires 0 <=Int ACCT_ID    andBool ACCT_ID    <Int (2 ^Int 160)
     andBool 0 <=Int CALLER_ID  andBool CALLER_ID  <Int (2 ^Int 160)
     andBool 0 <=Int ORIGIN_ID  andBool ORIGIN_ID  <Int (2 ^Int 160)
     andBool 0 <=Int NOW        andBool NOW        <Int (2 ^Int 256)
     andBool 0 <=Int CALL_DEPTH andBool CALL_DEPTH <Int 1024
     {REQUIRES}
```

## eDSL Template Parameters

The specification parameters and their values are given in the [INI format](https://en.wikipedia.org/wiki/INI_file), which is essentially a list of the parameter name and value pairs.
More precisely, they are given in a variant of the INI format, extended with support for nested inheritance, allowing further reusing parameters over the different but similar specifications.
Moreover, the specification parameters are grouped into two categories: function-specific parameters and program-specific parameters.
The program-specific parameters are shared among the specifications of the same program.
An EVM specification can be represented in terms of the parameter values, which are used to produce a full specification from the specification template.

### Function-Specific Parameters

Below is an example of the function-specific parameter definition of a `balanceOf` function which takes as an input the account address and returns its balance if the address is non-zero, otherwise throws.
(Note that this is *not* the ERC20 standard function, but a hypothetical function designed for explanation.)


```
  [DEFAULT]
  memoryUsed: 0 => _
  callValue: 0
  wordStack: .WordStack => _
  localMem: .Map => _
  pc: 0 => _
  gas: {GASCAP} => _

  [balanceOf]
  callData: #abiCallData("balanceOf", #address(OWNER))
  storage: #hashedLocation({COMPILER}, {_BALANCES}, OWNER) |-> VALUE _:Map
  requires: andBool 0 <=Int OWNER andBool OWNER <Int (2 ^Int 160)
            andBool 0 <=Int VALUE andBool VALUE <Int (2 ^Int 256)

  [balanceOf-success]
  k: #execute => (RETURN RET_ADDR:Int 32 ~> _)
  localMem: .Map => .Map[ RET_ADDR := #asByteStackInWidth(VALUE, 32) ] _:Map
  +requires: andBool OWNER =/=Int 0

  [balanceOf-failure]
  k: #execute => #exception
  +requires: andBool OWNER ==Int 0
```

The parameter definition consists of lists of parameter and value pairs, called 'sections'.
Each section begins with its name, enclosed by the square brackets, e.g., `[DEFAULT]` or `[balanceOf]`.
The section name is referred to when being inherited by other sections.
Each parameter is defined by a key and value pair separated by the colon (`:`).

A section can inherit another section to avoid duplication and highlight differences between different but similar specifications (sections).
For example, `[balanceOf-success]` inherits `[balanceOf]` which in turns inherits `[DEFAULT]`.
When a child section inherits its parent section, it overwrites the parameter values except for the parameter key whose name starts with the `+` symbol, for which it accumulates the values by appending the child values to the parent ones.
For example, the final value of `requires` of `[balanceOf-success]` is the concatenation of `[DEFAULT]`'s `requires`, `[balanceOf]`'s `+requires`, and `[balanceOf-success]`'s `+requires` values.

The `[DEFAULT]` section is inherited by all other sections.
It specifies the default parameter values.

The anonymous/nameless variable (`_`) denotes an arbitrary context whose value can be arbitrary and are not relevant w.r.t. functional correctness specification.
If it appears in the left-hand side of `=>`, it means that all possible input states/values are considered.
If it appears in the right-hand side of `=>`, it means that the output states/values may be updated and different from the input states, but their specific contents are not relevant for the current specification.
If it appears without `=>`, it means that all possible input states/values are considered but they are not updated at all during the execution, must remain intact.

`⚬Int` (e.g., `^Int` and `<=Int`) are (mathematical) integer arithmetic operations.

`output` specifies the output value at the end of the current transaction.
Specifically, in the `[DEFAULT]` section, it specifies that the output value is not relevant for the current specification.

`memoryUsed` specifies the amount of memory used at the beginning and the end of the execution, and
`localMem` specifies the pre- and post-states of the local memory.
Specifically, in the `[DEFAULT]` section, it specifies that it begins with the empty (fresh) memory but will end with some used memory whose contents are not relevant for the current specification.

`callValue` specifies the number of Wei sent with the current transaction.

`wordStack` specifies the pre- and post-states (snapshots) of the local stack.
Specifically, in the `[DEFAULT]` section, it specifies that it begins with the empty (fresh) stack but will end with some elements pushed, but the contents are not relevant for the current specification.

`pc` specifies the program-counter (PC) values at the beginning and the end of the execution.
Specifically, in the `[DEFAULT]` section, it specifies that it starts with PC 0 and will end with some PC value that are not relevant for the specification.

`gas` specifies the maximum gas amount, `{GASCAP}`, another parameter to be given by the program specification, ensuring that the program does not consume more gas than the limit.
One can set a tight amount of the gas limit to ensure that the program does not consume more gas than expected (i.e., no gas leakage).
In case that there is no loop in the code, however, one can simply give a loose upper-bound.
The verifier proves that the gas consumption is less than the provided limit, and also reports the exact amount of gas consumed during the execution.
Indeed, it reports a set of the amounts since the gas consumption varies depending on the context (i.e., the input parameter values and the state of the storage).

`log` specifies the pre- and post-states of log messages generated.
Specifically, in the `[DEFAULT]` section, it specifies that that no log is generated during the execution, while the existing log messages are not relevant.

`refund` specifies the pre- and post-amounts of the gas refund.
Specifically, in the `[DEFAULT]` section, it specifies that no gas is refunded.
Note that it does not mean it consumes all the provided gas.
The gas refund is different from returning the remaining gas after the execution.
It is another notion to capture some specific gas refund events that happen, for example, when an unused storage entry is re-claimed (i.e., garbage-collected).
The specification ensures that no such event happens during the execution of the current function.

`callData` specifies the call data using the `#abiCallData` eDSL notation.
Specifically, in the `[balanceOf]` section, it specifies the (symbolic) value, `OWNER`, of the first parameter.

`storage` specifies the pre- and post-states of the permanent storage.
Specifically, in the `[balanceOf]` section, it specifies that the value of `balances[OWNER]` is `VALUE` and other entries are not relevant (and could be arbitrary values).
It refers to another two parameters, `{COMPILER}` and `{_BALANCES}`, which are supposed to be given by the program specification.
`{COMPILER}` specifies the language in which the program is written.
`{_BALANCES}` specifies the position index of `balances` global variable in the program.

Specifying the irrelevant entries implicitly expresses the non-interference property.
That is, the total supply value will be returned regardless of what the other entires of the storage are.
This representation of the irrelevant part is used throughout the entire specification, ensuring one of the principal security properties.

`k` specifies that the execution eventually reaches the `RETURN` instruction, meaning that the program will successfully terminate.
The `RETURN` instruction says that a 32-byte return value will be stored in the memory at the location `RET_ADDR`.
The followed underline means that there will be more computation tasks to be performed (e.g., cleaning up the VM state) but they are not relevant w.r.t. the correctness.

`localMem` in the `[balanceOf-success]` section overwrites that of `[DEFAULT]`, specifying that the local memory is empty in the beginning, but in the end, it will store the return value `VALUE` at the location `RET_ADDR` among others.
The other entries are represented by the anonymous variable `_`, meaning that they can be arbitrary and are not relevant w.r.t. the correctness.

`requires` specifies the pre-condition over the named variables.
Specifically, `requires` of the `[DEFAULT]` section specifies the range of symbolic values based on their types.
`+requires` of `[balanceOf-success]` specifies additional pre-condition on the top of that of `[DEFAULT]`, which is the condition for the success case,
while that of `[balanceOf-failure]` specifies additional pre-condition for the failure case.

### Program-Specific Parameters

Below is an example of the program-specific parameters.

```
  [pgm]
  compiler: "Solidity"
  _balances: 0
  _totalSupply: 1
  _allowances: 2
  code: "0x60606040526004361061008e576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063095ea7b31461009357806318160ddd146100ed57806323b872dd14610116578063661884631461018f57806370a08231146101e9578063a9059cbb14610236578063d73dd62314610290578063dd62ed3e146102ea575b600080fd5b341561009e57600080fd5b6100d3600480803573ffffffffffffffffffffffffffffffffffffffff16906020019091908035906020019091905050610356565b604051808215151515815260200191505060405180910390f35b34156100f857600080fd5b610100610448565b6040518082815260200191505060405180910390f35b341561012157600080fd5b610175600480803573ffffffffffffffffffffffffffffffffffffffff1690602001909190803573ffffffffffffffffffffffffffffffffffffffff16906020019091908035906020019091905050610452565b604051808215151515815260200191505060405180910390f35b341561019a57600080fd5b6101cf600480803573ffffffffffffffffffffffffffffffffffffffff1690602001909190803590602001909190505061080c565b604051808215151515815260200191505060405180910390f35b34156101f457600080fd5b610220600480803573ffffffffffffffffffffffffffffffffffffffff16906020019091905050610a9d565b6040518082815260200191505060405180910390f35b341561024157600080fd5b610276600480803573ffffffffffffffffffffffffffffffffffffffff16906020019091908035906020019091905050610ae5565b604051808215151515815260200191505060405180910390f35b341561029b57600080fd5b6102d0600480803573ffffffffffffffffffffffffffffffffffffffff16906020019091908035906020019091905050610d04565b604051808215151515815260200191505060405180910390f35b34156102f557600080fd5b610340600480803573ffffffffffffffffffffffffffffffffffffffff1690602001909190803573ffffffffffffffffffffffffffffffffffffffff16906020019091905050610f00565b6040518082815260200191505060405180910390f35b600081600260003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020819055508273ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff167f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925846040518082815260200191505060405180910390a36001905092915050565b6000600154905090565b60008073ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff161415151561048f57600080fd5b6000808573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000205482111515156104dc57600080fd5b600260008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054821115151561056757600080fd5b6105b8826000808773ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054610f8790919063ffffffff16565b6000808673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000208190555061064b826000808673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054610fa090919063ffffffff16565b6000808573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000208190555061071c82600260008773ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054610f8790919063ffffffff16565b600260008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020819055508273ffffffffffffffffffffffffffffffffffffffff168473ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef846040518082815260200191505060405180910390a3600190509392505050565b600080600260003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000205490508083111561091d576000600260003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020819055506109b1565b6109308382610f8790919063ffffffff16565b600260003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020819055505b8373ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff167f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925600260003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008873ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020546040518082815260200191505060405180910390a3600191505092915050565b60008060008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020549050919050565b60008073ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff1614151515610b2257600080fd5b6000803373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020548211151515610b6f57600080fd5b610bc0826000803373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054610f8790919063ffffffff16565b6000803373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002081905550610c53826000808673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054610fa090919063ffffffff16565b6000808573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020819055508273ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef846040518082815260200191505060405180910390a36001905092915050565b6000610d9582600260003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054610fa090919063ffffffff16565b600260003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020819055508273ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff167f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925600260003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008773ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020546040518082815260200191505060405180910390a36001905092915050565b6000600260008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054905092915050565b6000828211151515610f9557fe5b818303905092915050565b6000808284019050838110151515610fb457fe5b80915050929150505600a165627a7a7230582058550344abe30ea80d7004da1407b11319bd56cc09cfbbc9ca9a7c80adacd5a30029"
  gasCap: 100000
```

`compiler` specifies the language in which the smart contract is implemented.

`code` is the EVM bytecode generated from the source code.

The position index parameters (the ones starting with the underline `_`) specify the indexes of the storage variables in the order that their declarations appear in the source code, meaning that the `balances` variable is declared first, followed by the `totalSupply` variable being declared, and followed by the `allowances` variable at last.
Note that the actual variable names in the source code may be different with the parameter names.
The literal name of the variable is not relevant for the EVM specification because the variable name disappears during compilation to the EVM, being identified only by it position index.

`gasCap` specifies the gas limit.
Here we give a rough upper-bound for demonstration purposes.
In practice, one should set a reasonable amount of the gas limit to see if the program does not consume too much gas (i.e., no gas leakage).

#### Full Examples

* [balanceOf-spec.k]: The full specification automatically derived from the above example template parameters.
(As noted above, this is *not* for the ERC20 standard function, but for the hypothetical function designed for the above example.)

* [ERC20-EVM]: An eDSL formal specification of ERC20 token standard


[ERC20-EVM]: </resources/erc20-evm.md>
[balanceOf-spec.k]: </resources/balanceOf-spec.k>

## Specification Generation

The specification can be automatically generated from the `.ini` file and the specification templates using the `gen-spec.py` script under the `resources` directory. 
```
$ python3 gen-spec.py <path-to-module-tmpl> <path-to-spec-tmpl> <path-to-spec-ini> <spec-name> <list-of-rule-names>
```
For example, the following command can be used to generate the specification file for the `collectToken` function under the `bihu` directory.
```
# under the verified-smart-contracts directory
$ python3 resources/gen-spec.py bihu/module-tmpl.k bihu/spec-tmpl.k bihu/collectToken-spec.ini collectToken collectToken loop ds-math-mul
```
* The first `collectToken` is the name of the specification.
* In order to prove the `collectToken` funciton, we need the specification rules for the top-level function, the loop and the multiplication. `collectToken loop ds-math-mul` is the list of section names in the `.ini` file corresponding to those three specifications.

The generated specification file has a module named `collectToken` and the module contains three specification rules as listed above.
