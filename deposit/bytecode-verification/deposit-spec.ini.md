
## `__init__()`

Behavior
- revert when the call value is non-zero
- update storage:
  ```
  zero_hashes[i] <- ZERO_HASHES_i  for 1 <= i < 32
  ```

```
ZERO_HASHES_{i+1} = #sha256(#buf(32, ZERO_HASHES_i) ++ #buf(32, ZERO_HASHES_i))  for 0 <= i < 31
ZERO_HASHES_0 = 0
```


## At beginning

- revert when calldatasize < 4
- revert when msg.data[0..4] does not match to the signature of any public functions, `get_deposit_root()`, `get_deposit_count()`, and `deposit()`


## `get_deposit_root()`

Behavior
- revert when the call value is non-zero
- preserve storage
- ignore extra msg.data
- return `#sha256(#buf(32, NODE_32) ++ #bufSeg(#buf(32, Y8), 24, 8) ++ #buf(24, 0))`

where:

`NODE_32` is the Merklee tree root value, recursively defined as follows:

```
NODE_{i+1} = if SIZE_i & 1 == 1
             then #sha256(#buf(32, branch[i]) ++ #buf(32, NODE_i))
             else #sha256(#buf(32, NODE_i) ++ #buf(32, zero_hashes[i]))
             for 0 <= i < 32
NODE_0 = 0
```

with

```
SIZE_{i+1} = SIZE_i /Int 2  for 0 <= i < 32
SIZE_0 = deposit_count
```

and:

`Y8` is the return value of `to_little_endian_64(deposit_count)`, defined as follows:

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
X8 = X7            /Int 256
X7 = X6            /Int 256
X6 = X5            /Int 256
X5 = X4            /Int 256
X4 = X3            /Int 256
X3 = X2            /Int 256
X2 = X1            /Int 256
X1 = deposit_count /Int 256
```

where

```
N /Int M = floor(N / M)
```


## `get_deposit_count()`

Behavior
- revert when the call value is non-zero
- preserve storage
- ignore extra msg.data
- return `#encodeArgs(#bytes(#bufSeg(#buf(32, Y8), 24, 8)))`


## `deposit(pubkey, withdrawal_credentials, signature, deposit_data_root)`

Behavior
- revert if either of the following is not met:
  - `old(deposit_count) < 2^32 - 1`
  - `msg.value /Int 10^9 >= 10^9`
  - `PUBKEY_ARRAY_SIZE                 == PUBKEY_LENGTH`
  - `WITHDRAWAL_CREDENTIALS_ARRAY_SIZE == WITHDRAWAL_CREDENTIALS_LENGTH`
  - `SIGNATURE_ARRAY_SIZE              == SIGNATURE_LENGTH`
  - `NODE == deposit_data_root`
- emit DepositEvent log:
  ```
  #abiEventLog(THIS, "DepositEvent",
              #bytes(#buf(PUBKEY_LENGTH, PUBKEY)),
              #bytes(#buf(WITHDRAWAL_CREDENTIALS_LENGTH, WITHDRAWAL_CREDENTIALS)),
              #bytes(#bufSeg(#buf(32, YY8), 24, 8)),
              #bytes(#buf(SIGNATURE_LENGTH, SIGNATURE)),
              #bytes(#bufSeg(#buf(32, Y8), 24, 8))
              )
  ```
- update storage:
  ```
  deposit_count <- old(deposit_count) + 1
  branch[K] <- NODE_K
  ```

```
NODE_{i+1} = #sha256(#buf(32, branch[i]) ++ #buf(32, NODE_i))  for 0 <= i < 32 - 1
NODE_0 = NODE

SIZE_{i+1} = SIZE_i /Int 2  for 0 <= i < 32 - 1
SIZE_0 = old(deposit_count) + 1
```
Note that `i < 32 - 1`, since the break statement is always executed because `old(deposit_count) < 2^32 - 1`.

K is the largest index less than 32 such that:
```
SIZE_i & 1 == 0  for 0 <= i < K
SIZE_K & 1 == 1
```
Note that such K always exists, since `old(deposit_count) < 2^32 - 1`.


where:

```
PUBKEY_OFFSET:                 4 +Word msg.data [  4 .. 32 ]
WITHDRAWAL_CREDENTIALS_OFFSET: 4 +Word msg.data [ 36 .. 32 ]
SIGNATURE_OFFSET:              4 +Word msg.data [ 68 .. 32 ]

PUBKEY:                 msg.data [ PUBKEY_OFFSET                 + 32 .. PUBKEY_LENGTH                 ]
WITHDRAWAL_CREDENTIALS: msg.data [ WITHDRAWAL_CREDENTIALS_OFFSET + 32 .. WITHDRAWAL_CREDENTIALS_LENGTH ]
SIGNATURE:              msg.data [ SIGNATURE_OFFSET              + 32 .. SIGNATURE_LENGTH              ]

PUBKEY_ARRAY_SIZE:                 msg.data [ PUBKEY_OFFSET                 .. 32 ]
WITHDRAWAL_CREDENTIALS_ARRAY_SIZE: msg.data [ WITHDRAWAL_CREDENTIALS_OFFSET .. 32 ]
SIGNATURE_ARRAY_SIZE:              msg.data [ SIGNATURE_OFFSET              .. 32 ]


PUBKEY_ROOT: #sha256(#buf(48, PUBKEY) ++ #buf(16, 0))
TMP1: #sha256(#bufSeg(#buf(96, SIGNATURE), 0, 64))
TMP2: #sha256(#bufSeg(#buf(96, SIGNATURE), 64, 32) ++ #buf(32, 0))
SIGNATURE_ROOT: #sha256(#buf(32, TMP1) ++ #buf(32, TMP2))
TMP3: #sha256(#buf(32, PUBKEY_ROOT) ++ #buf(32, WITHDRAWAL_CREDENTIALS))
TMP4: #sha256(#bufSeg(#buf(32, YY8), 24, 8) ++ #buf(24, 0) ++ #buf(32, SIGNATURE_ROOT))
NODE: #sha256(#buf(32, TMP3) ++ #buf(32, TMP4))
```

`WS [ N .. W ]` access the range of `WS` beginning with `N` of width `W`.


```
YY1 ==     DEPOSIT_AMOUNT & 255
YY2 == (YY1 * 256) + (XX1 & 255)
YY3 == (YY2 * 256) + (XX2 & 255)
YY4 == (YY3 * 256) + (XX3 & 255)
YY5 == (YY4 * 256) + (XX4 & 255)
YY6 == (YY5 * 256) + (XX5 & 255)
YY7 == (YY6 * 256) + (XX6 & 255)
YY8 == (YY7 * 256) + (XX7 & 255)

XX1 == DEPOSIT_AMOUNT /Int 256
XX2 == XX1            /Int 256
XX3 == XX2            /Int 256
XX4 == XX3            /Int 256
XX5 == XX4            /Int 256
XX6 == XX5            /Int 256
XX7 == XX6            /Int 256
XX8 == XX7            /Int 256

DEPOSIT_AMOUNT == msg.value /Int 10^9
```
