## Potential Attack Scenarios

Both attacks are based on the fact that `execTransactionAndPaySubmitter` can run any type of contracts given correct set of signatures and enough gas.

Let's suppose a malicious contract described below with pseudo-code is deployed on address `a`.
```solidity
contract C {
  function foo() {
    delegatecall(to = Proxy, data = removeOwner)
  }
  function bar() {
    owners[SENTINEL_OWNERS] = SENTINEL_OWNERS;
  }
}

```

### 1. executor calls `execTransactionAndPaySubmitter(to = a, data = C.foo, operation = Call, correct signatures)` to a Proxy account.
1. fallback function `delegatecall`s `execTransactionAndPaySubmitter`.
  * `this`: proxy
  * `msg.sender`: executor
2. `execTransactionAndPaySubmitter` calls `execute` and then `executeCall` internally.
  * `this`: proxy
  * `msg.sender`: executor
3. `executeCall` `call`s `C.foo` at address `a`
  * `this`: `a`
  * `msg.sender`: Proxy
4. `C.foo` `delegatecall`s `removeOwner` (authorized function) to Proxy, then it falls into fallback funtion.
  * `this`: `a`
  * `msg.sender`: proxy
5. fallback function `delegatecall`s `removeOwner`
  * `this`: `a`
  * `msg.sender`: proxy


4. `C.foo` `call`s `C.baz` to a
  * `this`: a
  * `msg.sender`: a

`baz` calls removeOwner
* this:

### 2. executor calls `execTransactionAndPaySubmitter(to = a, data = C.bar, operation = DelegateCall, correct signatures)`
1. fallback function `delegatecall`s `execTransactionAndPaySubmitter`.
  * `this`: _ -> Proxy
  * `msg.sender`: _ -> executor
2. `execTransactionAndPaySubmitter` calls `execute` and then `executeDelegateCall` internally.
  * `this`: Proxy
  * `msg.sender`: executor
3. `executeCall` `delegatecall`s `C.bar` at address `a`
  * `this`: Proxy
  * `msg.sender`: executor
4. storage of the Proxy is modified. || bar can call authorized function
