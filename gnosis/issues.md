### checkSignatures

`checkSignatures` checks only the first `threshold` number of signatures.
Thus, the validity of the remaining signatures does not matter.
Also, the sortedness of the whole signatures is not required, as long as the first `threshold` number of signatures are locally sorted.
However, we have not found an attack exploiting this.

### isValidSignature

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
