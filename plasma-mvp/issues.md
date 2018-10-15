## malicious library
Since this scenario requires correct set of signatures,
the risk is reduced if the library code is verified to be safe.
```solidity
contract C {
  function foo() {
    owners[SENTINEL_OWNERS] = SENTINEL_OWNERS;
  }
  function bar() {
    call(to=proxy, data=removeOwner(..));
  }
}
```
Contract C deployed at address `a`.
### 1. executor calls `execTransactionAndPaySubmitter(to = a, data = C.foo, operation = DelegateCall, correct signatures)`
1. fallback function `delegatecall`s `execTransactionAndPaySubmitter`.
  * `this`: Proxy
  * `msg.sender`: executor
2. `execTransactionAndPaySubmitter` calls `execute` and then `executeDelegateCall` internally.
  * `this`: Proxy
  * `msg.sender`: executor
3. `executeDelegateCall` `delegatecall`s `C.foo` at address `a`
  * `this`: Proxy
  * `msg.sender`: executor
4. storage of the Proxy is modified.

### 2.executor calls `execTransactionAndPaySubmitter(data = C.foo,...)`
1. ~3. same as above.
4. `C.bar` `call`s `removeOwner` to proxy
  * `this`: proxy
  * `msg.sender`: proxy
  * ==> `authorized`
