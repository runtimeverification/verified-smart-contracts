# Bytecode Behavior Specification of Deposit Contract

Here we summarize all possible behaviors of the compiled bytecode of the deposit contract that we formally verified.
We do not explicitly specify the out-of-gas exceptional behaviors.
Refer to [`deposit-spec.ini`](deposit-spec.ini) for the full formal specification.


## Storage state variables

- `deposit_count` (an unsigned 256-bit integer) keeps track of the number of deposits made.
- `branch` and `zero_hashes` (arrays of 32-byte words of size 32) are internal data structures for the incremental Merkle tree algorithm.


## Constructor `__init__()` (executed once at the deployment)

Behavior:
- It reverts when the call value is non-zero.
- Otherwise, it updates the storage state as follows:
  ```
  zero_hashes[i] <- ZERO_HASHES(i)  for 1 <= i < 32
  ```

Here `ZERO_HASHES(i)` is recursively defined as follows:
```
ZERO_HASHES(i+1) = #sha256(#buf(32, ZERO_HASHES(i)) ++ #buf(32, ZERO_HASHES(i)))  for 0 <= i < 31
ZERO_HASHES(0) = 0
```
where `#sha256` denotes the SHA2-256 hash function,
`#buf(SIZE, DATA)` denotes the byte representation of `DATA` in `SIZE` bytes,
and `++` denotes the byte concatenation.


## Common behavior at the entry of the deployed bytecode

- It reverts when `calldatasize < 4`.
- It reverts when `msg.data[0..4]` does not match the signature of any public functions `get_deposit_root()`, `get_deposit_count()`, or `deposit(bytes,bytes,bytes,bytes32)`.

Here `BUF [ START .. WIDTH ]` denotes the segment of `BUF` beginning with `START` of width `WIDTH`.


## Function `get_deposit_count()`

Behavior:
- It reverts when the call value is non-zero.
- It does not alter the storage state.
- It silently ignores any extra contents in `msg.data`. *(We have not yet found any attack that can exploit this behavior.)*
- It returns `#encodeArgs(#bytes(#buf(32, LE(deposit_count))[24..8]))`.
  
Here:

