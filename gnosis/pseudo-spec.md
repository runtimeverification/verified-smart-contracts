## SelfAuthorized

## MasterCopy
### `address masterCopy`

### `changeMasterCopy(address _masterCopy) public authorized`

#### Post
* `msg.sender == address(this)`
* `_masterCopy != 0`

#### post
* `masterCopy == _masterCopy`


## OwnerManager

### `address public constant SENTINEL_OWNERS = address(0x1)`

### `mapping(address=>address) internal owners`

### `uint256 ownerCount`

### `uint256 internal threshold`

### `setupOwners(address[] _owners, uint8 _threshold) internal`

#### pre
* internal
  * `this == proxy`
* `threshold == 0`
* valid threshold
  * `1 <= _threshold <= _owners.length`
* valid owners
  * forall `i` in `[0 .. _owners.length-1]`, `_owners[i] != 0 && _owners[i] != SENTINEL_OWNERS`
  * forall `i`,`j` in `[0 .. _owners.length-1]` `i != j`, `_owners[i] != _owners[j]`  

#### post
* linked list of owners
  * `owners[SENTINEL_OWNERS] == _owners[_owners[0]]`
  * forall `i` in `[0 .. _owners.length-2]`, `owners[_owners[i]] == owners[_owners[i+1]]`
  * `owners[_owners[_owners.length-1]] == SENTINEL_OWNERS`
* `threshold == _threshold`
* `ownerCount == _owners.length`

#### note
* expected to be called by `GnosisSafe.setup` internally, only once

### `addOwnerWithThreshold(address owner, uint8 _threshold) public authorized`

#### Pre
* authorized
  * `msg.sender == address(this)`
* valid owner
  * `owner != 0 && owner != SENTINEL_OWNERS`
  * `owners[owner] == 0`
* valid threshold if `threshold != _threshold`
  * `1 <= _threshold <= ownerCount`

#### Post
* `owners[owner] = owners[SENTINEL_OWNERS]`
* `owners[SENTINEL_OWNERS] = owner`
* `ownerCount++`
* `threshold == _threshold`

### `removeOwner(address prevOwner, address owner, uint8 _threshold) public authorized`

#### Pre
* authorized
  * `msg.sender == address(this)`
* valid threshold
  * `ownerCount - 1 >= _threshold`
* valid threshold if `threshold != _threshold`
  * `1 <= _threshold <= ownerCount`
* valid owner pair
  * `owner != 0 && owner != SENTINEL_OWNERS`
  * `owners[prevOwner] == owner`

#### Post
* `owners[prevOwner] == owners[owner]`
* `owners[owner] == 0`
* `ownerCount--`
* `threshold == _threshold`

### `swapOwner(address prevOwner, address oldOwner, address newOwner) public authorized`

#### Pre
* authorized
  * `msg.sender == address(this)`
* valid owner triple
  * `newOwner != 0 && newOwner != SENTINEL_OWNERS`
  * `owners[newOwner] == 0`
  * `oldOwner != 0 && oldOwner != SENTINEL_OWNERS`
  * `owners[prevOwner] == oldOwner`

#### Post
* `owners[newOwner] == owners[oldOwner]`
* `owners[prevOwner] == newOwner`
* `owners[oldOwner] == 0`

### `changeThreshold(uint8 _threshold) public authorized`

#### Pre
* authorized
  * `msg.sender == address(this)`
* valid threshold
  * `1 <= _threshold <= ownerCount`

#### Post
* `threshold == _threshold`


## `ModuleManager`

### `address public constant SENTINEL_MODULES = address(0x1)`

### `mapping (address => address) internal modules`

### `() external payable`

#### note
* accepts Ether transaction

### `setupModules(address to, bytes data) internal`
* internal
  * `this == proxy`
* `modules[SENTINEL_MODULES] == 0`

#### post
* if `to == 0`, `modules[SENTINEL_MODULES] == SENTINEL_MODULES`

#### note
* expected to be called by `GnosisSafe.setup` internally, only once
* Modules are added by `executeDelegateCall` to address where `CreateAndAddModules` contract is deployed.

