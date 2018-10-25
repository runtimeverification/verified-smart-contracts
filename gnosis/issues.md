## `checkSignatures`

### Local validity check

`checkSignatures` checks only the first `threshold` number of signatures.
Thus, the validity of the remaining signatures does not matter.
Also, the sortedness of the whole signatures is not required, as long as the first `threshold` number of signatures are locally sorted.
However, we have not found an attack exploiting this.

Another questionable behavior is in the case where there are `threshold` valid signatures in total, but some of them at the beginning are invalid. Currently, `checkSignatures` fails in this case.
A potential issue for this behavior is that a *bad* owner intentionally sends an invalid signature to *veto* the transaction. He can *always* veto if his address is the first (the smallest) among the owners. On the other hand, a *good* owner is hard to veto some bad transaction if his address is the last (the lartest) among the owners.
Is this intended?

### Exceptional behavior of `isValidSignature`

For the following code:
```
if (!ISignatureValidator(currentOwner).isValidSignature(data, contractSignature)) {
```
It is not clear what will happen if the external `isValidSignature` function does not return at all.
Similarly, what if the `currentOwner` contract does not implement `isValidSignature` function at all, but have the default fallback function? (Note that the default fallback function cannot return anything.)

It depends on the bytecode behavior.
If the bytecode does not reset the return memory address, it may reuse the garbage value previously returned by the `lastOwner.isValidSignature`, and it is exploitable.

Even if the current Solidity compiler generates the robust bytecode, a future version may not.
Thus, it is required to re-verify the bytecode once the compiler version is updated.

In the current bytecode, it checks the existence of the return value using `returndatasize`:
https://github.com/runtimeverification/verified-smart-contracts/blob/master/gnosis/generated/GnosisSafe.evm#L9704-L9721

### Memory copy

In `checkSignatures`, the argument `signatures` is first loaded into the local memory from the call data (not into the stack). Then, when it calls `isValidSignature`, it performs the memory-to-memory copy to prepare for the `contractSignature` argument (part of the `signatures` bytes).  Now, it is required in the bytecode that these two memory regions do not overlap.  Otherwise the memory-to-memory copy is not sound.

It also depends on the compiler version.

### `signatures` size limit

Considering the [current max block gas limit] (~8M) and the gas cost for the local memory usage (i.e., `n^2/512 + 3n` for `n` bytes), the size of `signatures` must be (much) less than 2^16 (i.e., 64KB). 


[current max block gas limit]: <https://etherscan.io/blocks>
