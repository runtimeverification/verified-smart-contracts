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


### Specification

We first define `the-first-invalid-signature-index` as follows:
- A1:  for all `i < the-first-invalid-signature-index`,  `signatures[i]` is valid.
- A2:  `signatures[the-first-invalid-signature-index]` is NOT valid.

Now we formulate the behavior of `checkSignatures` as follows:
- T1:  `checkSignatures` returns true if `the-first-invalid-signature-index >= threshold`.
- T2:  otherwise, returns false.

To prove that, we need the loop invariant as follows:
For some `i` such that `0 <= i < threshold` and `i <= the-first-invalid-signature-index`:
- L1:  if `i < threshold <= the-first-invalid-signature-index`, then return true.
- L1:  else (i.e., if `i <= the-first-invalid-signature-index < threshold`), then return false.

====

Proof sketch.

The top level specification:
- T1:  by L1 with `i = 0`.
- T2:  by L2 with `i = 0`.

The loop invariant:
- L1:
  By A1, signatures[i] is valid.  Then by M1, it goes back to the loop head, and we have two cases:
  - Case 1: `i + 1 = threshold`: it jumps out of the loop, and return true.
  - Case 2: `i + 1 < threshold`: by circular reasoning with L1.
- L2:
  - Case 1: `i = the-first-invalid-signature-index`:
    By A2, signatures[i] is NOT valid.  Then, by M2, we conclude.
  - Case 2: `i < the-first-invalid-signature-index`:
    By A1, signatures[i] is valid. Then, by M1, it goes to the loop head, and by the circular reasoning with L2, we conclude (since we know that `i + 1 <= the-first-invalid-signature-index < threshold`).


We need to prove the following claims, but it can be done with looking at the loop body only.
- M1:  if signatures[i] is valid, it continues to the next iteration (i.e., goes back to the loop head).
- M2:  if signatures[i] is NOT valid, it returns false.