### `enableModule(Module module) public authorized`

#### Pre
* authorized
  * `msg.sender == address(this)`
* valid module
  * `address(module) != 0 && address(module) != SENTINEL_MODULES`

#### Post
* `modules[module] == modules[SENTINEL_MODULES]`
* `modules[SENTINEL_MODULES] == module`

### `disableModule(Module prevModule, Module module) public authorized`

#### Pre
* authorized
  * `msg.sender == address(this)`

#### Post
* `modules[prevModule] == modules[module]`
* `modules[module] == 0`

### `execTransactionFromModule(address to, uint256 value, bytes data, Operation operation) public returns (bool success)`

#### Pre
* called by registered module
  * `modules[msg.sender] != 0`

### `execute(address to, uint256 value, bytes data, Enum.Operation operation, uint256 txGas) internal returns (bool success)`

#### Pre
* internal
  * `this == proxy`
* called internally by `execTransactionFromModule` or `execTransactionAndPaySubmitter`

### `executeCall(address to, uint256 value, bytes data, uint256 txGas) internal returns (bool success)`

### `executeDelegateCall(address to, bytes data, uint256 txGas) internal returns (bool success)`

### `executeCreate(bytes data) internal returns (address newContract)`


## SignatureValidator

### `recoverKey(bytes32 txHash, bytes messageSignature, int256 pos) pure public returns (address)`

### `signatureSplit(bytes signatures, uint256 pos) pure public returns (uint8 v, bytes32, bytes32 s)`


## GnosisSafe

### `setup(address[] _owners, uint8 _threshold, address to, bytes data) public`

#### notes
called once by proxy factory to proxy


## GnosisSafePersonalEdition

### `uint256 public nonce`
#### notes
Any functions (including `execute` functions) other than `execTransactionAndPaySubmitter` should not modify `nonce`,
while other storage variables can be modified when authorized.


### `execTransactionAndPaySubmitter`
    (
        address to,
        uint256 value,
        bytes data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 dataGas,
        uint256 gasPrice,
        address gasToken,
        bytes signatures
    )
        public
        returns (bool success)

#### Pre
* `msg.sender == executor`, `this == proxy`
* `tx.origin == executor`
* `checkHash(getTransactionHash(..), signatures)` succeeds.
  * recovered keys sorted by strictly increasing order
  * more than `threshold` keys
* no overflow
  * `uint256 gasCosts = (startGas - gasleft()) + dataGas <= maxUInt256`
  * `uint256 amount = gasCosts * gasPrice <= maxUInt256`

#### Post
* executor is paid
  * if `gasToken == address(0)`, `executor.balance += amount`
  * otherwise, `gasToken.balanceOf(executor) += amount` => how?
* `nonce++`
* if `execute` failed, emit `ExecutionFailed(txHash)`

#### notes
* `tx.origin.send(amount)` -> why not transfer?, `executor`'s fallback funciton?
  * `this == tx.origin`, `msg.sender == proxy` what if `proxy == tx.origin`?

### `requiredTxGas(..) public authorized returns (uint256)`

#### Pre
* authorized
  * `msg.sender == address(this)`

#### Post
* reverted, with `requiredGas` message

### `checkHash(bytes32 txHash, bytes signatures) internal view`

#### Pre
* internal
* view
* recovered key sorted in strictly increasing order

### `getTransactionHash(..) public view returns (byte32)`

#### Pre
* `this == proxy`

## Proxy

### `address masterCopy`

#### notes
* must have the same storage location as Proxy

### `() external payable`



## Libraries
Since the proxy can `executeDelegateCall` any external contracts (libraries),
there should be a guarantee that it does not run any unexpected operations.

### 1. Library should not access storage variables

### 2. Library functions should not `call` proxy (= `this`).
Inside the `executeDelegateCall`ed library function, `this == proxy`.
If it `call`s proxy, `this == proxy` and `msg.sender == proxy`


## Modules
Modules registered to a GnosisSafePersonalEdition wallet are also proxy contracts.