`#encodeArgs` is defined in [eDSL](https://github.com/kframework/evm-semantics/blob/master/edsl.md#abi-call-data) which formalizes [the ABI encoding specification](https://solidity.readthedocs.io/en/v0.6.1/abi-spec.html),
  
and:

`LE(V)` is essentially the return value of `to_little_endian_64(V)`, i.e., the 64-bit little-endian representation of `V`, defined as follows.
For `0 <= V < 2^64`:
```
LE(V) = (Y7(V) * 256) + (X7(V) & 255)
Y7(V) = (Y6(V) * 256) + (X6(V) & 255)
Y6(V) = (Y5(V) * 256) + (X5(V) & 255)
Y5(V) = (Y4(V) * 256) + (X4(V) & 255)
Y4(V) = (Y3(V) * 256) + (X3(V) & 255)
Y3(V) = (Y2(V) * 256) + (X2(V) & 255)
Y2(V) = (Y1(V) * 256) + (X1(V) & 255)
Y1(V) =                 (X0(V) & 255)
```
where:
```
X7(V) = floor(X6(V) / 256)
X6(V) = floor(X5(V) / 256)
X5(V) = floor(X4(V) / 256)
X4(V) = floor(X3(V) / 256)
X3(V) = floor(X2(V) / 256)
X2(V) = floor(X1(V) / 256)
X1(V) = floor(X0(V) / 256)
X0(V) = V
```
Note that `LE(deposit_count)` is well defined because `deposit_count < 2^32 < 2^64`.

The byte sequence of the return value is as follows (in hexadecimal notation):
```
0x0000000000000000000000000000000000000000000000000000000000000020
  0000000000000000000000000000000000000000000000000000000000000008
  deadbeefdeadbeef000000000000000000000000000000000000000000000000
```
This byte sequence encodes the returned byte array of type `bytes[8]`, where the first 32 bytes (in the first line) denote the offset (32 = `0x20`) to the byte array, the second 32 bytes (in the second line) denote the size of the byte array (8 = `0x8`), and the `deadbeefdeadbeef` (in the third line) denotes the content of the byte array, i.e., the sequence of 8 bytes that consists of `X0 & 255`, `X1 & 255`, ..., and `X7 & 255` in that order. The remaining 24 zero-bytes denote zero-padding for the 32-byte alignment. This byte sequence conforms to the ABI encoding specification. Note that the original sequence of bytes (i.e., the big-endian representation) of `deposit_count` consists of `X7 & 255`, `X6 & 255`, ..., and `X0 & 255` in that order.


## Function `get_deposit_root()`

Behavior:
- It reverts when the call value is non-zero.
- It does not alter the storage state.
- It silently ignores any extra contents in `msg.data`. *(We have not yet found any attack that can exploit this behavior.)*
- It returns `#sha256(#buf(32, NODE(32)) ++ #buf(32, LE(deposit_count))[24..8] ++ #buf(24, 0))`.

Here `NODE(32)` is the Merklee tree root value, recursively defined as follows:
```
NODE(i+1) = if SIZE(i) & 1 == 1
            then #sha256(#buf(32, branch[i]) ++ #buf(32, NODE(i)))
            else #sha256(#buf(32, NODE(i)) ++ #buf(32, zero_hashes[i]))
            for 0 <= i < 32
NODE(0) = 0
```
where:
```
SIZE(i+1) = floor(SIZE(i) / 2)  for 0 <= i < 32
SIZE(0) = deposit_count
```

`LE(deposit_count)` is the same with the one defined in the specification of the `get_deposit_count()` function above.


## Function `deposit(pubkey, withdrawal_credentials, signature, deposit_data_root)`

Behavior:
- It reverts if either of the following is not met:
  - `old(deposit_count) < 2^32 - 1`
  - `DEPOSIT_AMOUNT >= 10^9`
  - `PUBKEY_ARGUMENT_SIZE                 == PUBKEY_LENGTH`
  - `WITHDRAWAL_CREDENTIALS_ARGUMENT_SIZE == WITHDRAWAL_CREDENTIALS_LENGTH`
  - `SIGNATURE_ARGUMENT_SIZE              == SIGNATURE_LENGTH`
  - `NODE == deposit_data_root`
  
  where `old(deposit_count)` denotes the value of `deposit_count` at the beginning of the function,
  and `DEPOSIT_AMOUNT` is the amount of deposit (in gwei), that is, `floor(msg.value / 10^9)`.
- Otherwise, it emits a DepositEvent log:
  ```
  #abiEventLog(THIS, "DepositEvent",
               #bytes(#buf(PUBKEY_LENGTH, PUBKEY)),
               #bytes(#buf(WITHDRAWAL_CREDENTIALS_LENGTH, WITHDRAWAL_CREDENTIALS)),
               #bytes(#buf(32, LE(DEPOSIT_AMOUNT))[24..8]),
               #bytes(#buf(SIGNATURE_LENGTH, SIGNATURE)),
               #bytes(#buf(32, LE(old(deposit_count)))[24..8])
              )
  ```
  where `#abiEventLog` is defined in [eDSL](https://github.com/kframework/evm-semantics/blob/master/edsl.md#abi-event-logs) which formalizes [the ABI event encoding specification](https://solidity.readthedocs.io/en/v0.6.1/abi-spec.html#events),
  and `LE(V)` is the 64-bit little-endian representation of `V` which is defined in the specification of the `get_deposit_count()` function above.
  See below for the definition of the other event log arguments.

  Note that `LE(DEPOSIT_AMOUNT)` is well defined only when `DEPOSIT_AMOUNT` is less than `2^64` gwei (~ 18 billion Ether), which is very likely the case especially considering the current total supply of Ether (~ 110 million) and the history of its growth rate.
- Also, it updates the storage state as follows:
  ```
  deposit_count <- old(deposit_count) + 1
  branch[K] <- NODE(K)
  ```
  where `NODE(i)` is recursively defined as follows:
  ```
  NODE(i+1) = #sha256(#buf(32, branch[i]) ++ #buf(32, NODE(i)))  for 0 <= i < 32
  NODE(0) = NODE
  ```
  and `K` is the largest index less than 32 such that:
  ```
  SIZE(i) & 1 == 0  for 0 <= i < K
  SIZE(K) & 1 == 1
  ```
  where `SIZE(i)` is recursively defined as follows:
  ```
  SIZE(i+1) = floor(SIZE(i) / 2)  for 0 <= i < 32
  SIZE(0) = old(deposit_count) + 1
  ```
  Note that such `K` always exists, since `old(deposit_count) < 2^32 - 1` (because of the assertion at the beginning of the function).
  In other words, the loop always terminates by reaching the break statement, because of the assertion `old(deposit_count) < 2^32 - 1`.

Here:

The non-static-type function arguments (`PUBKEY`, `WITHDRAWAL_CREDENTIALS`, and `SIGNATURE`) are decoded as follows:
```
PUBKEY_OFFSET                 = (4 + msg.data[ 4..32]) mod 2^256
WITHDRAWAL_CREDENTIALS_OFFSET = (4 + msg.data[36..32]) mod 2^256
SIGNATURE_OFFSET              = (4 + msg.data[68..32]) mod 2^256

PUBKEY_ARGUMENT_SIZE                 = msg.data [ PUBKEY_OFFSET                 .. 32 ]
WITHDRAWAL_CREDENTIALS_ARGUMENT_SIZE = msg.data [ WITHDRAWAL_CREDENTIALS_OFFSET .. 32 ]
SIGNATURE_ARGUMENT_SIZE              = msg.data [ SIGNATURE_OFFSET              .. 32 ]

PUBKEY                 = msg.data [ (PUBKEY_OFFSET                 + 32) .. PUBKEY_LENGTH                 ]
WITHDRAWAL_CREDENTIALS = msg.data [ (WITHDRAWAL_CREDENTIALS_OFFSET + 32) .. WITHDRAWAL_CREDENTIALS_LENGTH ]
SIGNATURE              = msg.data [ (SIGNATURE_OFFSET              + 32) .. SIGNATURE_LENGTH              ]
```
**NOTE**: The argument decoding process of the Vyper-compiled bytecode does not explicitly check the well-formedness of the calldata (`msg.data`).
Specifically, the addition overflow may happen when decoding the offsets (`*_OFFSET`).
Also, the decoded offsets may be larger than the size of calldata, leading to out-of-bounds access, although the out-of-bounds access to calldata simply returns zero bytes.
We note that the Solidity-compiled bytecode contains more runtime checks to avoid aforementioned behaviors.
Currently, the deposit contract relies on the checksum (the `deposit_data_root` argument) to finally reject such ill-formed calldata.
We have not yet found any attack that can exploit this behavior especially in the presence of the checksum.

The deposit data root `NODE` is computed as follows:
```
PUBKEY_ROOT    = #sha256(#buf(48, PUBKEY) ++ #buf(16, 0))
TMP1           = #sha256(#buf(96, SIGNATURE)[0..64])
TMP2           = #sha256(#buf(96, SIGNATURE)[64..32] ++ #buf(32, 0))
SIGNATURE_ROOT = #sha256(#buf(32, TMP1) ++ #buf(32, TMP2))
TMP3           = #sha256(#buf(32, PUBKEY_ROOT) ++ #buf(32, WITHDRAWAL_CREDENTIALS))
TMP4           = #sha256(#buf(32, LE(DEPOSIT_AMOUNT))[24..8] ++ #buf(24, 0) ++ #buf(32, SIGNATURE_ROOT))
NODE           = #sha256(#buf(32, TMP3) ++ #buf(32, TMP4))
```

