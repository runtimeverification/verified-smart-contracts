# Bytecode Behavior Specification of Deposit Contract

Here we specify all possible behaviors of the compiled bytecode of the deposit contract that we formally verified.
We do not explicitly specify the out-of-gas exception.


## Constructor `__init__()` (executed once at the deployment)

Behavior:
- It reverts when the call value is non-zero.
- Otherwise, it updates the storage state as follows:
  ```
  zero_hashes[i] <- ZERO_HASHES_i  for 1 <= i < 32
  ```
  where `ZERO_HASHES_i` is recursively defined as follows:
  ```
  ZERO_HASHES_{i+1} = #sha256(#buf(32, ZERO_HASHES_i) ++ #buf(32, ZERO_HASHES_i))  for 0 <= i < 31
  ZERO_HASHES_0 = 0
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
- It returns `#encodeArgs(#bytes(#buf(32, Y8)[24..8]))`,
  
  where:

  `#encodeArgs` is defined in [eDSL](https://github.com/kframework/evm-semantics/blob/master/edsl.md#abi-call-data) which formalizes [the ABI encoding specification](https://solidity.readthedocs.io/en/v0.6.1/abi-spec.html),
  
  and:

  `Y8` is the return value of `to_little_endian_64(deposit_count)`, i.e., the 64-bit little-endian representation of `deposit_count`, defined as follows:
  ```
  Y8 = (Y7 * 256) + (X7 & 255)
  Y7 = (Y6 * 256) + (X6 & 255)
  Y6 = (Y5 * 256) + (X5 & 255)
  Y5 = (Y4 * 256) + (X4 & 255)
  Y4 = (Y3 * 256) + (X3 & 255)
  Y3 = (Y2 * 256) + (X2 & 255)
  Y2 = (Y1 * 256) + (X1 & 255)
  Y1 =    deposit_count & 255
  ```
  with
  ```
  X7 = floor(X6            / 256)
  X6 = floor(X5            / 256)
  X5 = floor(X4            / 256)
  X4 = floor(X3            / 256)
  X3 = floor(X2            / 256)
  X2 = floor(X1            / 256)
  X1 = floor(deposit_count / 256)
  ```
  Note that `to_little_endian_64(deposit_count)` is well defined because `deposit_count < 2^32 < 2^64`.


## Function `get_deposit_root()`

Behavior:
- It reverts when the call value is non-zero.
- It does not alter the storage state.
- It silently ignores any extra contents in `msg.data`. *(We have not yet found any attack that can exploit this behavior.)*
- It returns `#sha256(#buf(32, NODE_32) ++ #buf(32, Y8)[24..8] ++ #buf(24, 0))`.

  where:

  `NODE_32` is the Merklee tree root value, recursively defined as follows:
  ```
  NODE_{i+1} = if SIZE_i & 1 == 1
               then #sha256(#buf(32, branch[i]) ++ #buf(32, NODE_i))
               else #sha256(#buf(32, NODE_i) ++ #buf(32, zero_hashes[i]))
               for 0 <= i < 32
  NODE_0 = 0
  ```
  where:
  ```
  SIZE_{i+1} = floor(SIZE_i / 2)  for 0 <= i < 32
  SIZE_0 = deposit_count
  ```


## Function `deposit(pubkey, withdrawal_credentials, signature, deposit_data_root)`

Behavior:
- It reverts if either of the following is not met:
  - `old(deposit_count) < 2^32 - 1`
  - `floor(msg.value / 10^9) >= 10^9`
  - `PUBKEY_ARGUMENT_SIZE                 == PUBKEY_LENGTH`
  - `WITHDRAWAL_CREDENTIALS_ARGUMENT_SIZE == WITHDRAWAL_CREDENTIALS_LENGTH`
  - `SIGNATURE_ARGUMENT_SIZE              == SIGNATURE_LENGTH`
  - `NODE == deposit_data_root`
- Otherwise, it emits a DepositEvent log:
  ```
  #abiEventLog(THIS, "DepositEvent",
               #bytes(#buf(PUBKEY_LENGTH, PUBKEY)),
               #bytes(#buf(WITHDRAWAL_CREDENTIALS_LENGTH, WITHDRAWAL_CREDENTIALS)),
               #bytes(#buf(32, YY8)[24..8]),
               #bytes(#buf(SIGNATURE_LENGTH, SIGNATURE)),
               #bytes(#buf(32, Y8)[24..8])
              )
  ```
  where `#abiEventLog` is defined in [eDSL](https://github.com/kframework/evm-semantics/blob/master/edsl.md#abi-event-logs) which formalizes [the ABI event encoding specification](https://solidity.readthedocs.io/en/v0.6.1/abi-spec.html#events).
  See below for the definition of the event log arguments.
- Also, it updates the storage state as follows:
  ```
  deposit_count <- old(deposit_count) + 1
  branch[K] <- NODE_K
  ```
  where `NODE_i` is recursively defined as follows:
  (Note that `i < 32 - 1`, since the break statement is always executed because `old(deposit_count) < 2^32 - 1`.)
  ```
  NODE_{i+1} = #sha256(#buf(32, branch[i]) ++ #buf(32, NODE_i))  for 0 <= i < 32 - 1
  NODE_0 = NODE
  ```
  and `K` is the largest index less than 32 such that:
  ```
  SIZE_i & 1 == 0  for 0 <= i < K
  SIZE_K & 1 == 1
  ```
  where `SIZE_i` is recursively defined as follows:
  ```
  SIZE_{i+1} = floor(SIZE_i / 2)  for 0 <= i < 32 - 1
  SIZE_0 = old(deposit_count) + 1
  ```
  Note that such K always exists, since `old(deposit_count) < 2^32 - 1`.
  
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
Currently, the deposit contract relies on the checksum (`deposit_data_root`) to finally reject ill-formed calldata.
We have not yet found any attack that can exploit this behavior in the presence of the checksum.

The deposit data root `NODE` is computed as follows:
```
PUBKEY_ROOT    = #sha256(#buf(48, PUBKEY) ++ #buf(16, 0))
TMP1           = #sha256(#buf(96, SIGNATURE)[0..64])
TMP2           = #sha256(#buf(96, SIGNATURE)[64..32] ++ #buf(32, 0))
SIGNATURE_ROOT = #sha256(#buf(32, TMP1) ++ #buf(32, TMP2))
TMP3           = #sha256(#buf(32, PUBKEY_ROOT) ++ #buf(32, WITHDRAWAL_CREDENTIALS))
TMP4           = #sha256(#buf(32, YY8)[24..8] ++ #buf(24, 0) ++ #buf(32, SIGNATURE_ROOT))
NODE           = #sha256(#buf(32, TMP3) ++ #buf(32, TMP4))
```

The 64-bit little endian representation of the deposit amount, `to_little_endian_64(deposit_amount)`, is computed as follows:
```
YY8 = (YY7 * 256) + (XX7 & 255)
YY7 = (YY6 * 256) + (XX6 & 255)
YY6 = (YY5 * 256) + (XX5 & 255)
YY5 = (YY4 * 256) + (XX4 & 255)
YY4 = (YY3 * 256) + (XX3 & 255)
YY3 = (YY2 * 256) + (XX2 & 255)
YY2 = (YY1 * 256) + (XX1 & 255)
YY1 =     DEPOSIT_AMOUNT & 255

XX7 = floor(XX6            / 256)
XX6 = floor(XX5            / 256)
XX5 = floor(XX4            / 256)
XX4 = floor(XX3            / 256)
XX3 = floor(XX2            / 256)
XX2 = floor(XX1            / 256)
XX1 = floor(DEPOSIT_AMOUNT / 256)

DEPOSIT_AMOUNT = floor(msg.value / 10^9)
```
Note that `to_little_endian_64(deposit_amount)` is well defined only when `deposit_amount` is less than `2^64` gwei (~ 18 billion Ether), which is very likely the case especially considering the current total supply of Ether (~ 110 million).
