# Formal Specification of GnosisSafe Contract

This presents a formal specification of the GnosisSafe contract.
The specification is against the code from commit ID [`427d6f7`][v0.1.0] of the `gnosis/safe-contracts` Github repository.

The specifications are written in [eDSL], a domain-specific language for EVM specifications, which must be known in order to thoroughly understand our EVM-level specifications.
Refer to [resources] for background on our technology.


## GnosisSafe contract

The GnosisSafe contract provides the main function `execTransaction` as the main entry point of the whole contract.
The function takes a user transaction as input, and executes it if its signatures are valid.


#### Pre-conditions of accounts:

We first assume that there are more than or equal to five accounts deployed on-chain: the master copy account, the proxy account, the transaction sender (`tx.origin`) account, the transaction target (`to`) account, and the payment receiver (`refundReceiver`) account. Note that the master copy, the proxy, and the transaction sender accounts must be distinct, since a transaction cannot be sent from a contract account, while the transaction target and the payment receiver accounts may be the same with another. We assume nothing about their balances but their values being within the range of `uint256` (i.e., 0 to 2^256 - 1, inclusive).

```ini
[root]
code: {MASTER_COPY_CODE}
comment:
callDepth: CD
; account 1 has to be active, otherwise there will be branching on <k>: #accountNonexistent(1)
activeAccounts: SetItem(#MASTER_COPY_ID) SetItem(#PROXY_ID) SetItem(#ORIGIN_ID) SetItem(#EXEC_ACCT_TO) SetItem(#REFUND_RECEIVER) SetItem(1) _:Set
; master_copy
master_copy_bal: MASTER_BAL
master_copy_storage: _
master_copy_origstorage: _
master_copy_nonce: _
; proxy
proxy_bal: PROXY_BAL
proxy_storage: _
proxy_origstorage: _
proxy_nonce: _
; origin
origin_bal: ORIGIN_BAL
origin_code: _
origin_storage: _
origin_origstorage: _
origin_nonce: _
; acct_to
acct_to_bal: ACCT_TO_BAL
acct_to_code: _
acct_to_storage: _
acct_to_origstorage: _
acct_to_nonce: _
; refund_receiver
receiver_bal: RECEIVER_BAL
receiver_code: _
receiver_storage: _
receiver_origstorage: _
receiver_nonce: _
accounts:
requires:
    andBool #rangeUInt(256, MASTER_BAL)
    andBool #rangeUInt(256, PROXY_BAL)
    andBool #rangeUInt(256, ORIGIN_BAL)
    andBool #rangeUInt(256, ACCT_TO_BAL)
    andBool #rangeUInt(256, RECEIVER_BAL)
ensures:
attribute:
```


### Function signatureSplit

[`signatureSplit`] is an internal function that takes a sequence of signatures and an index, and returns the indexed signature as a tuple of its `v`, `r`, and `s` fields.

```
    function signatureSplit(bytes memory signatures, uint256 pos)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
```

#### Stack and memory:

The function takes two inputs, `signatures` and `pos`, where `signatures` is passed through the memory while `pos` is through the stack.

The input stack is given as follows:
```
POS : SIGS_LOC : RETURN_LOC : WS
```
where `POS` is the value of `pos`, and `SIGS_LOC` is the starting location of the memory that stores the `signatures` byte buffer.

**NOTE**: Throughout this specification, `RETURN_LOC` is the return address (PC value), and `WS` is the caller's stack frame, which are not relevant for the current function's behavior.


The memory stores the `signatures` buffer starting at the location `SIGS_LOC`, where it first stores the size of the buffer `SIGS_LEN`, followed by the actual buffer `SIGNATURES`, as illustrated below:

```
|<-  32  ->|<-    SIGS_LEN    ->|
+----------+--------------------+
| SIGS_LEN |     SIGNATURES     |
+----------+--------------------+
^          ^                    ^
|          |                    |
SIGS_LOC   SIGS_LOC + 32        SIGS_LOC + 32 + SIGS_LEN
```

The function's return value is a tuple of `(v, r, s)`, which is pushed into the stack, as in the following output stack:
```
RETURN_LOC : S : R : V : WS
```
where
* `R`: 32 bytes from the offset `65 * POS`      of `SIGNATURES`
* `S`: 32 bytes from the offset `65 * POS + 32` of `SIGNATURES`
* `V`: 1  byte  at   the offset `65 * POS + 64` of `SIGNATURES`

#### Function visibility and modifiers:

The function cannot be directly called from outside, as it is `internal`.
An external call to this function will silently terminate with no effect (and no exception).

The function does not update the storage, as it is marked `pure`.



#### Pre-conditions:

No overflow:
- The input stack size is small enough to avoid the stack overflow.
- The maximum memory location accessed, i.e., `SIGS_LOC + 32 + (65 * POS + 65)`, is small enough to avoid the integer overflow for the pointer arithmetic.

It is practically reasonable to assume that the no-overflow conditions are met. If they are not satisfied, the function will throw.

Well-formed input:
- No index out of bounds, i.e., `(POS + 1) * 65 <= SIGS_LEN`

The input well-formedness condition is satisfied in all calling contexts of the current GnosisSafe contract.


#### Mechanized formal specification:

Below is the specification that we verified against the GnosisSafe contract bytecode.

```ini
[signatureSplit]
k: #execute ~> _
output: _
statusCode: _
callStack: _
this: #PROXY_ID
msg_sender: MSG_SENDER
callData: _
callValue: 0
wordStack: POS : SIGS_LOC : RETURN_LOC : WS =>
           RETURN_LOC : #asWord(#bufSeg(SIGS_BUF, 65 *Int POS +Int 32, 32))
                      : #asWord(#bufSeg(SIGS_BUF, 65 *Int POS,         32))
                      :         #bufElm(SIGS_BUF, 65 *Int POS +Int 64)      : WS
pc: 22163 => 22209
gas: #gas(INITGAS, NONMEMGAS, MEMGAS) => #gas(INITGAS, NONMEMGAS +Int 111, MEMGAS +Int (Cmem(BYZANTIUM, FINAL_MEM_USAGE) -Int Cmem(BYZANTIUM, MU)))
memoryUsed: MU => FINAL_MEM_USAGE
log: _
refund: _
coinbase: _
+requires:
    andBool #rangeUInt(256, SIGS_LOC)
    andBool #rangeAddress(MSG_SENDER)

    andBool #range(0 <= #sizeWordStack(WS) <= 1000)
    andBool #range(0 <= CD < 1024)

    andBool LAST_LOC ==Int SIGS_LOC +Int (65 *Int POS +Int 65)
    andBool FINAL_MEM_USAGE ==K #memoryUsageUpdate(MU, LAST_LOC, 32)

    andBool 0 <=Int POS
    andBool (POS +Int 1) *Int 65 <=Int SIGS_LEN
    andBool LAST_LOC +Int 32 <Int pow256

[signatureSplit-proof]
localMem: storeRange(storeRange(M, SIGS_LOC        , 32      , #buf(32, SIGS_LEN)),
                                   SIGS_LOC +Int 32, SIGS_LEN, #buf(SIGS_LEN, SIGNATURES))
+requires:
    andBool SIGS_BUF ==K #buf(SIGS_LEN, SIGNATURES)
```

Below is the specification to be used when verifying other (caller) functions.

```ini
[signatureSplit-trusted]
localMem: M
+requires:
    andBool SIGS_LEN ==Int #asWord(selectRange(M, SIGS_LOC, 32))
    andBool SIGS_BUF ==K selectRange(M, SIGS_LOC +Int 32, SIGS_LEN)
+attribute: [trusted, matching(#gas)]
```


### Function encodeTransactionData

[`encodeTransactionData`] is a public function that calculates the hash value of the given transaction data.

```
    function encodeTransactionData(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 dataGas,
        uint256 gasPrice,
        address gasToken,
        address refundReceiver,
        uint256 _nonce
    )
        public
        view
        returns (bytes memory)
```

#### Stack and memory:

The function is `public`, to which both internal and external calls can be made.
One of the main differences between the two types of calls is how to pass the input.
The internal call passes the input through the stack and the memory, while the external call passes the input through the call data.

For the internal call, the input stack is given as follows:
```
NONCE : REFUND_RECEIVER : GAS_TOKEN : GAS_PRICE : DATA_GAS : SAFE_TX_GAS : OPERATION : DATA_LOC : VALUE : TO : RETURN_LOC : WS
```
where the first ten elements are the function arguments in reverse order, while `DATA_LOC` is a memory pointer to the actual buffer of `data`.
Note that `OPERATION` is encoded as `unit8`.

The memory stores the `data` buffer starting at the location `DATA_LOC`, where it first stores the size of the buffer, followed by the actual buffer bytes, as illustrated below:
```
|<-  32  ->|<-    DATA_LEN    ->|
+----------+--------------------+
| DATA_LEN |      DATA_BUF      |
+----------+--------------------+
^          ^                    ^
|          |                    |
DATA_LOC   DATA_LOC + 32        DATA_LOC + 32 + DATA_LEN
```

The output stack consists of:
```
RETURN_LOC : OUT_LOC : WS
```

For the internal call, the return value (buffer) is passed through the memory, being stored at the starting location `OUT_LOC`, as follows:
```
|<- 32 ->|<- 1 ->|<- 1 ->|<-      32      ->|<-    32    ->|
+--------+-------+-------+------------------+--------------+
|   66   |  0x19 |  0x01 | DOMAIN_SEPARATOR | SAFE_TX_HASH |
+--------+-------+-------+------------------+--------------+
^        ^               ^                  ^              ^
|        |               |                  |              |
OUT_LOC  OUT_LOC + 32    OUT_LOC + 34       OUT_LOC + 66   OUT_LOC + 98
```
Here the first 32 bytes denote the size of the buffer, and the remaining 66 bytes denote the result of `abi.encodePacked(byte(0x19), byte(0x01), domainSeparator, safeTxHash)`.
Note that the first two elements, `0x19` and `0x01`, are not aligned, because of the use of `abi.encodePacked` instead of `abi.encode`.
Also, `SAFE_TX_HASH` is the result of `abi.encode(SAFE_TX_TYPEHASH, to, value, keccak256(data), operation, safeTxGas, dataGas, gasPrice, gasToken, refundReceiver, _nonce)`, where each argument is 32-byte aligned with zero padding on the left.


For the external call, on the other hand, the return value (buffer) is encoded, in the ABI format, as follows:
```
|<- 32 ->|<- 32 ->|<- 1 ->|<- 1 ->|<-      32      ->|<-    32    ->|<- 30 ->|
+--------+--------+-------+-------+------------------+--------------+--------+
|   32   |   66   |  0x19 |  0x01 | DOMAIN_SEPARATOR | SAFE_TX_HASH |    0   |
+--------+--------+-------+-------+------------------+--------------+--------+
```
Here the prefix (the first 32 bytes) and the postfix (the last 30 bytes) are attached, compared to that of the internal call.
The prefix is the offset to the start of the return value buffer, and the postfix is the zero padding for the alignment.



For the internal call, the output memory is as follows:
```
|<-  32  ->|<-    DATA_LEN    ->|<- X ->|<-               384                 ->|<- 32 ->|<- 1 ->|<- 1 ->|<-      32      ->|<-    32    ->|
+----------+--------------------+-------+---------------------------------------+--------+-------+-------+------------------+--------------+
| DATA_LEN |      DATA_BUF      |   0   |                 ...                   |   66   |  0x19 |  0x01 | DOMAIN_SEPARATOR | SAFE_TX_HASH |
+----------+--------------------+-------+---------------------------------------+--------+-------+-------+------------------+--------------+
^          ^                    ^       ^                                       ^        ^       ^       ^                  ^              ^
|          |                    |       |                                       |                                                          |
DATA_LOC   DATA_LOC + 32        |       DATA_LOC + 32 + ceil32(DATA_LEN)        DATA_LOC + 32 + ceil32(DATA_LEN) + 384                     DATA_LOC + 32 + ceil32(DATA_LEN) + 482
                                |                                               ^
                                DATA_LOC + 32 + DATA_LEN                        |
                                                                                OUTPUT_LOC
```
where `X = ceil32(DATA_LEN) - DATA_LEN`.
Here the function writes to the memory starting from `DATA_LOC + 32 + ceil32(DATA_LEN)`.
The first 384 bytes are used for executing `keccak256` to compute `safeTxHash`, i.e., 352 bytes for preparing for 11 arguments (= 32 * 11), and 32 bytes for holding the return value.
The next 98 bytes are used for passing the return value, as described above.


Note that the external call results in the same output memory, but the memory is not shared by the caller, and does not affect the caller's memory.



#### Function visibility and modifiers:

The function does not update the storage, as it is marked `view`.

For the external call, `msg.value` must be zero, since the function is not `payable`.  Otherwise, it throws.



#### Pre-conditions:

No overflow:
- For the external call, the call depth is small enough to avoid the call depth overflow.
- For the internal call, the input stack size is small enough to avoid the stack overflow.
- The maximum memory location accessed, i.e., `DATA_LOC + 32 + ceil32(DATA_LEN) + 482`, is small enough to avoid the integer overflow for the pointer arithmetic.

It is practically reasonable to assume that the no-overflow conditions are met. If they are not satisfied, the function will throw.


Well-formed input:
- The `to`, `gasToken`, and `refundReceiver` argument values are all within the range of `address`, i.e., the first 96 (= 256 - 160) bits are zero. Otherwise, the function simply ignores (i.e., truncates) the fist 96 bits.
- The `operation` is either 0, 1, or 2.  Otherwise, the `execute` function (defined at `Executor.sol`) will throw.
- The maximum size of `data` is 2^32. Otherwise, it reverts. (The bound is practically reasonable considering the current block gas limit. See the buffer size limit discussion.)

The input well-formedness conditions are satisfied in all calling contexts of the current GnosisSafe contract.


#### Mechanized formal specification:

##### For internal call:

Below is the specification that we verified against the GnosisSafe contract bytecode.

```ini
[encodeTransactionData-internal]
; output = bytes32(32) bytes32(66) bytes1(0x19) bytes1(0x1) bytes32(DOMAIN_SEPARATOR) bytes32(SAFE_TX_HASH) bytes30(0)
; size = 160
k: #execute ~> _
output: _
statusCode: _
callStack: _
this: #PROXY_ID
msg_sender: MSG_SENDER
callData: _
callValue: 0
wordStack: NONCE : REFUND_RECEIVER : GAS_TOKEN : GAS_PRICE : DATA_GAS : SAFE_TX_GAS : OPERATION
                 : DATA_LEN_LOC : VALUE : TO : RETURN_LOC : WS
           => RETURN_LOC : INIT_USED_MEM_PTR +Int 384 : WS
localMem:INIT_MEM =>
  storeRange( storeRange( storeRange( storeRange( storeRange( storeRange( storeRange(
  storeRange( storeRange( storeRange( storeRange( storeRange( storeRange( storeRange(
  storeRange( storeRange( storeRange( storeRange(
  storeRange( INIT_MEM,
    ; internal computations, memory no longer used
    INIT_USED_MEM_PTR +Int 32,  32, _),
    INIT_USED_MEM_PTR +Int 64,  32, _),
    INIT_USED_MEM_PTR +Int 96,  32, _),
    INIT_USED_MEM_PTR +Int 128, 32, _),
    INIT_USED_MEM_PTR +Int 160, 32, _),
    INIT_USED_MEM_PTR +Int 192, 32, _),
    INIT_USED_MEM_PTR +Int 224, 32, _),
    INIT_USED_MEM_PTR +Int 256, 32, _),
    INIT_USED_MEM_PTR +Int 288, 32, _),
    INIT_USED_MEM_PTR +Int 320, 32, _),
    INIT_USED_MEM_PTR +Int 352, 32, _),
    INIT_USED_MEM_PTR,          32, _),
    64,                         32, _),

    ;start of result, divided into 4 parts:
    ;return abi.encodePacked(byte(0x19), byte(0x01), domainSeparator, safeTxHash)
    INIT_USED_MEM_PTR +Int 416, CONST_LEN, HEX_19_WS ),
    INIT_USED_MEM_PTR +Int 417, CONST_LEN, HEX_01_WS ),
    INIT_USED_MEM_PTR +Int 418, 32,        #buf(32, DOMAIN_SEPARATOR) ),
    INIT_USED_MEM_PTR +Int 450, 32,        #buf(32, SAFE_TX_HASH ) ),
    ;output len
    INIT_USED_MEM_PTR +Int 384, 32,        #buf(32, 66) ),
    ;next free memory loc
    64,                         32,        #buf(32, INIT_USED_MEM_PTR +Int 482) )
pc: 16193 => 16786
gas: #gas(INITGAS,
          NONMEMGAS => (NONMEMGAS +Int 6 *Int ((DATA_LEN +Int 31) /Int 32)) +Int 941,
          MEMGAS    =>  MEMGAS +Int (Cmem(BYZANTIUM, END_MEM_USED) -Int Cmem(BYZANTIUM, MU)) )
memoryUsed: MU => END_MEM_USED
log: _
refund: _
coinbase: _
proxy_storage: STORAGE
+requires:
    ; Range
    andBool #rangeAddress(MSG_SENDER)

    andBool #rangeAddress(          TO)
    andBool #rangeUInt( 256,        VALUE)
    andBool #rangeUInt( 256,        DATA_LEN)
    ;andBool #rangeBytes( DATA_LEN,  DATA)
    andBool #rangeUInt(   8,        OPERATION)
    ; enum Enum.Operation, 3 possible values encoded to 0-2.
    andBool OPERATION <=Int 2
    andBool #rangeUInt( 256,        SAFE_TX_GAS)
    andBool #rangeUInt( 256,        DATA_GAS)
    andBool #rangeUInt( 256,        GAS_PRICE)
    andBool #rangeAddress(          GAS_TOKEN)
    andBool #rangeAddress(          REFUND_RECEIVER)
    andBool #rangeUInt( 256,        NONCE)

    andBool #rangeBytes( 32,        DOMAIN_SEPARATOR)

    ; TODO more precise value. 1000 is too little.
    andBool #range(0 <= #sizeWordStack(WS) <= 900)

    andBool DATA_LEN <Int 2 ^Int 16

    andBool SAFE_TX_HASH ==Int keccak( #encodeArgs(
                                 #bytes32(#parseHexWord({SAFE_TX_TYPEHASH})),
                                 #address(TO),
                                 #uint256(VALUE),
                                 #bytes32(keccak(DATA_BUF)),
                                 #uint8(OPERATION),
                                 #uint256(SAFE_TX_GAS),
                                 #uint256(DATA_GAS),
                                 #uint256(GAS_PRICE),
                                 #address(GAS_TOKEN),
                                 #address(REFUND_RECEIVER),
                                 #uint256(NONCE) ))
    andBool INIT_USED_MEM_PTR  ==Int #ceil32(DATA_LEN) +Int DATA_LEN_LOC +Int 32

    ; local memory ranges
    ; on encodeTransactionData-public:
    ; andBool DATA_LEN_LOC ==Int 128
    ; DATA_LEN_LOC is the base memory location for all other locations.
    ; We give a wider range enough to cover all execution paths.
    andBool #range(128 <= DATA_LEN_LOC <= 2 ^Int 16)
    andBool DATA_LEN_LOC modInt 32 ==Int 0
    andBool DATA_BUF_LOC  ==Int DATA_LEN_LOC +Int 32
    ; required to resolve select...store expressions.
    andBool INIT_USED_MEM_ACTUAL ==Int DATA_LEN_LOC +Int 32 +Int DATA_LEN
    andBool END_MEM_USED   ==Int #memoryUsageUpdate(MU, INIT_USED_MEM_PTR +Int 450, 32)

    ; storage
    andBool select(STORAGE, #hashedLocation({COMPILER}, {DOMAIN_SEPARATOR}, .IntList)) ==Int DOMAIN_SEPARATOR

[encodeTransactionData-internal-proof]
+requires:
    andBool CONST_LEN ==Int 32
    andBool HEX_19_WS ==K #padRightToWidth(32, #parseByteStack("0x19"))
    andBool HEX_01_WS ==K #padRightToWidth(32, #parseByteStack("0x01"))
    andBool INIT_MEM  ==K storeRange( storeRange( storeRange( storeRange( _,
                              64,                   32,       #buf(32, INIT_USED_MEM_PTR) ),
                              DATA_LEN_LOC,         32,       #buf(32, DATA_LEN) ),
                              DATA_BUF_LOC,         DATA_LEN, DATA_BUF ),
                              INIT_USED_MEM_ACTUAL, 32,       #buf(32, 0) )
    andBool DATA_BUF  ==K #buf(DATA_LEN, DATA)

[encodeTransactionData-internal-proof-1]
+requires:
    andBool DATA_LEN ==Int 0

[encodeTransactionData-internal-proof-2]
+requires:
    andBool 0 <Int DATA_LEN
```

Below is the specification to be used when verifying other (caller) functions.

```ini
[encodeTransactionData-internal-trusted]
localMem: INIT_MEM =>
  storeRange( storeRange( storeRange( storeRange( storeRange( storeRange(
  storeRange( INIT_MEM,
    ; internal computations, memory no longer used
    INIT_USED_MEM_PTR,          384, _ ),

    ;start of result, divided into 4 parts:
    ;return abi.encodePacked(byte(0x19), byte(0x01), domainSeparator, safeTxHash)
    INIT_USED_MEM_PTR +Int 416, CONST_LEN, HEX_19_WS ),
    INIT_USED_MEM_PTR +Int 417, CONST_LEN, HEX_01_WS ),
    INIT_USED_MEM_PTR +Int 418, 32,        #buf(32, DOMAIN_SEPARATOR) ),
    INIT_USED_MEM_PTR +Int 450, 32,        #buf(32, SAFE_TX_HASH ) ),
    ;output len
    INIT_USED_MEM_PTR +Int 384, 32,        #buf(32, 66) ),
    ;next free memory loc
    64,                         32,        #buf(32, INIT_USED_MEM_PTR +Int 482) )
+requires:
    andBool CONST_LEN         ==Int 1
    andBool HEX_19_WS         ==K   #parseByteStack("0x19")
    andBool HEX_01_WS         ==K   #parseByteStack("0x01")
    andBool INIT_USED_MEM_PTR ==Int #asWord(selectRange(INIT_MEM, 64,                   32))
    andBool DATA_LEN          ==Int #asWord(selectRange(INIT_MEM, DATA_LEN_LOC,         32))
    andBool DATA_BUF          ==K           selectRange(INIT_MEM, DATA_BUF_LOC,         DATA_LEN)
    andBool #buf(32, 0)       ==K           selectRange(INIT_MEM, INIT_USED_MEM_ACTUAL, 32)
+attribute: [trusted, matching(#gas)]
```

##### For external call:

Below is the specification that we verified against the GnosisSafe contract bytecode.

```ini
[encodeTransactionData-public]
; output = bytes32(32) bytes32(66) bytes1(0x19) bytes1(0x1) bytes32(DOMAIN_SEPARATOR) bytes32(SAFE_TX_HASH) bytes30(0)
; size = 160
k: (#execute => #halt) ~> _
output: _ => #encodeArgs( #bytes(
                #parseHexWord("0x19") : #parseHexWord("0x1")
                : #encodeArgs(#bytes32(DOMAIN_SEPARATOR), #bytes32(SAFE_TX_HASH))
             ))
statusCode: _ => EVMC_SUCCESS
callStack: _
this: #PROXY_ID
msg_sender: MSG_SENDER
callData: #abiCallData("encodeTransactionData", (
            #address(TO),
            #uint256(VALUE),
            #bytes(#buf(DATA_LEN, DATA)),
            ; Enum.Operation operation, represented as uint8
            #uint8(OPERATION),
            #uint256(SAFE_TX_GAS),
            #uint256(DATA_GAS),
            #uint256(GAS_PRICE),
            #address(GAS_TOKEN),
            #address(REFUND_RECEIVER),
            #uint256(NONCE) ))
callValue: 0
wordStack: .WordStack => _
localMem: .IMap => _
pc: 0 => _
gas: #gas(INITGAS, 0, 0) => _
memoryUsed: 0 => _
log: _
refund: _
coinbase: _
proxy_storage:
    store(M, #hashedLocation({COMPILER}, {DOMAIN_SEPARATOR}, .IntList), DOMAIN_SEPARATOR)
+requires:
    ; Range
    andBool #rangeAddress(MSG_SENDER)
    andBool #rangeAddress(          TO)
    andBool #rangeUInt( 256,        VALUE)
    andBool #rangeUInt( 256,        DATA_LEN)
    ;andBool #rangeBytes( DATA_LEN,  DATA)
    andBool #rangeUInt(   8,        OPERATION)
    ; enum Enum.Operation, 3 possible values encoded to 0-2.
    andBool OPERATION <=Int 2
    andBool #rangeUInt( 256,        SAFE_TX_GAS)
    andBool #rangeUInt( 256,        DATA_GAS)
    andBool #rangeUInt( 256,        GAS_PRICE)
    andBool #rangeAddress(          GAS_TOKEN)
    andBool #rangeAddress(          REFUND_RECEIVER)
    andBool #rangeUInt( 256,        NONCE)

    andBool #rangeBytes( 32,        DOMAIN_SEPARATOR)
    andBool #range(0 <= CD < 1024)

    andBool DATA_LEN <Int 2 ^Int 16

    andBool SAFE_TX_HASH ==Int keccak( #encodeArgs(
                                 #bytes32(#parseHexWord({SAFE_TX_TYPEHASH})),
                                 #address(TO),
                                 #uint256(VALUE),
                                 #bytes32(keccak(#buf(DATA_LEN, DATA))),
                                 #uint8(OPERATION),
                                 #uint256(SAFE_TX_GAS),
                                 #uint256(DATA_GAS),
                                 #uint256(GAS_PRICE),
                                 #address(GAS_TOKEN),
                                 #address(REFUND_RECEIVER),
                                 #uint256(NONCE) ))

[encodeTransactionData-public-1]
+requires:
    andBool DATA_LEN ==Int 0

[encodeTransactionData-public-2]
+requires:
    andBool 0 <Int DATA_LEN
```

### Function getTransactionHash

[`getTransactionHash`] is a simple wrapper of `encodeTransactionData` that returns the `keccak256` hash of the `encodeTransactionData` output.

```
    function getTransactionHash(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 dataGas,
        uint256 gasPrice,
        address gasToken,
        address refundReceiver,
        uint256 _nonce
    )
        public
        view
        returns (bytes32)
```

```ini
[getTransactionHash]
k: (#execute => #halt) ~> _
output: _ => #padToWidth(32, #asByteStack(keccak(TRANSACTION_DATA)) )
statusCode: _ => EVMC_SUCCESS
callStack: _
this: #PROXY_ID
msg_sender: MSG_SENDER
callData: #abiCallData("getTransactionHash", (
            #address(TO),
            #uint256(VALUE),
            #bytes(#buf(DATA_LEN, DATA)),
            #uint8(OPERATION),
            #uint256(SAFE_TX_GAS),
            #uint256(DATA_GAS),
            #uint256(GAS_PRICE),
            #address(GAS_TOKEN),
            #address(REFUND_RECEIVER),
            #uint256(NONCE) ))
callValue: 0
wordStack: .WordStack => _
localMem: .IMap => _
pc: 0 => _
gas: #gas(INITGAS, 0, 0) => _
memoryUsed: 0 => _
log: _
refund: _
coinbase: _
proxy_storage:
    store(M, #hashedLocation({COMPILER}, {DOMAIN_SEPARATOR}, .IntList), DOMAIN_SEPARATOR)
+requires:
    ; Range
    andBool #rangeAddress(MSG_SENDER)

    andBool #rangeAddress(          TO)
    andBool #rangeUInt( 256,        VALUE)
    andBool #rangeUInt( 256,        DATA_LEN)
    andBool #rangeUInt(   8,        OPERATION)
    andBool OPERATION <=Int 2
    andBool #rangeUInt( 256,        SAFE_TX_GAS)
    andBool #rangeUInt( 256,        DATA_GAS)
    andBool #rangeUInt( 256,        GAS_PRICE)
    andBool #rangeAddress(          GAS_TOKEN)
    andBool #rangeAddress(          REFUND_RECEIVER)
    andBool #rangeUInt( 256,        NONCE)

    andBool #rangeBytes( 32,        DOMAIN_SEPARATOR)

    andBool DATA_LEN <Int 2 ^Int 16

    ; computed data
    andBool SAFE_TX_HASH ==Int keccak( #encodeArgs(
                                 #bytes32(#parseHexWord({SAFE_TX_TYPEHASH})),
                                 #address(TO),
                                 #uint256(VALUE),
                                 #bytes32(keccak(#buf(DATA_LEN, DATA))),
                                 #uint8(OPERATION),
                                 #uint256(SAFE_TX_GAS),
                                 #uint256(DATA_GAS),
                                 #uint256(GAS_PRICE),
                                 #address(GAS_TOKEN),
                                 #address(REFUND_RECEIVER),
                                 #uint256(NONCE) ))
    andBool TRANSACTION_DATA ==K
                #parseHexWord("0x19") : #parseHexWord("0x1")
              : #encodeArgs(#bytes32(DOMAIN_SEPARATOR), #bytes32(SAFE_TX_HASH))

[getTransactionHash-1]
+requires:
    andBool DATA_LEN ==Int 0

[getTransactionHash-2]
+requires:
    andBool 0 <Int DATA_LEN
```

### Function handlePayment

[`handlePayment`] is a private function that pays the gas cost to the receiver in either Ether or tokens.

```
    function handlePayment(
        uint256 startGas,
        uint256 dataGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver
    )
        private
```

Here we consider only the case of payment in Ether. The token payment is out of the scope of the current engagement.

#### Stack and memory:

All of the input arguments are passed through the stack, and no memory is required since they are all fixed-size:
```
REFUND_RECEIVER : GAS_TOKEN : GAS_PRICE : DATA_GAS : START_GAS : RETURN_LOC : WS
```

The function has no return value, and thus the output stack, if succeeds, is as follows:
```
RETURN_LOC : WS
```

#### State update:

The payment amount is calculated by the following formula:
```
((START_GAS - GAS_LEFT) + DATA_GAS) * GAS_PRICE
```
where `GAS_LEFT` is the result of `gasleft()` at [line 115].

If an arithmetic overflow occurs when evaluating the above formula, the function reverts.


If no overflow occurs, `receiver` is set to `tx.origin` if `refundReceiver` is zero, otherwise it is set to `refundReceiver`. Thus `receiver` is non-zero.

Finally, the amount of Ether is sent to `receiver`.
If `send` succeeds, then the function returns (with no return value). Otherwise it reverts.


Here, we have little concern about the reentrancy for `send`, since there is no critical statement after `send`, and also the function is private.


#### Function visibility and modifiers:

The function cannot be directly called from outside, as it is `private`.
An external call to this function will silently terminate with no effect (and no exception).


#### Pre-conditions:

No overflow:
- The input stack size is small enough to avoid the stack overflow.

It is practically reasonable to assume that the no-overflow conditions are met. If they are not satisfied, the function will throw.

Well-formed input:
- The value of the address arguments are within the range of `address`, i.e., the first 96 (= 256 - 160) bits are zero. Otherwise, the function simply ignores (i.e., truncates) the fist 96 bits.

The input well-formedness conditions are satisfied in all calling contexts of the current GnosisSafe contract.


#### Mechanized formal specification:

Below is the specification that we verified against the GnosisSafe contract bytecode.

```ini
[handlePayment]
callStack: _
this: #PROXY_ID
msg_sender: MSG_SENDER
callData: _
callValue: 0
localMem: _
log: _
refund: _
coinbase: _
+requires:
    andBool #rangeUInt(256, START_GAS)
    andBool #rangeUInt(256, DATA_GAS)
    andBool #rangeUInt(256, GAS_PRICE)
    andBool #rangeAddress(GAS_TOKEN)

    andBool #range(0 <= #sizeWordStack(WS) <= 1000)
    // call send() in the handlePayment
    andBool #range(0 <= CD < 1023)

    andBool GAS_LEFT ==Int #gas(INITGAS, NONMEMGAS +Int 21, MEMGAS)
    andBool TOTAL_GAS ==Int (START_GAS -Int GAS_LEFT) +Int DATA_GAS
    andBool TOTAL_AMOUNT ==Int TOTAL_GAS *Int GAS_PRICE

    // The function is only used in execTransction and START_GAS > gasleft()
    andBool GAS_LEFT <Int START_GAS
    // The function is only used in execTransction and GAS_PRICE > 0
    andBool 0 <Int GAS_PRICE
    // only consider ether payment
    andBool GAS_TOKEN ==Int 0

[handlePayment-arithmetic-overflow]
k: (#execute => #halt) ~> _
output: _ => .WordStack
statusCode: _ => EVMC_REVERT
wordStack: REFUND_RECEIVER : GAS_TOKEN : GAS_PRICE : DATA_GAS : START_GAS : RETURN_LOC : WS => _
memoryUsed: MU

[handlePayment-arithmetic-overflow-1]
pc: 19729 => 22332
gas: #gas(INITGAS, NONMEMGAS, MEMGAS) => #gas(INITGAS, NONMEMGAS +Int 216, MEMGAS)
+requires:
    andBool pow256 <=Int TOTAL_GAS

[handlePayment-arithmetic-overflow-2]
pc: 19729 => 22393
gas: #gas(INITGAS, NONMEMGAS, MEMGAS) => #gas(INITGAS, NONMEMGAS +Int 380, MEMGAS)
+requires:
    andBool TOTAL_GAS <Int pow256
    andBool pow256 <=Int TOTAL_AMOUNT

[handlePayment-send]
memoryUsed: MU => FINAL_MEM_USAGE
+requires:
    andBool CALL_PC ==Int 19952
    // (START_GAS - gasleft()) + DATA_GAS < pow256
    andBool TOTAL_GAS <Int pow256
    andBool TOTAL_AMOUNT <Int pow256

[handlePayment-send-success]
k: (#execute => #execute) ~> _
output: _ => _
statusCode: _
wordStack: REFUND_RECEIVER : GAS_TOKEN : GAS_PRICE : DATA_GAS : START_GAS : RETURN_LOC : WS => RETURN_LOC : WS
pc: 19729 => 20290
+requires:
    andBool FINAL_MEM_USAGE ==K #memoryUsageUpdate(MU, 64, 32)

;TODO: 1) ORIGIN_ID == #EXEC_ACCT_TO
;      2) ORIGIN_ID == #REFUND_RECEIVER
;      3) ORIGIN_ID == #EXEC_TO
[handlePayment-send-success-origin]
gas: #gas(INITGAS, NONMEMGAS, MEMGAS) => #gas(INITGAS, NONMEMGAS +Int #callGas(BYZANTIUM, 0, #ORIGIN_ID, TOTAL_AMOUNT, true) +Int 618, MEMGAS +Int (Cmem(BYZANTIUM, FINAL_MEM_USAGE) -Int Cmem(BYZANTIUM, MU)))
proxy_bal: PROXY_BAL => PROXY_BAL -Int TOTAL_AMOUNT
origin_bal: ORIGIN_BAL => ORIGIN_BAL +Int TOTAL_AMOUNT
+requires:
    andBool REFUND_RECEIVER ==Int 0
    andBool ORIGIN_ID ==Int #ORIGIN_ID
    andBool #callSuccess(CALL_PC, #ORIGIN_ID)
    andBool TOTAL_AMOUNT <=Int PROXY_BAL
    andBool ORIGIN_BAL +Int TOTAL_AMOUNT <Int pow256

[handlePayment-send-success-origin-trusted]
+attribute: [trusted, matching(#gas)]

;TODO: 1) REFUND_RECEIVER == #PROXY_ID
;      2) REFUND_RECEIVER == #MASTER_COPY_ID
;      3) REFUND_RECEIVER == #ORIGIN_ID
;      4) REFUND_RECEIVER == #EXEC_TO
[handlePayment-send-success-receiver]
gas: #gas(INITGAS, NONMEMGAS, MEMGAS) => #gas(INITGAS, NONMEMGAS +Int #callGas(BYZANTIUM, 0, #REFUND_RECEIVER, TOTAL_AMOUNT, true) +Int 629, MEMGAS +Int (Cmem(BYZANTIUM, FINAL_MEM_USAGE) -Int Cmem(BYZANTIUM, MU)))
proxy_bal: PROXY_BAL => PROXY_BAL -Int TOTAL_AMOUNT
receiver_bal: RECEIVER_BAL => RECEIVER_BAL +Int TOTAL_AMOUNT
+requires:
    andBool REFUND_RECEIVER ==Int #REFUND_RECEIVER

    andBool #callSuccess(CALL_PC, #REFUND_RECEIVER)
    andBool TOTAL_AMOUNT <=Int PROXY_BAL
    andBool RECEIVER_BAL +Int TOTAL_AMOUNT <Int pow256

[handlePayment-send-failure]
k: (#execute => #halt) ~> _
output: _ => _
statusCode: _ => EVMC_REVERT
wordStack: REFUND_RECEIVER : GAS_TOKEN : GAS_PRICE : DATA_GAS : START_GAS : RETURN_LOC : WS => _
localMem: storeRange(M, 64, 32, #buf(32, NEXT_LOC)) => _
pc: 19729 => 20110
+requires:
    andBool #rangeUInt(256, NEXT_LOC)
    // Practical bound to help memory reasoning
    andBool #range(96 <= NEXT_LOC < 2 ^Int 32)

    andBool FINAL_MEM_USAGE ==K #memoryUsageUpdate(MU, NEXT_LOC +Int 100, 32)

[handlePayment-send-failure-origin]
gas: #gas(INITGAS, NONMEMGAS, MEMGAS) => #gas(INITGAS, NONMEMGAS +Int #callGas(BYZANTIUM, 0, #ORIGIN_ID, TOTAL_AMOUNT, false) +Int 714, MEMGAS +Int (Cmem(BYZANTIUM, FINAL_MEM_USAGE) -Int Cmem(BYZANTIUM, MU)))
+requires:
    andBool REFUND_RECEIVER ==Int 0
    andBool ORIGIN_ID ==Int #ORIGIN_ID
    andBool #callFailure(CALL_PC, #ORIGIN_ID)

[handlePayment-send-failure-receiver]
gas: #gas(INITGAS, NONMEMGAS, MEMGAS) => #gas(INITGAS, NONMEMGAS +Int #callGas(BYZANTIUM, 0, #REFUND_RECEIVER, TOTAL_AMOUNT, false) +Int 725, MEMGAS +Int (Cmem(BYZANTIUM, FINAL_MEM_USAGE) -Int Cmem(BYZANTIUM, MU)))
+requires:
    andBool REFUND_RECEIVER ==Int #REFUND_RECEIVER
    andBool #callFailure(CALL_PC, #REFUND_RECEIVER)
```

Below is the specification to be used when verifying other (caller) functions.

```ini
; Simplified handlePayment
[handlePayment_trusted]
k: (#execute => #handlePaymentSpecApplied) ~> _
output: _
statusCode: _
callStack: _
this: #PROXY_ID
msg_sender: MSG_SENDER
callData: _
callValue: 0
wordStack: REFUND_RECEIVER : GAS_TOKEN : GAS_PRICE : DATA_GAS : START_GAS : RETURN_LOC : WS
localMem: _
pc: 19729
gas: _
memoryUsed: _
log: _
refund: _
coinbase: _
+requires:
    andBool #rangeAddress(MSG_SENDER)
    andBool #rangeUInt(256, START_GAS)
    andBool #rangeUInt(256, DATA_GAS)
    andBool #rangeUInt(256, GAS_PRICE)
    andBool #rangeAddress(GAS_TOKEN)
    andBool #rangeAddress(REFUND_RECEIVER)

    andBool #range(0 <= #sizeWordStack(WS) <= 1000)
    // call send() in the handlePayment
    andBool #range(0 <= CD < 1023)
    ; GAS_LEFT <Int START_GAS is always satisfied in the context of execTransction
    ;andBool GAS_LEFT <Int START_GAS
    andBool 0 <Int GAS_PRICE
+attribute: [trusted]
```

### Function checkSignatures

[`checkSignatures`] is an internal function that checks the validity of the given signatures.

```
    function checkSignatures(bytes32 dataHash, bytes memory data, bytes memory signatures, bool consumeHash)
        internal
        returns (bool)
```

#### Stack and memory:

The input arguments are passed through the stack as follows:
```
CONSUME_HASH : SIGS_LOC : DATA_LOC : DATA_HASH : RETURN_LOC : WS
```

where `data` and `signatures` are stored in the memory:
```
|<-  32  ->|<-    DATA_LEN    ->|         |<-  32  ->|<-    DATA_LEN    ->|
+----------+--------------------+         +----------+--------------------+
| DATA_LEN |      DATA_BUF      |   ...   | SIGS_LEN |      SIGS_BUF      |
+----------+--------------------+         +----------+--------------------+
^          ^                    ^         ^          ^                    ^
|          |                    |         |          |                    |
DATA_LOC   DATA_LOC + 32        |         SIGS_LOC   SIGS_LOC + 32        SIGS_LOC + 32 + SIGS_LEN
                                |
                                DATA_LOC + 32 + DATA_LEN
```


The function returns true if:
- the number of signatures is more than equal to `threshold`, and
- the first `threshold` number of signatures are valid, signed by owners, and sorted by their owner address.

where a signature is valid if:
- case v = 0: `r`'s isValidSignature returns true.
- case v = 1: `r` == msg.sender or `dataHash` is already approved.
- otherwise:  it is a valid ECDSA signature.


Otherwise, the function returns false, unless `isValidSignature` throws (or reverts).

If `isValidSignature` throws or reverts, `checkSignatures` reverts, immediately terminating without returning to `execTransaction`.


Also, if `consumeHash = true`, the function may update `approvedHashes[currentOwner][dataHash]` to zero.


#### Function visibility and modifiers:

The function cannot be directly called from outside, as it is `internal`.
An external call to this function will silently terminate with no effect (and no exception).



#### Pre-conditions:

No overflow:
- The input stack size is small enough to avoid the stack overflow.
- The maximum memory location accessed is small enough to avoid the integer overflow for the pointer arithmetic.

It is practically reasonable to assume that the no-overflow conditions are met. If they are not satisfied, the function will throw.

No wrap-around:
- `threshold` is small enough to avoid overflow (wrap-around).

The no-wrap-around condition is implied by the OwnerManager contract invariant.
If it is not satisfied, the function may have unexpected behaviors.

Well-formed input:
- Every owner (i.e., some `o` such that `owners[o] =/= 0`) is within the range of `address`. Otherwise, the function simply truncates the higher bits when validating the signatures.
- The maximum size of `data` is 2^32. Otherwise, it reverts. (The bound is practically reasonable considering the current block gas limit. See the buffer size limit discussion.)
- No overlap between two memory chunks of `data` and `signatures`, i.e., `DATA_LOC + 32 + DATA_LEN <= SIGS_LOC`. Otherwise, the function becomes nondeterministic.
- Every signature encoding is well-formed. Otherwise, the function becomes nondeterministic.

The first three conditions are satisfied in all calling contexts of the current GnosisSafe contract.
In particular, the first condition is part of the contract invariant.

However, the last condition should be satisfied by the client when he calls `execTransaction`, since the current contract omits the well-formedness check of the signature encoding.

Non-interfering external contract call:
- The external contract call does not change the current (i.e., the proxy) storage.

The non-interfering external contract call assumption is an under-approximation of all possible behaviors, and thus may lead to missing some behaviors, but it enables the modular reasoning of the function.

NOTE:
A conservative abstraction (i.e., an over-approximation) is possible by assuming that the external contract call may update all deployed accounts (i.e., their balance, storage, nonce, and even code!) and create some new accounts, but never delete an existing account (since the SELFDESTRUCT opcode effect is applied only after the current transaction finishes).
However, such an abstraction is too crude and does not necessarily lead to a better reasoning either.



#### Mechanized formal specification:


We formalize the validity of (arbitrary number of) signatures in a way that we can avoid explicit quantifier reasoning during the mechanized formal verification, as follows.


We first define `the-first-invalid-signature-index` as follows:
(The mechanized definition is [here][fii].)
- A1:  For all `i < the-first-invalid-signature-index`,  `signatures[i]` is valid.
- A2:  `signatures[the-first-invalid-signature-index]` is NOT valid.

Now we can formulate the behavior of `checkSignatures` using the above definition (with no quantifiers!) as follows:
- T1:  `checkSignatures` returns true if `the-first-invalid-signature-index >= threshold`.
- T2:  Otherwise, returns false.

To prove the above top-level specifications, T1 and T2, we need the following loop invariant:

For some `i` such that `0 <= i < threshold` and `i <= the-first-invalid-signature-index`:
- L1:  If `i < threshold <= the-first-invalid-signature-index`, then the function returns true once the loop terminates.
- L1:  Else (i.e., if `i <= the-first-invalid-signature-index < threshold`), then the function eventually returns false.

To prove the above loop invariant, L1 and L2, we need the following claims for a single loop iteration:
- M1:  If `signatures[i]` is valid, it continues to the next iteration (i.e., goes back to the loop head).
- M2:  If `signatures[i]` is NOT valid, it returns false.


##### Proof sketch:

The top level specification:
- T1:  By L1 with `i = 0`.
- T2:  By L2 with `i = 0`.

The loop invariant:
- L1:
  By A1, `signatures[i]` is valid.
  Then by M1, it goes back to the loop head, and we have two cases:
  - Case 1: `i + 1 = threshold`: It jumps out of the loop, and return true.
  - Case 2: `i + 1 < threshold`: By the circular reasoning with L1.
- L2:
  - Case 1: `i = the-first-invalid-signature-index`:
    By A2, `signatures[i]` is NOT valid.  Then, by M2, we conclude.
  - Case 2: `i < the-first-invalid-signature-index`:
    By A1, `signatures[i]` is valid. Then, by M1, it goes to the loop head, and by the circular reasoning with L2, we conclude (since we know that `i + 1 <= the-first-invalid-signature-index < threshold`).

The single loop iteration claim does not involve the recursive structure, and thus can be verified in the similar way as other specifications.



Below is the specification that we verified against the GnosisSafe contract bytecode.

```ini
; internal
[checkSignatures]
k: #execute ~> _
output: _ => _
statusCode: _ => _
callStack: _
this: #PROXY_ID
msg_sender: MSG_SENDER
callData: _
callValue: 0
memoryUsed: MU => FINAL_MEM_USAGE
gas: #gas(INITGAS, NONMEMGAS, MEMGAS) => _
log: _
refund: _
coinbase: _
proxy_storage:
   S:IMap
pc: {PC_FUN_START} => {PC_FUN_END}
wordStack:
    ; parameters
    {CONSUME_HASH} : SIGS_LOC : TX_DATA_LOC : TX_DATA_HASH :
    ; return address
    RETURN_LOC : WS
    =>
    {WORD_STACK_RHS}
localMem:
    storeRange(storeRange(storeRange(storeRange(storeRange(M,
      TX_DATA_LOC        , 32         , #buf(32, TX_DATA_LEN)),
      TX_DATA_LOC +Int 32, TX_DATA_LEN, #buf(TX_DATA_LEN, TX_DATA)),
      SIGS_LOC           , 32         , #buf(32, SIGS_LEN)),
      SIGS_LOC +Int 32   , SIGS_LEN   , #buf(SIGS_LEN, SIGS)),
      64                 , 32         , #buf(32, NEXT_LOC))
    =>
    {MEM_RHS}
MEM_RHS: M2
+requires:
    ; elements
    andBool THRESHOLD ==Int select(S, #hashedLocation({COMPILER}, {THRESHOLD}, .IntList))

    ; no overflow
    andBool #rangeUInt(256, THRESHOLD *Int 65)

    ; <wordStack> when calling signatureSplit:
    ; I : SIGS_LOC : RETURN_LOC : I : S0 : ... : RETURN_LOC : WS
    ;                             ^^^^^^^^^^^^^^^^^^^^^^^^^ 12 elems
    ; NOTE: need to consider the peak size of stack during the execution
    andBool #range(0 <= #sizeWordStack(WS) <= 1000 -Int 12)

    andBool #range(SIGS_LOC +Int 32 +Int #ceil32(SIGS_LEN) <= NEXT_LOC < 2 ^Int 32)

    ; ranges
    andBool #range(0 <= CD < 1023)
    ; bool consumeHash
    andBool #range(0 <= {CONSUME_HASH} <= 1)
    ; bytes memory signatures
    andBool #rangeUInt(256, SIGS_LOC)
    ; bytes memory data
    andBool #rangeUInt(256, TX_DATA_LOC)
    ; bytes32 dataHash
    andBool #rangeUInt(256, TX_DATA_HASH)
    ; andBool #range(0 <= #sizeWordStack(WS) <= 990)
    andBool #rangeUInt(256, THRESHOLD)
    andBool #rangeUInt(256, TX_DATA_LEN)
    andBool #rangeUInt(256, SIGS_LEN)
    andBool #rangeUInt(256, NEXT_LOC)
    andBool #rangeAddress(MSG_SENDER)

    ; practical bounds for localMem address
    andBool #range(96 <= SIGS_LOC    < 2 ^Int 32)
    andBool #range(96 <= TX_DATA_LOC < 2 ^Int 32)
    andBool #range(96 <= NEXT_LOC    < 2 ^Int 32)
    ; rough bounds for lengths related to localMem address
    andBool TX_DATA_LEN <Int 2 ^Int 16
    andBool SIGS_LEN    <Int 2 ^Int 16
    andBool THRESHOLD   <Int 2 ^Int 32

    ; no overlap between data and sigatures
    andBool TX_DATA_LOC +Int 32 +Int TX_DATA_LEN <=Int SIGS_LOC

    ; accounts
    andBool #PROXY_ID =/=Int 1

    ; contract invariants
    andBool 1 <=Int THRESHOLD

    ; assumption
    andBool #rangeAddress(select(S, #hashedLocation({COMPILER}, {OWNERS}, #signer({SIGS_BUF}, 0, TX_DATA_HASH))))
    andBool #rangeAddress(#signer({SIGS_BUF}, 0, TX_DATA_HASH))

+ensures:
    andBool selectRange(M2, TX_DATA_LOC        , 32      ) ==K #buf(32, TX_DATA_LEN)
    andBool selectRange(M2, TX_DATA_LOC +Int 32, TX_DATA_LEN) ==K #buf(TX_DATA_LEN, TX_DATA)
    andBool selectRange(M2, SIGS_LOC        , 32      ) ==K #buf(32, SIGS_LEN)
    andBool selectRange(M2, SIGS_LOC +Int 32, SIGS_LEN) ==K #buf(SIGS_LEN, SIGS)
    andBool #asWord(selectRange(M2, 64, 32)) >=Int NEXT_LOC

CONSUME_HASH: 1

PC_FUN_START: 18250
PC_LOOP_HEAD: 18292
PC_FUN_END:   19453

SIGS_BUF: #buf(SIGS_LEN, SIGS)
DATA_BUF: #buf(TX_DATA_LEN, TX_DATA)


[checkSignatures-success]
+requires:
    ; enough signatures
    andBool SIGS_LEN >=Int THRESHOLD *Int 65
    ; valid signatures
    andBool #fii({SIGS_BUF}, TX_DATA_HASH, {DATA_BUF}, S, MSG_SENDER) >=Int THRESHOLD
WORD_STACK_RHS: RETURN_LOC : 1 : WS

[checkSignatures-failure]
WORD_STACK_RHS: RETURN_LOC : 0 : WS

[checkSignatures-failure-1]
+requires:
    ; not enough signatures
    andBool SIGS_LEN <Int THRESHOLD *Int 65

[checkSignatures-failure-2]
+requires:
    ; enough signatures
    andBool SIGS_LEN >=Int THRESHOLD *Int 65
    ; invalid signatures
    andBool #fii({SIGS_BUF}, TX_DATA_HASH, {DATA_BUF}, S, MSG_SENDER) <Int THRESHOLD


[checkSignatures-loop]
pc: {PC_LOOP_HEAD} => {PC_FUN_END}
memoryUsed: MU => MEM_USAGE_LOOP
gas: #gas(INITGAS, NONMEMGAS, MEMGAS) => _
wordStack:
    ; local variables
    I : S0 : R0 : V0 : CURRENT_OWNER0 : LAST_OWNER :
    ; return values
    RET :
    ; parameters
    {CONSUME_HASH} : SIGS_LOC : TX_DATA_LOC : TX_DATA_HASH :
    ; return address
    RETURN_LOC : WS
    =>
    {WORD_STACK_RHS}
+requires:
    ; <wordStack> when calling signatureSplit:
    ; I : SIGS_LOC : RETURN_LOC : I : S0 : ... : RETURN_LOC : WS
    ;                             ^^^^^^^^^^^^^^^^^^^^^^^^^ 12 elems
    andBool #range(0 <= #sizeWordStack(WS) <= 1000 -Int 12)

    ; signatures.length >= threshold * 65
    andBool SIGS_LEN >=Int THRESHOLD *Int 65

    andBool #rangeAddress({INIT_CURRENT_OWNER})
    andBool #rangeAddress({CURRENT_OWNER})
    andBool #rangeAddress(LAST_OWNER)
    andBool SIGS_LOC +Int (65 *Int I +Int 65) +Int 32 <Int pow256
    ; invariant
    andBool #range(0 <= I < THRESHOLD)
    andBool I <=Int #fii({SIGS_BUF}, TX_DATA_HASH, {DATA_BUF}, S, MSG_SENDER)
    andBool LAST_OWNER ==Int #signer({SIGS_BUF}, I -Int 1, TX_DATA_HASH)
INIT_CURRENT_OWNER: select(S, #hashedLocation({COMPILER}, {OWNERS}, {CURRENT_OWNER}))
CURRENT_OWNER:      #signer({SIGS_BUF}, I, TX_DATA_HASH)
attribute: [matching(#gas,storeRange,#buf)]

[checkSignatures-loop-trusted]
gas: #gas(INITGAS, NONMEMGAS, MEMGAS) => #gas(INITGAS, NONMEMGAS +Int NONMEMGAS_USAGE_LOOP, MEMGAS +Int (Cmem(BYZANTIUM, MEM_USAGE_LOOP) -Int Cmem(BYZANTIUM, MU)))
attribute: [trusted, matching(#gas,storeRange,#buf)]

[checkSignatures-loop-success]
+requires:
    andBool #fii({SIGS_BUF}, TX_DATA_HASH, {DATA_BUF}, S, MSG_SENDER) >=Int THRESHOLD
WORD_STACK_RHS: RETURN_LOC : 1 : WS

[checkSignatures-loop-success-trusted]
attribute: [trusted, matching(#gas,storeRange,#buf)]

[checkSignatures-loop-failure]
+requires:
    andBool #fii({SIGS_BUF}, TX_DATA_HASH, {DATA_BUF}, S, MSG_SENDER) <Int THRESHOLD
WORD_STACK_RHS: RETURN_LOC : 0 : WS

[checkSignatures-loop-failure-trusted]
attribute: [trusted, matching(#gas,storeRange,#buf)]

[checkSignatures-loop-failure-now]
+requires:
    andBool I ==Int #fii({SIGS_BUF}, TX_DATA_HASH, {DATA_BUF}, S, MSG_SENDER)
attribute: [matching(#gas,storeRange,#buf)]

[checkSignatures-loop-failure-later]
+requires:
    andBool I <Int #fii({SIGS_BUF}, TX_DATA_HASH, {DATA_BUF}, S, MSG_SENDER)
attribute: [matching(#gas,storeRange,#buf)]


; check i < threshold, run the body, i++, return to the loop header
[checkSignatures-loop-body-success]
pc: {PC_LOOP_HEAD}
memoryUsed: MU => MEM_USAGE_SINGLE_LOOP
gas: #gas(INITGAS, NONMEMGAS, MEMGAS) => _
wordStack: (I => I +Int 1) : (S0 => S1) : (R0 => R1) : (V0 => V1) : (CURRENT_OWNER0 => {CURRENT_OWNER}) : (LAST_OWNER => {CURRENT_OWNER})
           : RET : {CONSUME_HASH} : SIGS_LOC : TX_DATA_LOC : TX_DATA_HASH : RETURN_LOC : WS
+requires:
    ; path-condition
    andBool #isValid({SIGS_BUF}, I, TX_DATA_HASH, {DATA_BUF}, S, MSG_SENDER, {EVAL})
EVAL: true
+ensures:
    andBool selectRange(M2, TX_DATA_LOC        , 32      ) ==K #buf(32, TX_DATA_LEN)
    andBool selectRange(M2, TX_DATA_LOC +Int 32, TX_DATA_LEN) ==K #buf(TX_DATA_LEN, TX_DATA)
    andBool selectRange(M2, SIGS_LOC        , 32      ) ==K #buf(32, SIGS_LEN)
    andBool selectRange(M2, SIGS_LOC +Int 32, SIGS_LEN) ==K #buf(SIGS_LEN, SIGS)
  //andBool selectRange(M2, 64              , 32      ) ==K #buf(32, NEXT_LOC)
  //andBool #asWord(selectRange(M2, 64, 32)) ==Int NEXT_LOC +Int 32
    andBool #asWord(selectRange(M2, 64, 32)) >=Int NEXT_LOC


[checkSignatures-loop-body-success-trusted]
pc: {PC_LOOP_HEAD} +Int 1 => {PC_LOOP_HEAD}
gas: #gas(INITGAS, NONMEMGAS, MEMGAS) => #gas(INITGAS, NONMEMGAS +Int NONMEMGAS_USAGE_SINGLE_LOOP, MEMGAS +Int (Cmem(BYZANTIUM, MEM_USAGE_SINGLE_LOOP) -Int Cmem(BYZANTIUM, MU)))
MEM_RHS:
    storeRange(storeRange(storeRange(storeRange(storeRange(_,
      TX_DATA_LOC        , 32         , #buf(32, TX_DATA_LEN)),
      TX_DATA_LOC +Int 32, TX_DATA_LEN, #buf(TX_DATA_LEN, TX_DATA)),
      SIGS_LOC           , 32         , #buf(32, SIGS_LEN)),
      SIGS_LOC +Int 32   , SIGS_LEN   , #buf(SIGS_LEN, SIGS)),
      64                 , 32         , #buf(32, NEW_NEXT_LOC))
ensures:
    andBool NEW_NEXT_LOC >=Int NEXT_LOC
    ; assumption
    andBool #rangeAddress(select(S, #hashedLocation({COMPILER}, {OWNERS}, #signer({SIGS_BUF}, I +Int 1, TX_DATA_HASH))))
    andBool #rangeAddress(#signer({SIGS_BUF}, I +Int 1, TX_DATA_HASH))
    andBool SIGS_LOC +Int (65 *Int (I +Int 1) +Int 65) +Int 32 <Int pow256
    andBool #range(SIGS_LOC +Int 32 +Int #ceil32(SIGS_LEN) <= NEW_NEXT_LOC < 2 ^Int 32)
EVAL: false
k: ( .K => split ( I +Int 1 <Int THRESHOLD ) ) ~> #execute ~> _
attribute: [trusted, matching(#gas,storeRange,#buf)]


[checkSignatures-loop-body-success-v0]
+requires:
    ; v == 0
    andBool #sigV({SIGS_BUF}, I) ==Int 0
    andBool #rangeUInt(256, #sigS({SIGS_BUF}, I))
    andBool #rangeUInt(256, SIGS_LOC +Int #sigS({SIGS_BUF}, I))
    ; TODO: what if SIGS_LOC +Int S_I +Int 32 overflows? It will read content before the content of signature.
    andBool #rangeUInt(256, {DYNAMIC_START})
    ; read CONTRACT_SIG_LEN
    andBool SIGS_LOC +Int 32 <=Int {DYNAMIC_START}
    andBool {DYNAMIC_START} +Int 32 <=Int SIGS_LOC +Int 32 +Int SIGS_LEN
    ; read CONTRACT_SIG
    andBool SIGS_LOC +Int 32 <=Int {DYNAMIC_START} +Int 32
    andBool {DYNAMIC_START} +Int 32 +Int {CONTRACT_SIG_LEN} <=Int SIGS_LOC +Int 32 +Int SIGS_LEN
    ; read 64
    andBool 96 <Int NEXT_LOC +Int #ceil32(TX_DATA_LEN) +Int 132 +Int {CONTRACT_SIG_LEN}
    ; read TX_DATA_LEN
    andBool TX_DATA_LOC +Int 32                  <Int {TRAILING_ZERO_START}
    ; read TX_DATA
    andBool TX_DATA_LOC +Int 32 +Int TX_DATA_LEN <Int {TRAILING_ZERO_START}
    ; read SIGS_LEN
    andBool SIGS_LOC +Int 32                     <Int {TRAILING_ZERO_START}
    ; read SIGS
    andBool SIGS_LOC +Int 32 +Int SIGS_LEN       <Int {TRAILING_ZERO_START}
    andBool 0 <Int #extCodeSize({CURRENT_OWNER})
    andBool #callSuccess(18677, {CURRENT_OWNER})
    andBool #callResult(18677, {CURRENT_OWNER}) ==K 1
dynamic_start: SIGS_LOC +Int #sigS({SIGS_BUF}, I) +Int 32
contract_sig_len: #asWord(#bufSeg({SIGS_BUF}, #sigS({SIGS_BUF}, I), 32))
trailing_zero_start: NEXT_LOC +Int #ceil32(TX_DATA_LEN) +Int 132 +Int {CONTRACT_SIG_LEN}

[copy-trusted]
k: #execute ~> _
output: _
statusCode: _
callStack: _
this: #PROXY_ID
msg_sender: _
callData: _
callValue: 0
wordStack: INDEX : SOURCE_START : DEST_START : SOURCE_LEN : SOURCE_LEN : SOURCE_START : DEST_START : WS => GARBAGE_VALUE : DEST_END : WS
localMem: INIT_MEM => storeRange(storeRange(INIT_MEM,
                          DEST_START                , SOURCE_LEN                         , SOURCE_BUF),
                          DEST_START +Int SOURCE_LEN, #ceil32(SOURCE_LEN) -Int SOURCE_LEN, #buf(#ceil32(SOURCE_LEN) -Int SOURCE_LEN, 0))
pc: PC_START => PC_START +Int 72
gas: #gas(INITGAS,
          NONMEMGAS => NONMEMGAS +Int #loopGas(PC_START, PC_START +Int 72),
          MEMGAS => MEMGAS +Int (Cmem(BYZANTIUM, FINAL_MEM_USAGE) -Int Cmem(BYZANTIUM, MU)))
memoryUsed: #memoryUsageUpdate(MU, _, _) => FINAL_MEM_USAGE
log: _
refund: _
coinbase: _
+requires:
    andBool DEST_END        ==K DEST_START +Int #ceil32(SOURCE_LEN)
    andBool SOURCE_BUF      ==K selectRange(INIT_MEM, SOURCE_START, SOURCE_LEN)
    andBool FINAL_MEM_USAGE ==K #memoryUsageUpdate(MU, DEST_START, #ceil32(SOURCE_LEN))
+attribute: [trusted, matching(#gas,#memoryUsageUpdate)]

[copy-trusted-data]
+requires:
    andBool PC_START ==Int 18467

[copy-trusted-contractSig]
+requires:
    andBool PC_START ==Int 18569

[checkSignatures-loop-body-success-v1]
+requires:
    andBool select(S, #hashedLocation({COMPILER}, {APPROVED_HASHES}, {CURRENT_OWNER} TX_DATA_HASH)) ==Int APPROVED
    andBool #rangeUInt(256, APPROVED)
    ; v == 1
    andBool #sigV({SIGS_BUF}, I) ==Int 1

[checkSignatures-loop-body-success-v1-owner]
+requires:
    andBool MSG_SENDER ==Int {CURRENT_OWNER}

[checkSignatures-loop-body-success-v1-not-owner]
proxy_storage: S => store(S, #hashedLocation({COMPILER}, {APPROVED_HASHES}, {CURRENT_OWNER} TX_DATA_HASH), 0)
refund: _ => _
+requires:
    andBool MSG_SENDER =/=Int {CURRENT_OWNER}
    andBool APPROVED =/=Int 0

[checkSignatures-loop-body-success-v_else]
+requires:
    andBool #sigV({SIGS_BUF}, I) =/=Int 0
    andBool #sigV({SIGS_BUF}, I) =/=Int 1



[checkSignatures-loop-body-failure]
pc: {PC_LOOP_HEAD} => {PC_FUN_END}
WORD_STACK_RHS: RETURN_LOC : 0 /* return value */ : WS

[checkSignatures-loop-body-failure-trusted]
pc: {PC_LOOP_HEAD} +Int 1 => {PC_FUN_END}
+requires:
    andBool notBool #isValid({SIGS_BUF}, I, TX_DATA_HASH, {DATA_BUF}, S, MSG_SENDER, {EVAL})
EVAL: false
attribute: [trusted, matching(#gas,storeRange,#buf)]

[checkSignatures-loop-body-failure-v0]
+requires:
    ; v == 0
    andBool #sigV({SIGS_BUF}, I) ==Int 0
    andBool #rangeUInt(256, #sigS({SIGS_BUF}, I))
    andBool #rangeUInt(256, SIGS_LOC +Int #sigS({SIGS_BUF}, I))
    ; TODO: what if SIGS_LOC +Int S_I +Int 32 overflows? It will read content before the content of signature.
    andBool #rangeUInt(256, {DYNAMIC_START})
    ; read CONTRACT_SIG_LEN
    andBool SIGS_LOC +Int 32 <=Int {DYNAMIC_START}
    andBool {DYNAMIC_START} +Int 32 <=Int SIGS_LOC +Int 32 +Int SIGS_LEN
    ; read CONTRACT_SIG
    andBool SIGS_LOC +Int 32 <=Int {DYNAMIC_START} +Int 32
    andBool {DYNAMIC_START} +Int 32 +Int {CONTRACT_SIG_LEN} <=Int SIGS_LOC +Int 32 +Int SIGS_LEN
    ; read 64
    andBool 96 <Int NEXT_LOC +Int #ceil32(TX_DATA_LEN) +Int 132 +Int {CONTRACT_SIG_LEN}
    ; read TX_DATA_LEN
    andBool TX_DATA_LOC +Int 32                  <Int {TRAILING_ZERO_START}
    ; read TX_DATA
    andBool TX_DATA_LOC +Int 32 +Int TX_DATA_LEN <Int {TRAILING_ZERO_START}
    ; read SIGS_LEN
    andBool SIGS_LOC +Int 32                     <Int {TRAILING_ZERO_START}
    ; read SIGS
    andBool SIGS_LOC +Int 32 +Int SIGS_LEN       <Int {TRAILING_ZERO_START}
    andBool 0 <Int #extCodeSize({CURRENT_OWNER})
    andBool #callSuccess(18677, {CURRENT_OWNER})
dynamic_start: SIGS_LOC +Int #sigS({SIGS_BUF}, I) +Int 32
contract_sig_len: #asWord(#bufSeg({SIGS_BUF}, #sigS({SIGS_BUF}, I), 32))
trailing_zero_start: NEXT_LOC +Int #ceil32(TX_DATA_LEN) +Int 132 +Int {CONTRACT_SIG_LEN}

[checkSignatures-loop-body-failure-v0-1]
+requires:
    andBool #callResult(18677, {CURRENT_OWNER}) ==K 0

[checkSignatures-loop-body-failure-v0-2]
+requires:
    andBool #callResult(18677, {CURRENT_OWNER}) ==K 1
    andBool ( {CURRENT_OWNER} <=Int LAST_OWNER
       orBool {INIT_CURRENT_OWNER} ==Int 0 )

[checkSignatures-loop-body-failure-v1]
+requires:
    ; v == 1
    andBool #sigV({SIGS_BUF}, I) ==Int 1

[checkSignatures-loop-body-failure-v1-owner]
+requires:
    andBool MSG_SENDER ==Int {CURRENT_OWNER}
    andBool ( {CURRENT_OWNER} <=Int LAST_OWNER
       orBool {INIT_CURRENT_OWNER} ==Int 0 )

[checkSignatures-loop-body-failure-v1-not-owner]
+requires:
    andBool MSG_SENDER =/=Int {CURRENT_OWNER}
    andBool select(S, #hashedLocation({COMPILER}, {APPROVED_HASHES}, {CURRENT_OWNER} TX_DATA_HASH)) ==Int APPROVED
    andBool #rangeUInt(256, APPROVED)

[checkSignatures-loop-body-failure-v1-not-owner-approved]
proxy_storage: S => store(S, #hashedLocation({COMPILER}, {APPROVED_HASHES}, {CURRENT_OWNER} TX_DATA_HASH), 0)
refund: _ => _
+requires:
    andBool APPROVED =/=Int 0
    andBool ( {CURRENT_OWNER} <=Int LAST_OWNER
       orBool {INIT_CURRENT_OWNER} ==Int 0 )

[checkSignatures-loop-body-failure-v1-not-owner-not-approved]
+requires:
    ; andBool APPROVED ==Int 0
    andBool select(S, #hashedLocation({COMPILER}, {APPROVED_HASHES}, {CURRENT_OWNER} TX_DATA_HASH)) ==Int 0

[checkSignatures-loop-body-failure-v_else]
+requires:
    andBool #sigV({SIGS_BUF}, I) =/=Int 0
    andBool #sigV({SIGS_BUF}, I) =/=Int 1

[checkSignatures-loop-body-failure-v_else-ecrecEmpty]
+requires:
    andBool #ecrecEmpty(#ecrecData({SIGS_BUF}, I, TX_DATA_HASH))

[checkSignatures-loop-body-failure-v_else-not-ecrecEmpty]
+requires:
    andBool notBool #ecrecEmpty(#ecrecData({SIGS_BUF}, I, TX_DATA_HASH))
    andBool ( {CURRENT_OWNER} <=Int LAST_OWNER
       orBool {INIT_CURRENT_OWNER} ==Int 0 )


[checkSignatures-loop-body-exception-v0]
k: (#execute => #halt) ~> _
statusCode: _ => EVMC_REVERT
WORD_STACK_RHS: _
pc: {PC_LOOP_HEAD} => 18693
+requires:
    ; v == 0
    andBool #sigV({SIGS_BUF}, I) ==Int 0
    andBool #rangeUInt(256, #sigS({SIGS_BUF}, I))
    andBool #rangeUInt(256, SIGS_LOC +Int #sigS({SIGS_BUF}, I))
    ; TODO: what if SIGS_LOC +Int S_I +Int 32 overflows? It will read content before the content of signature.
    andBool #rangeUInt(256, {DYNAMIC_START})
    ; read CONTRACT_SIG_LEN
    andBool SIGS_LOC +Int 32 <=Int {DYNAMIC_START}
    andBool {DYNAMIC_START} +Int 32 <=Int SIGS_LOC +Int 32 +Int SIGS_LEN
    ; read CONTRACT_SIG
    andBool SIGS_LOC +Int 32 <=Int {DYNAMIC_START} +Int 32
    andBool {DYNAMIC_START} +Int 32 +Int {CONTRACT_SIG_LEN} <=Int SIGS_LOC +Int 32 +Int SIGS_LEN
    ; read 64
    andBool 96 <Int NEXT_LOC +Int #ceil32(TX_DATA_LEN) +Int 132 +Int {CONTRACT_SIG_LEN}
    ; read TX_DATA_LEN
    andBool TX_DATA_LOC +Int 32                  <Int {TRAILING_ZERO_START}
    ; read TX_DATA
    andBool TX_DATA_LOC +Int 32 +Int TX_DATA_LEN <Int {TRAILING_ZERO_START}
    ; read SIGS_LEN
    andBool SIGS_LOC +Int 32                     <Int {TRAILING_ZERO_START}
    ; read SIGS
    andBool SIGS_LOC +Int 32 +Int SIGS_LEN       <Int {TRAILING_ZERO_START}
    andBool 0 <Int #extCodeSize({CURRENT_OWNER})
    andBool #callFailure(18677, {CURRENT_OWNER})
dynamic_start: SIGS_LOC +Int #sigS({SIGS_BUF}, I) +Int 32
contract_sig_len: #asWord(#bufSeg({SIGS_BUF}, #sigS({SIGS_BUF}, I), 32))
trailing_zero_start: NEXT_LOC +Int #ceil32(TX_DATA_LEN) +Int 132 +Int {CONTRACT_SIG_LEN}
ensures:
```

Below is the specification to be used when verifying other (caller) functions.

```ini
[checkSignatures_trusted]
k: #execute ~> _
output: _ => _
statusCode: _ => _
callStack: _
this: #PROXY_ID
msg_sender: MSG_SENDER
callData: _
callValue: 0
log: _
refund: _
coinbase: _
pc: {PC_FUN_START} => {PC_FUN_END}
gas: #gas(INITGAS,
          NONMEMGAS => NONMEMGAS +Int #checkSigsGasNonMem,
          MEMGAS    => MEMGAS +Int (Cmem(BYZANTIUM, FINAL_MEM_USAGE) -Int Cmem(BYZANTIUM, MU)))
memoryUsed: MU => FINAL_MEM_USAGE
wordStack:
    ; parameters
    {CONSUME_HASH} : SIGS_LOC : TX_DATA_LOC : TX_DATA_HASH :
    ; return address
    RETURN_LOC : WS
    =>
    {WORD_STACK_RHS}
localMem: M1 =>
    storeRange(storeRange(storeRange(storeRange(storeRange(M2,
      TX_DATA_LOC        , 32         , #buf(32, TX_DATA_LEN)),
      TX_DATA_LOC +Int 32, TX_DATA_LEN, TX_DATA_BUF),
      SIGS_LOC           , 32         , #buf(32, SIGS_LEN)),
      SIGS_LOC +Int 32   , SIGS_LEN   , SIGS_BUF),
      64                 , 32         , #buf(32, #checkSigsNextLoc(MU)))
proxy_storage:
   S:IMap
+requires:
    ; elements
    andBool FINAL_MEM_USAGE ==Int #checkSigsFinalMemUsed(MU)
    andBool THRESHOLD       ==Int select(S, #hashedLocation({COMPILER}, {THRESHOLD}, .IntList))
    andBool TX_DATA_LEN     ==Int #asWord(selectRange(M1, TX_DATA_LOC, 32))
    andBool SIGS_LEN        ==Int #asWord(selectRange(M1, SIGS_LOC,    32))

    andBool TX_DATA_BUF ==K selectRange(M1, TX_DATA_LOC +Int 32, TX_DATA_LEN)
    andBool SIGS_BUF    ==K selectRange(M1, SIGS_LOC +Int 32, SIGS_LEN)

    ; no overflow
    andBool #rangeUInt(256, THRESHOLD *Int 65)

    ; ranges
    andBool #range(0 <= #sizeWordStack(WS) <= 1000 -Int 12)

    andBool #range(0 <= CD < 1023)
    ; bool consumeHash
    andBool #range(0 <= {CONSUME_HASH} <= 1)
    ; bytes memory signatures
    andBool #rangeUInt(256, SIGS_LOC)
    ; bytes memory data
    andBool #rangeUInt(256, TX_DATA_LOC)
    ; bytes32 dataHash
    andBool #rangeUInt(256, TX_DATA_HASH)
    andBool #rangeUInt(256, THRESHOLD)
    andBool #rangeUInt(256, TX_DATA_LEN)
    andBool #rangeUInt(256, SIGS_LEN)
    andBool #rangeAddress(MSG_SENDER)

    ; practical bounds for localMem address
    andBool #range(96 <= SIGS_LOC          < 2 ^Int 32)
    andBool #range(96 <= TX_DATA_LOC       < 2 ^Int 32)
    ; rough bounds for lengths related to localMem address
    andBool TX_DATA_LEN <Int 2 ^Int 16
    andBool SIGS_LEN    <Int 2 ^Int 16
    andBool THRESHOLD   <Int 2 ^Int 32

    ; no overlap between data and sigatures
    andBool TX_DATA_LOC +Int 32 +Int TX_DATA_LEN <=Int SIGS_LOC

    ; contract invariants
    andBool 1 <=Int THRESHOLD
+ensures:
    andBool #rangeUInt(256, #checkSigsNextLoc(MU))
    andBool #range(96 <= #checkSigsNextLoc(MU) < 2 ^Int 32)
    andBool #range(SIGS_LOC +Int 32 +Int #ceil32(SIGS_LEN) <= #checkSigsNextLoc(MU) < 2 ^Int 32)

+attribute: [trusted, matching(#gas)]

CONSUME_HASH: 1

PC_FUN_START: 18250
PC_FUN_END:   19453

[checkSignatures_trusted-success]
+requires:
    ; enough signatures
    andBool THRESHOLD *Int 65 <=Int SIGS_LEN
    ; valid signatures
    andBool #enoughValidSigs
WORD_STACK_RHS: RETURN_LOC : 1 : WS


[checkSignatures_trusted-failure]
+requires:
    ; not enough signaures or invalid signatures
    andBool ( SIGS_LEN <Int THRESHOLD *Int 65
       orBool notBool #enoughValidSigs )
WORD_STACK_RHS: RETURN_LOC : 0 : WS

[checkSignatures_trusted_exception]
k: (#execute => #halt) ~> _
output: _ => _
statusCode: _ => EVMC_REVERT
callStack: _
this: #PROXY_ID
msg_sender: _
callData: _
callValue: _
log: _ => _
refund: _ => _
coinbase: _
pc: {PC_FUN_START} => 18693
gas: #gas(_, _ => _, _ => _)
memoryUsed: _ => _
wordStack: _ => _
localMem: _ => _
+requires:
    ; enough signatures
    andBool THRESHOLD *Int 65 <=Int SIGS_LEN
    andBool #checkSignaturesException
attribute: [trusted, matching(#gas)]
PC_FUN_START: 18250
```


### Function execTransaction

[`execTransaction`] is an external function that executes the given transaction.

```
    function execTransaction(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 dataGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes calldata signatures
    )
        external
        returns (bool success)
```

We consider only the case of `Enum.Operation.Call` operation (i.e., `operation == 0`).
The other two cases are out of the scope of the current engagement.

#### Stack and memory:

Since it is an external function, it starts with a fresh VM (i.e., both the stack and the memory are empty, the PC is 0, etc.)


#### State update:

The function checks the validity of `signatures`, and reverts if not valid.

Then it increases `nonce`, and calls `execute` with the given transaction.

It finally calls `handlePayment`.


The function has the following non-trivial behaviors:
- `checkSignatures` may revert, which immediately terminates the current VM, without returning to `execTransaction`.
- `execute` does NOT reverts, even if the given transaction execution throws or reverts. The return value of the given transaction, if any, is silently ignored.
  - However, `execute` may still throw for some cases (e.g., when `operation` is not within the range of `Enum.Operation`).
- `handlePayment` may throw or revert, and in that case, `execTransaction` reverts (i.e., the given transaction execution is reverted as well, and no ExecutionFailed event is logged).


#### Function visibility and modifiers:

`msg.value` must be zero, since the function is not `payable`.  Otherwise, it throws.


#### Pre-conditions:

No wrap-around:
- `nonce` is small enough to avoid overflow (wrap-around).

The no-wrap-around condition is implied by the GnosisSafe contract invariant.
(Note that the resource limitation (such as gas) is considered to prove the contract invariant.)
If it is not satisfied, the function may have unexpected behaviors.

Well-formed input:
- The value of the address arguments are within the range of `address`, i.e., the first 96 (= 256 - 160) bits are zero. Otherwise, the function simply ignores (i.e., truncates) the fist 96 bits.
- The maximum size of `data` and `signatures` is 2^32. Otherwise, it reverts. (The bound is practically reasonable considering the current block gas limit. See the buffer size limit discussion.)

These conditions should be satisfied by the client when he calls `execTransaction`.

Non-interfering external contract call:
- The external contract call does not change the current (i.e., the proxy) storage.

The non-interfering external contract call assumption is an under-approximation of all possible behaviors, and thus may lead to missing some behaviors, but it enables the modular reasoning of the function.

NOTE:
A conservative abstraction (i.e., an over-approximation) is possible by assuming that the external contract call may update all deployed accounts (i.e., their balance, storage, nonce, and even code!) and create some new accounts, but never delete an existing account (since the SELFDESTRUCT opcode effect is applied only after the current transaction finishes).
However, such an abstraction is too crude and does not necessarily lead to a better reasoning either.



#### Mechanized formal specification:

Below is the specification that we verified against the GnosisSafe contract bytecode.

```ini
[execTransaction]
k: (#execute => #halt) ~> _
callStack: _
this: #PROXY_ID
msg_sender: MSG_SENDER
callData: #abiCallData("execTransaction", (
            #address(TO),
            #uint256(VALUE),
            #bytes(#buf(DATA_LEN, DATA)),
            ; Enum.Operation operation, represented as uint8
            #uint8(OPERATION),
            #uint256(SAFE_TX_GAS),
            #uint256(DATA_GAS),
            #uint256(GAS_PRICE),
            #address(GAS_TOKEN),
            #address(REFUND_RECEIVER),
            #bytes(#buf(SIGS_LEN, SIGS)) ))
callValue: 0
wordStack: .WordStack => _
localMem: .IMap => _
pc: 0 => _
gas: #gas(INITGAS, 0, 0) => _
memoryUsed: 0 => _
log: _
refund: _ => _
coinbase: _ => _
proxy_storage:
    store(store(store(M1, #hashedLocation({COMPILER}, {THRESHOLD}, .IntList),        THRESHOLD),
                          #hashedLocation({COMPILER}, {NONCE}, .IntList),            NONCE => {NEW_NONCE}),
                          #hashedLocation({COMPILER}, {DOMAIN_SEPARATOR}, .IntList), DOMAIN_SEPARATOR)
NEW_NONCE: NONCE +Int 1
proxy_origstorage: store(M2, #hashedLocation({COMPILER}, {NONCE}, .IntList),         ORIG_NONCE)
+requires:
    andBool #range(0 <= CD < 1023)

    ; Range
    andBool #rangeAddress(MSG_SENDER)
    andBool #rangeAddress(TO)
    andBool #rangeUInt(256, VALUE)
    andBool #rangeUInt(256, DATA_LEN)
    andBool #rangeUInt(8  , OPERATION)
    ; enum Enum.Call
    andBool OPERATION ==Int 0
    andBool #rangeUInt(256, SAFE_TX_GAS)
    andBool #rangeUInt(256, DATA_GAS)
    andBool #rangeUInt(256, GAS_PRICE)
    andBool #rangeAddress(GAS_TOKEN)
    andBool #rangeAddress(REFUND_RECEIVER)
    andBool #rangeUInt(256, SIGS_LEN)
    andBool #rangeUInt(256, THRESHOLD)
    andBool #rangeUInt(256, NONCE)
    andBool #rangeBytes(32, DOMAIN_SEPARATOR)
    andBool #rangeUInt(256, ORIG_NONCE)

    andBool #range(1 <= THRESHOLD < 2 ^Int 32)
    andBool DATA_LEN <Int 2 ^Int 16
    andBool SIGS_LEN <Int 2 ^Int 16
    andBool NONCE    <Int maxUInt256

[execTransaction-checkSigs-exception]
output: _ => _
statusCode: _ => EVMC_REVERT
log: _ => _
NEW_NONCE: NONCE
+requires:
    ; enough signatures but exception
    andBool SIGS_LEN >=Int THRESHOLD *Int 65
    andBool #checkSignaturesException

[execTransaction-checkSigs0]
output: _ => _
statusCode: _ => EVMC_REVERT
NEW_NONCE: NONCE
+requires:
    ; not enough signaures or invalid signatures
    andBool ( SIGS_LEN <Int THRESHOLD *Int 65
       orBool notBool #enoughValidSigs )

[execTransaction-checkSigs1]
+requires:
    ; enough signatures
    andBool THRESHOLD *Int 65 <=Int SIGS_LEN
    ; valid signatures
    andBool #enoughValidSigs

[execTransaction-checkSigs1-gas0]
output: _ => _
statusCode: _ => EVMC_REVERT
+requires:
    // gasleft() < safeTxGas
    andBool SAFE_TX_GAS >Int  #gas(INITGAS, 9 *Int (DATA_LEN up/Int 32) +Int 3 *Int (SIGS_LEN up/Int 32) +Int #checkSigsGasNonMem +Int Csstore(BYZANTIUM, NONCE +Int 1, NONCE, ORIG_NONCE) +Int 2903, Cmem(BYZANTIUM, #checkSigsFinalMemUsed(#memoryUsageUpdate(5, #ceil32(DATA_LEN) +Int 674 +Int SIGS_LEN, 32))))

[execTransaction-checkSigs1-gas1]
+requires:
    // gasleft() >= safeTxGas
    andBool SAFE_TX_GAS <=Int  #gas(INITGAS, 9 *Int (DATA_LEN up/Int 32) +Int 3 *Int (SIGS_LEN up/Int 32) +Int #checkSigsGasNonMem +Int Csstore(BYZANTIUM, NONCE +Int 1, NONCE, ORIG_NONCE) +Int 2903, Cmem(BYZANTIUM, #checkSigsFinalMemUsed(#memoryUsageUpdate(5, #ceil32(DATA_LEN) +Int 674 +Int SIGS_LEN, 32))))

[execTransaction-checkSigs1-gas1-safetxgas0-gasprice0]
+requires:
    andBool SAFE_TX_GAS ==Int 0
    andBool GAS_PRICE ==Int 0

[execTransaction-checkSigs1-gas1-safetxgas0-gasprice0-call0]
output: _ => #buf(32, 0)
statusCode: _ => EVMC_SUCCESS
log: _:List ( .List => ListItem(#abiEventLog(#PROXY_ID, "ExecutionFailed", #bytes32({TX_HASH_DATA}))) )
+requires:
    andBool CALL_PC ==Int 22225
    andBool #callFailure(CALL_PC, TO)
TX_HASH_DATA: keccak(25 : 1 : #encodeArgs(#bytes32(DOMAIN_SEPARATOR), #bytes32({SAFE_TX_HASH})))
SAFE_TX_HASH: keccak(#encodeArgs(#bytes32(#parseHexWord({SAFE_TX_TYPEHASH})),
                                 #address(TO),
                                 #uint256(VALUE),
                                 #bytes32(keccak(#buf(DATA_LEN, DATA))),
                                 #uint8(OPERATION),
                                 #uint256(SAFE_TX_GAS),
                                 #uint256(DATA_GAS),
                                 #uint256(GAS_PRICE),
                                 #address(GAS_TOKEN),
                                 #address(REFUND_RECEIVER),
                                 #uint256(NONCE) ))

[execTransaction-checkSigs1-gas1-safetxgas0-gasprice0-call1]
output: _ => #buf(32, 1)
statusCode: _ => EVMC_SUCCESS
+requires:
    andBool CALL_PC ==Int 22225
    andBool #callSuccess(CALL_PC, TO)

[execTransaction-checkSigs1-gas1-safetxgas0-gasprice0-call1-to]
proxy_bal: PROXY_BAL => PROXY_BAL -Int VALUE
acct_to_bal: ACCT_TO_BAL => ACCT_TO_BAL +Int VALUE
+requires:
    andBool TO ==Int #EXEC_ACCT_TO
    andBool VALUE <=Int PROXY_BAL
    andBool ACCT_TO_BAL +Int VALUE <Int pow256

[execTransaction-checkSigs1-gas1-safetxgas0-gasprice1]
+requires:
    andBool SAFE_TX_GAS ==Int 0
    andBool 0 <Int GAS_PRICE

[execTransaction-checkSigs1-gas1-safetxgas0-gasprice1-call0]
k: (#execute => #handlePaymentSpecApplied) ~> _
output: _ => _
statusCode: _ => _
pc: 0 => 19729
log: _:List ( .List => ListItem(#abiEventLog(#PROXY_ID, "ExecutionFailed", #bytes32({TX_HASH_DATA}))) )
+requires:
    andBool CALL_PC ==Int 22225
    andBool #callFailure(CALL_PC, TO)
TX_HASH_DATA: keccak(25 : 1 : #encodeArgs(#bytes32(DOMAIN_SEPARATOR), #bytes32({SAFE_TX_HASH})))
SAFE_TX_HASH: keccak(#encodeArgs(#bytes32(#parseHexWord({SAFE_TX_TYPEHASH})),
                                 #address(TO),
                                 #uint256(VALUE),
                                 #bytes32(keccak(#buf(DATA_LEN, DATA))),
                                 #uint8(OPERATION),
                                 #uint256(SAFE_TX_GAS),
                                 #uint256(DATA_GAS),
                                 #uint256(GAS_PRICE),
                                 #address(GAS_TOKEN),
                                 #address(REFUND_RECEIVER),
                                 #uint256(NONCE) ))

[execTransaction-checkSigs1-gas1-safetxgas0-gasprice1-call1]
+requires:
    andBool CALL_PC ==Int 22225
    andBool #callSuccess(CALL_PC, TO)

[execTransaction-checkSigs1-gas1-safetxgas0-gasprice1-call1-to]
k: (#execute => #handlePaymentSpecApplied) ~> _
output: _ => _
statusCode: _ => _
pc: 0 => 19729
proxy_bal: PROXY_BAL => PROXY_BAL -Int VALUE
acct_to_bal: ACCT_TO_BAL => ACCT_TO_BAL +Int VALUE
+requires:
    andBool CALL_PC ==Int 22225
    andBool #callSuccess(CALL_PC, TO)
    andBool TO ==Int #EXEC_ACCT_TO
    andBool VALUE <=Int PROXY_BAL
    andBool ACCT_TO_BAL +Int VALUE <Int pow256

[execTransaction-checkSigs1-gas1-safetxgas1]
+requires:
    andBool 0 <Int SAFE_TX_GAS

[execTransaction-checkSigs1-gas1-safetxgas1-call0]
log: _:List ( .List => ListItem(#abiEventLog(#PROXY_ID, "ExecutionFailed", #bytes32({TX_HASH_DATA}))) )
+requires:
    andBool CALL_PC ==Int 22225
    andBool #callFailure(CALL_PC, TO)

TX_HASH_DATA: keccak(25 : 1 : #encodeArgs(#bytes32(DOMAIN_SEPARATOR), #bytes32({SAFE_TX_HASH})))
SAFE_TX_HASH: keccak(#encodeArgs(#bytes32(#parseHexWord({SAFE_TX_TYPEHASH})),
                                 #address(TO),
                                 #uint256(VALUE),
                                 #bytes32(keccak(#buf(DATA_LEN, DATA))),
                                 #uint8(OPERATION),
                                 #uint256(SAFE_TX_GAS),
                                 #uint256(DATA_GAS),
                                 #uint256(GAS_PRICE),
                                 #address(GAS_TOKEN),
                                 #address(REFUND_RECEIVER),
                                 #uint256(NONCE) ))

[execTransaction-checkSigs1-gas1-safetxgas1-call0-to]
+requires:
    andBool TO ==Int #EXEC_ACCT_TO

[execTransaction-checkSigs1-gas1-safetxgas1-call0-to-gasprice0]
output: _ => #buf(32, 0)
statusCode: _ => EVMC_SUCCESS
+requires:
    andBool GAS_PRICE ==Int 0

[execTransaction-checkSigs1-gas1-safetxgas1-call0-to-gasprice1]
k: (#execute => #handlePaymentSpecApplied) ~> _
output: _ => _
statusCode: _ => _
pc: 0 => 19729
+requires:
    andBool 0 <Int GAS_PRICE

[execTransaction-checkSigs1-gas1-safetxgas1-call1]
+requires:
    andBool CALL_PC ==Int 22225
    andBool #callSuccess(CALL_PC, TO)

[execTransaction-checkSigs1-gas1-safetxgas1-call1-to]
proxy_bal: PROXY_BAL => PROXY_BAL -Int VALUE
acct_to_bal: ACCT_TO_BAL => ACCT_TO_BAL +Int VALUE
+requires:
    andBool TO ==Int #EXEC_ACCT_TO
    andBool VALUE <=Int PROXY_BAL
    andBool ACCT_TO_BAL +Int VALUE <Int pow256

[execTransaction-checkSigs1-gas1-safetxgas1-call1-to-gasprice0]
output: _ => #buf(32, 1)
statusCode: _ => EVMC_SUCCESS
+requires:
    andBool GAS_PRICE ==Int 0

[execTransaction-checkSigs1-gas1-safetxgas1-call1-to-gasprice1]
k: (#execute => #handlePaymentSpecApplied) ~> _
output: _ => _
statusCode: _ => _
pc: 0 => 19729
+requires:
    andBool 0 <Int GAS_PRICE
```

## OwnerManager contract

The OwnerManager contract maintains the set of owners.

The storage state of `owners` represents a (non-empty) list of `(o_0, o_1, ... o_N)`, which denotes the (possibly empty) set of owners `{o_1, ..., o_N}`. (Note that `o_0` is a dummy element of the list, not an owner.)

The OwnerManager contract must satisfy the following contract invariant, once initialized (after `setup`):
- `ownerCount >= threshold >= 1`
- `ownerCount` is small enough to avoid overflow
- `owners` represents the list of `(o_0, o_1, ..., o_N)` such that:
  - `N = ownerCount`
  - `o_i` is non-zero (for all `0 <= i <= N`)
  - `o_0 = 1`
  - all `o_i`'s are distinct (for `0 <= i <= N`)
  - `owners[o_i] = o_{i+1 mod N+1}` for `0 <= i <= N`
  - `owners[x]` = 0 for any `x` not in the list `(o_0, ..., o_N)`


### Function addOwnerWithThreshold

[`addOwnerWithThreshold`] is a public authorized function that adds a new owner and updates `threshold`.

```
    function addOwnerWithThreshold(address owner, uint256 _threshold)
        public
        authorized
```

#### State update:

Suppose `owners` represents `(o_0, o_1, ..., o_N)` and the contract invariant holds before calling the function.
Note that the contract invariant implies `N >= 1`.

The function reverts if one of the following input conditions is not satisfied:
- The argument `owner` should be a non-zero new owner, i.e., `owner =/= 0` and `owner =/= o_i` for all `0 <= i <= N`.
- The argument `_threshold` should be within the range of `[1, N+1]`, inclusive.

NOTE:
The check `require(owner != SENTINEL_OWNERS)` is logically redundant in the presence of `require(owners[owner] == address(0))` and the given contract invariant.

If the function succeeds, the post state will be:
- `owners` will represent `(o_0, owner, o_1, ..., o_N)`.
- `ownerCount = N+1`
- `threshold = _threshold`


#### Function visibility and modifiers:

The function should be invoked by the proxy account. Otherwise, it reverts.




```ini
[addOwnerWithThreshold]
k: (#execute => #halt) ~> _
callStack: _
wordStack: .WordStack => _
localMem: .IMap => _
pc: 0 => _
gas: #gas(STARTGAS, 0, 0) => _
memoryUsed: 0 => _
refund: _ => _
coinbase: _ => _
output: _ => _
this: #PROXY_ID
msg_sender: MSG_SENDER
callData: #abiCallData("addOwnerWithThreshold", (#address(OWNER), #uint256(NEW_THRESHOLD)))
callValue: 0
proxy_storage:
    M1:IMap => M2:IMap
+requires:
    ; Storage
    andBool select(M1, #hashedLocation({COMPILER}, {OWNERS},     #SENTINEL)) ==Int INIT_SENTINEL
    andBool select(M1, #hashedLocation({COMPILER}, {OWNERS},     OWNER))     ==Int INIT_OWNER
    andBool select(M1, #hashedLocation({COMPILER}, {THRESHOLD},  .IntList))  ==Int THRESHOLD
    andBool select(M1, #hashedLocation({COMPILER}, {OWNERCOUNT}, .IntList))  ==Int OWNERCOUNT
    ; Range
    andBool #rangeAddress(  OWNER)
    andBool #rangeAddress(  INIT_SENTINEL)
    andBool #rangeAddress(  INIT_OWNER)
    andBool #rangeAddress(  MSG_SENDER)
    andBool #rangeUInt(256, NEW_THRESHOLD)
    andBool #rangeUInt(256, THRESHOLD)
    andBool #rangeUInt(256, OWNERCOUNT)
+ensures:

[addOwnerWithThreshold-success]
statusCode: _ => EVMC_SUCCESS
+requires:
    ; requirements from code
    ; authorized
    andBool MSG_SENDER ==Int #PROXY_ID
    ; Owner address cannot be null
    andBool OWNER     =/=Int 0
    andBool OWNER     =/=Int #SENTINEL
    ; No duplicate owners allowed
    andBool INIT_OWNER ==Int 0
    ; The hashes are different (the hash2 lemma is not enough)
    andBool #hashedLocation({COMPILER}, {OWNERS}, #SENTINEL) =/=Int #hashedLocation({COMPILER}, {OWNERS}, OWNER)
    ; Avoid overflow
    andBool OWNERCOUNT +Int 1 <Int pow256
+ensures:
    andBool select(M2, #hashedLocation({COMPILER}, {OWNERS},     #SENTINEL)) ==Int OWNER
    andBool select(M2, #hashedLocation({COMPILER}, {OWNERS},     OWNER))     ==Int INIT_SENTINEL
    andBool select(M2, #hashedLocation({COMPILER}, {OWNERCOUNT}, .IntList))  ==Int OWNERCOUNT +Int 1

[addOwnerWithThreshold-success-1]
log: _:List ( .List => ListItem(#abiEventLog(MSG_SENDER, "AddedOwner", #address(OWNER))) )
+requires:
    andBool THRESHOLD ==Int NEW_THRESHOLD
+ensures:
    andBool select(M2, #hashedLocation({COMPILER}, {THRESHOLD}, .IntList)) ==Int THRESHOLD
    andBool M2 ==IMap M1 except (
        SetItem(#hashedLocation({COMPILER}, {OWNERS}, #SENTINEL))
        SetItem(#hashedLocation({COMPILER}, {OWNERS}, OWNER))
        SetItem(#hashedLocation({COMPILER}, {OWNERCOUNT}, .IntList))
        .Set )

[addOwnerWithThreshold-success-2]
log: _:List ( .List =>
        ListItem(#abiEventLog(MSG_SENDER, "AddedOwner",       #address(OWNER)))
        ListItem(#abiEventLog(MSG_SENDER, "ChangedThreshold", #uint256(NEW_THRESHOLD))) )
+requires:
    andBool THRESHOLD     =/=Int NEW_THRESHOLD
    ; Requirements from code
    ; Validate that threshold is smaller than number of owners
    andBool NEW_THRESHOLD <=Int OWNERCOUNT +Int 1
    ; There has to be at least one safe owner
    andBool NEW_THRESHOLD >=Int 1
+ensures:
    andBool select(M2, #hashedLocation({COMPILER}, {THRESHOLD}, .IntList)) ==Int NEW_THRESHOLD
    andBool M2 ==IMap M1 except (
        SetItem(#hashedLocation({COMPILER}, {OWNERS}, #SENTINEL))
        SetItem(#hashedLocation({COMPILER}, {OWNERS}, OWNER))
        SetItem(#hashedLocation({COMPILER}, {OWNERCOUNT}, .IntList))
        SetItem(#hashedLocation({COMPILER}, {THRESHOLD}, .IntList))
        .Set )

[addOwnerWithThreshold-failure]
+ensures:
    andBool M2 ==IMap M1 except (
        SetItem(#hashedLocation({COMPILER}, {OWNERS}, #SENTINEL))
        SetItem(#hashedLocation({COMPILER}, {OWNERS}, OWNER))
        SetItem(#hashedLocation({COMPILER}, {OWNERCOUNT}, .IntList))
        SetItem(#hashedLocation({COMPILER}, {THRESHOLD}, .IntList))
        .Set )

[addOwnerWithThreshold-failure-1]
log: _
statusCode: _ => EVMC_REVERT

[addOwnerWithThreshold-failure-1-a]
+requires:
    ; Property to verify does not hold
    andBool MSG_SENDER =/=Int #PROXY_ID

[addOwnerWithThreshold-failure-1-b]
+requires:
    ; Property to verify
    andBool MSG_SENDER ==Int #PROXY_ID
    ; Requirements from code do not hold
    andBool (   OWNER      ==Int 0
        orBool  OWNER      ==Int #SENTINEL
        orBool  INIT_OWNER =/=Int 0 )

[addOwnerWithThreshold-failure-2]
statusCode: _ => EVMC_REVERT
log: _ => _
+requires:
    ; Property to verify
    andBool MSG_SENDER ==Int #PROXY_ID
    ; Requirements from code
    ; Owner address cannot be null
    andBool OWNER     =/=Int 0
    andBool OWNER     =/=Int #SENTINEL
    ; No duplicate owners allowed
    andBool INIT_OWNER ==Int 0
    ; The hashes are different (the hash2 lemma is not enough)
    andBool #hashedLocation({COMPILER}, {OWNERS}, #SENTINEL) =/=Int #hashedLocation({COMPILER}, {OWNERS}, OWNER)
    ; Avoid overflow
    andBool OWNERCOUNT +Int 1 <Int pow256
    andBool THRESHOLD     =/=Int NEW_THRESHOLD
    ; Requirements from code do not hold
    andBool ( NEW_THRESHOLD  >Int  OWNERCOUNT +Int 1
        orBool NEW_THRESHOLD ==Int 0 )

[addOwnerWithThreshold-failure-3]
log: _ => _
+requires:
    ; Property to verify
    andBool MSG_SENDER ==Int #PROXY_ID
    ; Requirements from code
    ; Owner address cannot be null
    andBool OWNER     =/=Int 0
    andBool OWNER     =/=Int #SENTINEL
    ; No duplicate owners allowed
    andBool INIT_OWNER ==Int 0
    ; The hashes are different (the hash2 lemma is not enough)
    andBool #hashedLocation({COMPILER}, {OWNERS}, #SENTINEL) =/=Int #hashedLocation({COMPILER}, {OWNERS}, OWNER)
    ; Overflow
    andBool OWNERCOUNT +Int 1 >=Int pow256

[addOwnerWithThreshold-failure-3-a]
statusCode: _ => EVMC_SUCCESS
+requires:
    andBool THRESHOLD ==Int NEW_THRESHOLD
+ensures:
    andBool select(M2, #hashedLocation({COMPILER}, {OWNERS},     #SENTINEL)) ==Int OWNER
    andBool select(M2, #hashedLocation({COMPILER}, {OWNERS},     OWNER))     ==Int INIT_SENTINEL
    andBool select(M2, #hashedLocation({COMPILER}, {OWNERCOUNT}, .IntList))  ==Int OWNERCOUNT +Word 1
    andBool select(M2, #hashedLocation({COMPILER}, {THRESHOLD}, .IntList))   ==Int THRESHOLD

[addOwnerWithThreshold-failure-3-b]
statusCode: _ => EVMC_REVERT
+requires:
    andBool THRESHOLD =/=Int NEW_THRESHOLD
    ; The requirements specified in the function changeThreshold cannot hold in the case of overflow,
    ; as OWNERCOUNT + 1 = 0, and both requirements cannot hold at the same time
    ;   Requirements from code:
    ;   Validate that threshold is smaller than number of owners
    ;   andBool NEW_THRESHOLD <=Int OWNERCOUNT
    ;   There has to be at least one safe owner
    ;   andBool NEW_THRESHOLD >=Int 1
```

### Function removeOwner

[`removeOwner`] is a public authorized function that removes the given owner and updates `threshold`.

```
    function removeOwner(address prevOwner, address owner, uint256 _threshold)
        public
        authorized
```

#### State update:

Suppose `owners` represents `(o_0, o_1, ..., o_N)` and the contract invariant holds before calling the function.
Note that the contract invariant implies `N >= 1`.

The function reverts if one of the following input conditions is not satisfied:
- `N >= 2`
- There exists `0 <= k < N` such that `prevOwner = o_k` and `owner = o_{k+1}`.
- The argument `_threshold` should be within the range of `[1, N-1]`, inclusive.

NOTE:
The check `require(owner != SENTINEL_OWNERS)` is necessary to ensure `k =/= N`.

If the function succeeds, the post state will be:
- `owners` will represent `(..., o_k, o_{k+2}, ...)` for `0 <= k < N`.
- `ownerCount = N-1`
- `threshold = _threshold`


#### Function visibility and modifiers:

The function should be invoked by the proxy account. Otherwise, it reverts.



```ini
[removeOwner]
k: (#execute => #halt) ~> _
output: _ => _
callStack: _
this: #PROXY_ID
msg_sender: MSG_SENDER
callData: #abiCallData("removeOwner", (#address(PREV_OWNER),
                                       #address(OWNER),
                                       #uint256(NEW_THRESHOLD)))
callValue: 0
wordStack: .WordStack => _
localMem: .IMap => _
pc: 0 => _
gas: #gas(STARTGAS, 0, 0) => _
memoryUsed: 0 => _
refund: _ => _
coinbase: _ => _
proxy_storage:
    M1:IMap => M2:IMap
+requires:
    ; storage
    andBool select(M1, #hashedLocation({COMPILER}, {OWNERS}, OWNER))        ==Int INIT_OWNER
    andBool select(M1, #hashedLocation({COMPILER}, {OWNERS}, PREV_OWNER))   ==Int INIT_PREV_OWNER
    andBool select(M1, #hashedLocation({COMPILER}, {THRESHOLD}, .IntList))  ==Int THRESHOLD
    andBool select(M1, #hashedLocation({COMPILER}, {OWNERCOUNT}, .IntList)) ==Int OWNERCOUNT
    ; Contract invariant
    andBool OWNERCOUNT >=Int 1
    ; Range
    andBool #rangeAddress(  MSG_SENDER)
    andBool #rangeAddress(  PREV_OWNER)
    andBool #rangeAddress(  OWNER)
    andBool #rangeAddress(  INIT_OWNER)
    andBool #rangeAddress(  INIT_PREV_OWNER)
    andBool #rangeUInt(256, NEW_THRESHOLD)
    andBool #rangeUInt(256, THRESHOLD)
    andBool #rangeUInt(256, OWNERCOUNT)
ensures:

[removeOwner-success]
statusCode: _ => EVMC_SUCCESS
+requires:
    ; Property to verify
    andBool MSG_SENDER ==Int #PROXY_ID
    ; Requirements from code
    ; Only allow to remove an owner, if threshold can still be reached.
    andBool OWNERCOUNT -Int 1 >=Int NEW_THRESHOLD
    ; Validate owner address and check that it corresponds to owner index
    andBool OWNER =/=Int 0
    andBool OWNER =/=Int #SENTINEL
    andBool INIT_PREV_OWNER ==Int OWNER
    ; Path condition
    andBool OWNER =/=Int PREV_OWNER     // implied from 'owners[prevOwner] == owner' and 'owner != SENTINEL_OWNERS'
+ensures:
   andBool select(M2, #hashedLocation({COMPILER}, {OWNERS}, OWNER))         ==Int 0
   andBool select(M2, #hashedLocation({COMPILER}, {OWNERS}, PREV_OWNER))    ==Int INIT_OWNER
   andBool select(M2, #hashedLocation({COMPILER}, {OWNERCOUNT}, .IntList))  ==Int OWNERCOUNT -Int 1
   andBool M1 ==IMap M2 except (
        SetItem(#hashedLocation({COMPILER}, {OWNERS}, OWNER))
        SetItem(#hashedLocation({COMPILER}, {OWNERS}, PREV_OWNER))
        SetItem(#hashedLocation({COMPILER}, {THRESHOLD}, .IntList))
        SetItem(#hashedLocation({COMPILER}, {OWNERCOUNT}, .IntList))
        .Set)

[removeOwner-success-1]
log: _:List ( .List => ListItem(#abiEventLog(#PROXY_ID, "RemovedOwner", #address(OWNER))) )
+requires:
    ; Requirements from code
    ; Threshold is unchanged
    andBool THRESHOLD ==Int NEW_THRESHOLD
+ensures:
    andBool select(M2, #hashedLocation({COMPILER}, {THRESHOLD}, .IntList))   ==Int THRESHOLD

[removeOwner-success-2]
log: _:List ( .List => ListItem(#abiEventLog(#PROXY_ID, "RemovedOwner", #address(OWNER)))
                       ListItem(#abiEventLog(#PROXY_ID, "ChangedThreshold", #uint256(NEW_THRESHOLD))) )
+requires:
    ; Requirements from code
    ; Threshold is changed.
    andBool THRESHOLD =/=Int NEW_THRESHOLD
    ; Requirements from changeThreshold
    ; Validate that threshold is smaller than number of owners
    ; andBool NEW_THRESHOLD <=Int OWNERCOUNT -Int 1 // already in the pre-condition
    ; There has to be at least one Safe owner
    andBool NEW_THRESHOLD >=Int 1
+ensures:
   andBool select(M2, #hashedLocation({COMPILER}, {THRESHOLD}, .IntList))   ==Int NEW_THRESHOLD

[removeOwner-failure]
statusCode: _ => EVMC_REVERT
+ensures:
   andBool M1 ==IMap M2 except (
        SetItem(#hashedLocation({COMPILER}, {OWNERS}, OWNER))
        SetItem(#hashedLocation({COMPILER}, {OWNERS}, PREV_OWNER))
        SetItem(#hashedLocation({COMPILER}, {THRESHOLD}, .IntList))
        SetItem(#hashedLocation({COMPILER}, {OWNERCOUNT}, .IntList))
        .Set)

[removeOwner-failure-1]
log: _

[removeOwner-failure-1-a]
+requires:
    ; Property to verify doesn't hold
    andBool MSG_SENDER =/=Int #PROXY_ID

[removeOwner-failure-1-b]
+requires:
    ; Property to verify
    andBool MSG_SENDER ==Int #PROXY_ID
    ; Requirements from code that don't hold
    andBool ( OWNERCOUNT -Int 1 <Int NEW_THRESHOLD
       orBool OWNER ==Int 0
       orBool OWNER ==Int #SENTINEL
       orBool INIT_PREV_OWNER =/=Int OWNER )

[removeOwner-failure-2]
log: _ => _
+requires:
    ; Property to verify
    andBool MSG_SENDER ==Int #PROXY_ID
    ; Requirements from code
    ; Only allow to remove an owner, if threshold can still be reached.
    andBool OWNERCOUNT -Int 1 >=Int NEW_THRESHOLD
    ; Validate owner address and check that it corresponds to owner index
    andBool OWNER =/=Int 0
    andBool OWNER =/=Int #SENTINEL
    andBool INIT_PREV_OWNER ==Int OWNER
    ; Path condition
    andBool OWNER =/=Int PREV_OWNER     // implied from 'owners[prevOwner] == owner' and 'owner != SENTINEL_OWNERS'
    ; Threshold is changed
    andBool THRESHOLD =/=Int NEW_THRESHOLD
    ; Requirements from code that don't hold
    ; andBool NEW_THRESHOLD >Int OWNERCOUNT -Int 1 // negation of this req. in the pre-condition
    andBool NEW_THRESHOLD ==Int 0
```

### Function swapOwner

[`swapOwner`] is a public authorized function that replaces `oldOwner` with `newOwner`.

```
    function swapOwner(address prevOwner, address oldOwner, address newOwner)
        public
        authorized
```

#### State update:

Suppose `owners` represents `(o_0, o_1, ..., o_N)` and the contract invariant holds before calling the function.
Note that the contract invariant implies `N >= 1`.

The function reverts if one of the following input conditions is not satisfied:
- The argument `newOwner` should be a non-zero new owner, i.e., `newOwner =/= 0` and `newOwner =/= o_i` for all `0 <= i <= N`.
- There exists `0 <= k < N` such that `prevOwner = o_k` and `oldOwner = o_{k+1}`.

NOTE:
- The check `require(newOwner != SENTINEL_OWNERS)` is logically redundant in the presence of `require(owners[newOwner] == address(0))` and the given contract invariant.
- The check `require(oldOwner != SENTINEL_OWNERS)`, however, is necessary to ensure `k =/= N`.

If the function succeeds, the post state will be:
- `owners` will represent `(..., o_k, newOwner, ...)` for `0 <= k < N`.
- `ownerCount` and `threshold` are not updated.


#### Function visibility and modifiers:

The function should be invoked by the proxy account. Otherwise, it reverts.


```ini
[swapOwner]
k: (#execute => #halt) ~> _
output: _ => _
callStack: _
this: #PROXY_ID
msg_sender: MSG_SENDER
callData: #abiCallData("swapOwner", (#address(PREV_OWNER), #address(OLD_OWNER), #address(NEW_OWNER)))
callValue: 0
wordStack: .WordStack => _
localMem: .IMap => _
pc: 0 => _
gas: #gas(STARTGAS, 0, 0) => _
memoryUsed: 0 => _
refund: _ => _
coinbase: _ => _
proxy_storage:
    M1:IMap => M2:IMap
+requires:
    ; storage
    andBool INIT_PREV_OWNER ==Int select(M1:IMap, #hashedLocation({COMPILER}, {OWNERS}, PREV_OWNER))
    andBool INIT_OLD_OWNER  ==Int select(M1:IMap, #hashedLocation({COMPILER}, {OWNERS}, OLD_OWNER))
    andBool INIT_NEW_OWNER  ==Int select(M1:IMap, #hashedLocation({COMPILER}, {OWNERS}, NEW_OWNER))
    ; Range
    andBool #rangeAddress(MSG_SENDER)
    andBool #rangeAddress(PREV_OWNER)
    andBool #rangeAddress(OLD_OWNER)
    andBool #rangeAddress(NEW_OWNER)
    andBool #rangeAddress(INIT_PREV_OWNER)
    andBool #rangeAddress(INIT_OLD_OWNER)
    andBool #rangeAddress(INIT_NEW_OWNER)
ensures:
   andBool M1 ==IMap M2 except (
        SetItem(#hashedLocation({COMPILER}, {OWNERS}, PREV_OWNER))
        SetItem(#hashedLocation({COMPILER}, {OWNERS}, OLD_OWNER))
        SetItem(#hashedLocation({COMPILER}, {OWNERS}, NEW_OWNER))
       .Set)

[swapOwner-success]
statusCode: _ => EVMC_SUCCESS
log: _:List ( .List => ListItem(#abiEventLog(#PROXY_ID, "RemovedOwner", #address(OLD_OWNER)))
                       ListItem(#abiEventLog(#PROXY_ID, "AddedOwner",   #address(NEW_OWNER))) )
+requires:
    ; requirements from code
    ; authorized
    andBool MSG_SENDER ==Int #PROXY_ID
    ; Owner address cannot be null.
    andBool NEW_OWNER =/=Int 0
    andBool NEW_OWNER =/=Int #SENTINEL
    ; No duplicate owners allowed.
    andBool INIT_NEW_OWNER ==Int 0
    ; Validate oldOwner address and check that it corresponds to owner index
    andBool OLD_OWNER =/=Int 0
    andBool OLD_OWNER =/=Int #SENTINEL
    andBool INIT_PREV_OWNER ==Int OLD_OWNER
    ; path condition
    ; All owners are different
    andBool PREV_OWNER =/=Int OLD_OWNER  // implied from `owners[prevOwner] == oldOwner` (implying `prevOwner != oldOwner` or `prevOwner == oldOwner == SENTINEL_OWNERS`) and `oldOwner != SENTINEL_OWNERS`
    andBool PREV_OWNER =/=Int NEW_OWNER  // implied from `owners[prevOwner] == oldOwner != address(0)` and `owners[newOwner] == address(0)`
    andBool OLD_OWNER  =/=Int NEW_OWNER  // implied from `owners[prevOwner] == oldOwner` (implying `owners[oldOwner] != address(0)`) and `owners[newOwner] == address(0)`
+ensures:
   andBool select(M2, #hashedLocation({COMPILER}, {OWNERS}, PREV_OWNER)) ==Int NEW_OWNER
   andBool select(M2, #hashedLocation({COMPILER}, {OWNERS}, OLD_OWNER))  ==Int 0
   andBool select(M2, #hashedLocation({COMPILER}, {OWNERS}, NEW_OWNER))  ==Int INIT_OLD_OWNER

[swapOwner-failure]
statusCode: _ => EVMC_REVERT
log: _

[swapOwner-failure-1]
+requires:
    ; requirements from code won't hold
    ; authorized
    andBool MSG_SENDER =/=Int #PROXY_ID

[swapOwner-failure-2]
+requires:
    ; requirements from code won't hold
    ; authorized
    andBool MSG_SENDER ==Int #PROXY_ID
    ; Owner address cannot be null.
    andBool ( NEW_OWNER ==Int 0
       orBool NEW_OWNER ==Int #SENTINEL
       ; No duplicate owners allowed.
       orBool INIT_NEW_OWNER =/=Int 0
       ; Validate oldOwner address and check that it corresponds to owner index
       orBool OLD_OWNER ==Int 0
       orBool OLD_OWNER ==Int #SENTINEL
       orBool INIT_PREV_OWNER =/=Int OLD_OWNER )
```

## ModuleManager contract

The ModuleManager contract maintains the set of modules.

The storage state of `modules` represents a (non-empty) list of `(m_0, m_1, ... m_N)`, which denotes the (possibly empty) set of modules `{m_1, ..., m_N}`. (Note that `m_0` is a dummy element of the list, not a module.)

The ModuleManager contract must satisfy the following contract invariant, once initialized (after `setup`):
- `modules` represents the list of `(m_0, m_1, ..., m_N)` such that:
  - `N >= 0`
  - `m_i` is non-zero (for all `0 <= i <= N`)
  - `m_0 = 1`
  - all `m_i`'s are distinct (for `0 <= i <= N`)
  - `modules[m_i] = m_{i+1 mod N+1}` for `0 <= i <= N`
  - `modules[x]` = 0 for any `x` not in the list `(m_0, ..., m_N)`

Note that the set of modules could be empty, while the set of owners cannot.


### Function enableModule

[`enableModule`] is a public authorized function that adds a new module.

```
    function enableModule(Module module)
        public
        authorized
```

#### State update:

Suppose `modules` represents `(m_0, m_1, ..., m_N)` and the contract invariant holds before calling the function.

The function reverts if one of the following input conditions is not satisfied:
- The argument `module` should be a non-zero new module, i.e., `module =/= 0` and `module =/= m_i` for all `0 <= i <= N`.

NOTE:
The check `require(module != SENTINEL_OWNERS)` is logically redundant in the presence of `require(modules[address(module)] == address(0))` and the given contract invariant.

If the function succeeds, the post state will be:
- `modules` will represent `(m_0, module, m_1, ..., m_N)`.

#### Function visibility and modifiers:

The function should be invoked by the proxy account. Otherwise, it reverts.

```ini
[enableModule]
k: (#execute => #halt) ~> _
output: _ => _
callStack: _
this: #PROXY_ID
msg_sender: MSG_SENDER
callData: #abiCallData("enableModule", #address(MODULE))
callValue: 0
wordStack: .WordStack => _
localMem: .IMap => _
pc: 0 => _
gas: #gas(STARTGAS, 0, 0) => _
memoryUsed: 0 => _
refund: _ => _
coinbase: _ => _
proxy_storage:
    M1:IMap => M2:IMap
+requires:
    ; storage
    andBool select(M1, #hashedLocation({COMPILER}, {MODULES}, #SENTINEL)) ==Int INIT_SENTINEL
    andBool select(M1, #hashedLocation({COMPILER}, {MODULES}, MODULE))    ==Int INIT_MODULE
    ; Range
    andBool #rangeAddress(MSG_SENDER)
    andBool #rangeAddress(MODULE)
    andBool #rangeAddress(INIT_MODULE)
    andBool #rangeAddress(INIT_SENTINEL)
    ; Contract invariant

[enableModule-success]
statusCode: _ => EVMC_SUCCESS
log: _:List ( .List => ListItem(#abiEventLog(#PROXY_ID, "EnabledModule", #address(MODULE))) )
+requires:
    ; Requirements from code
    ; Module address cannot be null or sentinel.
    andBool MODULE =/=Int 0
    andBool MODULE =/=Int #SENTINEL
    ; Module cannot be added twice.
    andBool INIT_MODULE ==Int 0
    ; Property to verify
    andBool MSG_SENDER ==Int #PROXY_ID
    ; the hash2 lemma is not enough here, since the SENTINEL location is fully evaluated: 92458281274488595289803937127152923398167637295201432141969818930235769911599
    andBool #hashedLocation({COMPILER}, {MODULES}, MODULE) =/=Int #hashedLocation({COMPILER}, {MODULES}, #SENTINEL)
ensures:
    andBool select(M2, #hashedLocation({COMPILER}, {MODULES}, #SENTINEL)) ==Int MODULE
    andBool select(M2, #hashedLocation({COMPILER}, {MODULES}, MODULE))    ==Int INIT_SENTINEL
    andBool M1 ==IMap M2 except (
         SetItem(#hashedLocation({COMPILER}, {MODULES}, MODULE))
         SetItem(#hashedLocation({COMPILER}, {MODULES}, #SENTINEL))
         .Set)

[enableModule-failure]
statusCode: _ => EVMC_REVERT
log: _

[enableModule-failure-1]
+requires:
    andBool MSG_SENDER =/=Int #PROXY_ID

[enableModule-failure-2]
+requires:
    andBool MSG_SENDER ==Int #PROXY_ID
    andBool ( MODULE ==Int 0
       orBool MODULE ==Int #SENTINEL
       orBool INIT_MODULE =/=Int 0 )
```

### Function disableModule

[`disableModule`] is a public authorized function that removes the given module.

```
    function disableModule(Module prevModule, Module module)
        public
        authorized
```

#### State update:

Suppose `modules` represents `(m_0, m_1, ..., m_N)` and the contract invariant holds before calling the function.

The function reverts if one of the following input conditions is not satisfied:
- `N >= 1`
- There exists `0 <= k < N` such that `prevModule = m_k` and `module = m_{k+1}`.

NOTE:
The check `require(module != SENTINEL_OWNERS)` is necessary to ensure `k =/= N` and `N >= 1`.

If the function succeeds, the post state will be:
- `modules` will represent `(..., m_k, m_{k+2}, ...)` for `0 <= k < N`.

#### Function visibility and modifiers:

The function should be invoked by the proxy account. Otherwise, it reverts.

```ini
[disableModule]
k: (#execute => #halt) ~> _
output: _ => _
callStack: _
this: #PROXY_ID
msg_sender: MSG_SENDER
callData: #abiCallData("disableModule", (#address(PREV_MODULE), #address(MODULE)))
callValue: 0
wordStack: .WordStack => _
localMem: .IMap => _
pc: 0 => _
gas: #gas(STARTGAS, 0, 0) => _
memoryUsed: 0 => _
refund: _ => _
coinbase: _ => _
proxy_storage:
    M1:IMap => M2:IMap
+requires:
    ; storage
    andBool select(M1, #hashedLocation({COMPILER}, {MODULES}, MODULE))      ==Int INIT_MODULE
    andBool select(M1, #hashedLocation({COMPILER}, {MODULES}, PREV_MODULE)) ==Int INIT_PREV_MODULE
    ; Range
    andBool #rangeAddress(MSG_SENDER)
    andBool #rangeAddress(PREV_MODULE)
    andBool #rangeAddress(MODULE)
    andBool #rangeAddress(INIT_MODULE)
    andBool #rangeAddress(INIT_PREV_MODULE)
    ; Contract invariant

[disableModule-success]
statusCode: _ => EVMC_SUCCESS
log: _:List ( .List => ListItem(#abiEventLog(#PROXY_ID, "DisabledModule", #address(MODULE))) )
+requires:
    ; Requirements from code
    ; Validate module address and check that it corresponds to module index.
    andBool MODULE =/=Int 0
    andBool MODULE =/=Int #SENTINEL
    andBool INIT_PREV_MODULE ==Int MODULE
    ; Path condition
    andBool MODULE =/=Int PREV_MODULE  // implied from 'modules[prevModule] == module' and 'module != SENTINEL_MODULES'
    ; Property to verify
    andBool MSG_SENDER ==Int #PROXY_ID
ensures:
    andBool select(M2, #hashedLocation({COMPILER}, {MODULES}, MODULE))      ==Int 0
    andBool select(M2, #hashedLocation({COMPILER}, {MODULES}, PREV_MODULE)) ==Int INIT_MODULE
    andBool M1 ==IMap M2 except (
         SetItem(#hashedLocation({COMPILER}, {MODULES}, MODULE))
         SetItem(#hashedLocation({COMPILER}, {MODULES}, PREV_MODULE))
         .Set)

[disableModule-failure]
statusCode: _ => EVMC_REVERT
log: _

[disableModule-failure-1]
+requires:
    andBool MSG_SENDER =/=Int #PROXY_ID

[disableModule-failure-2]
+requires:
    andBool MSG_SENDER ==Int #PROXY_ID
    andBool ( MODULE ==Int 0
       orBool MODULE ==Int #SENTINEL
       orBool INIT_PREV_MODULE =/=Int MODULE )
```

### Function execTransactionFromModule

[`execTransactionFromModule`] is a public function that executes the given transaction.

```
    function execTransactionFromModule(address to, uint256 value, bytes memory data, Enum.Operation operation)
        public
        returns (bool success)
```

Here we consider only the case that `modules` denotes the empty set.
The case for a non-empty set of modules is out of the scope of the current engagement.

The function reverts if `msg.sender =/= 1` and `modules` denotes the empty set, i.e., `modules[x] = 0` for any `x =/= 1`, and `modules[1] = 1`.

```ini
[execTransactionFromModule]
k: (#execute => #halt) ~> _
output: _ => _
log: _
callStack: _
this: #PROXY_ID
msg_sender: MSG_SENDER
callData: #abiCallData("execTransactionFromModule", (
            #address(TO),
            #uint256(VALUE),
            #bytes(#buf(DATA_LEN, DATA)),
            #uint8(OPERATION)))
callValue: 0
wordStack: .WordStack => _
localMem: .IMap => _
pc: 0 => _
gas: #gas(STARTGAS, 0, 0) => _
memoryUsed: 0 => _
refund: _ => _
coinbase: _ => _
proxy_storage:
    M1:IMap => M2:IMap
+requires:
    ; storage
    andBool select(M1, #hashedLocation({COMPILER}, {MODULES}, MSG_SENDER)) ==Int INIT_MSG_SENDER
    ; Range
    andBool #rangeAddress(MSG_SENDER)
    andBool #rangeAddress(TO)
    andBool #rangeUInt(256, VALUE)
    andBool #rangeUInt(256, DATA_LEN)
    ; enum Enum.Operation, 3 possible values encoded to 0-2.
    andBool #range(0 <= OPERATION <= 2)
    andBool #rangeUInt(256, INIT_MSG_SENDER)
    ; Contract invariant

[execTransactionFromModule-failure]
statusCode: _ => EVMC_REVERT
output: _ => _
+requires:
    ; only added modules can execute the transaction
    andBool INIT_MSG_SENDER ==Int 0
```

## MasterCopy contract

### Function changeMasterCopy

[`changeMasterCopy`] is a public authorized function that updates `masterCopy`.

```
    function changeMasterCopy(address _masterCopy)
        public
        authorized
```

#### State update:

The function reverts if the argument `_masterCopy` is zero.

Otherwise, it updates `masterCopy` to `_masterCopy`.

#### Function visibility and modifiers:

The function should be invoked by the proxy account. Otherwise, it reverts.


```ini
[changeMasterCopy]
k: (#execute => #halt) ~> _
output: _ => _
log: _
callStack: _
this: #PROXY_ID
msg_sender: MSG_SENDER
callData: #abiCallData("changeMasterCopy", #address(NEW_MASTER_COPY))
callValue: 0
wordStack: .WordStack => _
localMem: .IMap => _
pc: 0 => _
gas: #gas(STARTGAS, 0, 0) => _
memoryUsed: 0 => _
refund: _ => _
coinbase: _ => _
proxy_storage:
    M1:IMap => M2:IMap
+requires:
    ; storage
    andBool select(M1, #hashedLocation({COMPILER}, {MASTER_COPY}, .IntList)) ==Int MASTER_COPY
    ; Range
    andBool #rangeAddress(MSG_SENDER)
    andBool #rangeAddress(MASTER_COPY)
    andBool #rangeAddress(NEW_MASTER_COPY)
    ; Contract invariant

[changeMasterCopy-success]
statusCode: _ => EVMC_SUCCESS
+requires:
    ; Path condition
    andBool NEW_MASTER_COPY =/=Int 0
    ; Property to verify
    andBool MSG_SENDER ==Int #PROXY_ID
ensures:
    andBool select(M2, #hashedLocation({COMPILER}, {MASTER_COPY}, .IntList)) ==Int NEW_MASTER_COPY
    andBool M1 ==IMap M2 except (
         SetItem(#hashedLocation({COMPILER}, {MASTER_COPY}, .IntList))
         .Set)

[changeMasterCopy-failure]
statusCode: _ => EVMC_REVERT

[changeMasterCopy-failure-1]
+requires:
    andBool MSG_SENDER =/=Int #PROXY_ID

[changeMasterCopy-failure-2]
+requires:
    andBool MSG_SENDER ==Int #PROXY_ID
    andBool NEW_MASTER_COPY ==Int 0
```

## Important constants

```ini
[pgm]
compiler: "Solidity"
safe_tx_typehash: "0x14d461bc7412367e924637b363c7bf29b8f47e2f84869f4426e5633d8af47b20"
```

### Storage layout

```ini
; address masterCopy
master_copy: 0
; mapping (address => address) internal modules
modules: 1
; mapping(address => address) internal owners
owners: 2
; uint256 ownerCount
ownercount: 3
; uint256 internal threshold
threshold: 4
; uint256 public nonce
nonce: 5
; bytes32 public domainSeparator
domain_separator: 6
; mapping(bytes32 => uint256) signedMessage
signed_message: 7
; mapping(address => mapping(bytes32 => uint256)) approvedHashes
approved_hashes: 8
```

### Runtime bytecode

```ini
master_copy_code: "0x608060405260043610610196576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680630a1028c4146101985780630d582f13146102745780630ec78d9e146102cf5780631db61b54146103d457806320c13b0b146103ff5780632f54bf6e146104f2578063468721a71461055b5780635ae6bd3714610672578063610b5925146106c1578063694e80c3146107125780636a7612021461074d5780637d832974146108d65780637de7edef1461094557806385a5affe1461099657806385e332cd14610a1c5780638cff635514610a73578063a0e67e2b14610aca578063a3f4df7e14610b36578063affed0e014610bc6578063b2494df314610bf1578063c0856ffc14610c5d578063c4ca3a9c14610c88578063ccafc38714610d59578063d4d9bdcd14610d84578063d8d11f7814610dbf578063e009cfde14610f3b578063e318b52b14610fac578063e75235b81461103d578063e86637db14611068578063f698da2514611249578063f8dc5dd914611274578063ffa1ad74146112ef575b005b3480156101a457600080fd5b5061025e600480360360208110156101bb57600080fd5b81019080803590602001906401000000008111156101d857600080fd5b8201836020820111156101ea57600080fd5b8035906020019184600183028401116401000000008311171561020c57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f82011690508083019250505050505050919291929050505061137f565b6040518082815260200191505060405180910390f35b34801561028057600080fd5b506102cd6004803603604081101561029757600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190803590602001909291905050506114f4565b005b3480156102db57600080fd5b506103d2600480360360808110156102f257600080fd5b810190808035906020019064010000000081111561030f57600080fd5b82018360208201111561032157600080fd5b8035906020019184602083028401116401000000008311171561034357600080fd5b909192939192939080359060200190929190803573ffffffffffffffffffffffffffffffffffffffff1690602001909291908035906020019064010000000081111561038e57600080fd5b8201836020820111156103a057600080fd5b803590602001918460018302840111640100000000831117156103c257600080fd5b9091929391929390505050611989565b005b3480156103e057600080fd5b506103e9611b23565b6040518082815260200191505060405180910390f35b34801561040b57600080fd5b506104d86004803603604081101561042257600080fd5b810190808035906020019064010000000081111561043f57600080fd5b82018360208201111561045157600080fd5b8035906020019184600183028401116401000000008311171561047357600080fd5b90919293919293908035906020019064010000000081111561049457600080fd5b8201836020820111156104a657600080fd5b803590602001918460018302840111640100000000831117156104c857600080fd5b9091929391929390505050611b4a565b604051808215151515815260200191505060405180910390f35b3480156104fe57600080fd5b506105416004803603602081101561051557600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190505050611c68565b604051808215151515815260200191505060405180910390f35b34801561056757600080fd5b506106586004803603608081101561057e57600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff16906020019092919080359060200190929190803590602001906401000000008111156105c557600080fd5b8201836020820111156105d757600080fd5b803590602001918460018302840111640100000000831117156105f957600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f820116905080830192505050505050509192919290803560ff169060200190929190505050611d00565b604051808215151515815260200191505060405180910390f35b34801561067e57600080fd5b506106ab6004803603602081101561069557600080fd5b8101908080359060200190929190505050611e42565b6040518082815260200191505060405180910390f35b3480156106cd57600080fd5b50610710600480360360208110156106e457600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190505050611e5a565b005b34801561071e57600080fd5b5061074b6004803603602081101561073557600080fd5b81019080803590602001909291905050506122c7565b005b34801561075957600080fd5b506108bc600480360361014081101561077157600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff16906020019092919080359060200190929190803590602001906401000000008111156107b857600080fd5b8201836020820111156107ca57600080fd5b803590602001918460018302840111640100000000831117156107ec57600080fd5b9091929391929390803560ff169060200190929190803590602001909291908035906020019092919080359060200190929190803573ffffffffffffffffffffffffffffffffffffffff169060200190929190803573ffffffffffffffffffffffffffffffffffffffff1690602001909291908035906020019064010000000081111561087857600080fd5b82018360208201111561088a57600080fd5b803590602001918460018302840111640100000000831117156108ac57600080fd5b9091929391929390505050612512565b604051808215151515815260200191505060405180910390f35b3480156108e257600080fd5b5061092f600480360360408110156108f957600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190803590602001909291905050506127cd565b6040518082815260200191505060405180910390f35b34801561095157600080fd5b506109946004803603602081101561096857600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff1690602001909291905050506127f2565b005b3480156109a257600080fd5b50610a1a600480360360208110156109b957600080fd5b81019080803590602001906401000000008111156109d657600080fd5b8201836020820111156109e857600080fd5b80359060200191846001830284011164010000000083111715610a0a57600080fd5b90919293919293905050506129c9565b005b348015610a2857600080fd5b50610a31612afb565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b348015610a7f57600080fd5b50610a88612b00565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b348015610ad657600080fd5b50610adf612b05565b6040518080602001828103825283818151815260200191508051906020019060200280838360005b83811015610b22578082015181840152602081019050610b07565b505050509050019250505060405180910390f35b348015610b4257600080fd5b50610b4b612ca0565b6040518080602001828103825283818151815260200191508051906020019080838360005b83811015610b8b578082015181840152602081019050610b70565b50505050905090810190601f168015610bb85780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b348015610bd257600080fd5b50610bdb612cd9565b6040518082815260200191505060405180910390f35b348015610bfd57600080fd5b50610c06612cdf565b6040518080602001828103825283818151815260200191508051906020019060200280838360005b83811015610c49578082015181840152602081019050610c2e565b505050509050019250505060405180910390f35b348015610c6957600080fd5b50610c72612f86565b6040518082815260200191505060405180910390f35b348015610c9457600080fd5b50610d4360048036036080811015610cab57600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff1690602001909291908035906020019092919080359060200190640100000000811115610cf257600080fd5b820183602082011115610d0457600080fd5b80359060200191846001830284011164010000000083111715610d2657600080fd5b9091929391929390803560ff169060200190929190505050612fad565b6040518082815260200191505060405180910390f35b348015610d6557600080fd5b50610d6e6131a1565b6040518082815260200191505060405180910390f35b348015610d9057600080fd5b50610dbd60048036036020811015610da757600080fd5b81019080803590602001909291905050506131c8565b005b348015610dcb57600080fd5b50610f256004803603610140811015610de357600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff1690602001909291908035906020019092919080359060200190640100000000811115610e2a57600080fd5b820183602082011115610e3c57600080fd5b80359060200191846001830284011164010000000083111715610e5e57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f820116905080830192505050505050509192919290803560ff169060200190929190803590602001909291908035906020019092919080359060200190929190803573ffffffffffffffffffffffffffffffffffffffff169060200190929190803573ffffffffffffffffffffffffffffffffffffffff16906020019092919080359060200190929190505050613325565b6040518082815260200191505060405180910390f35b348015610f4757600080fd5b50610faa60048036036040811015610f5e57600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190803573ffffffffffffffffffffffffffffffffffffffff169060200190929190505050613350565b005b348015610fb857600080fd5b5061103b60048036036060811015610fcf57600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190803573ffffffffffffffffffffffffffffffffffffffff169060200190929190803573ffffffffffffffffffffffffffffffffffffffff1690602001909291905050506137e2565b005b34801561104957600080fd5b50611052613f37565b6040518082815260200191505060405180910390f35b34801561107457600080fd5b506111ce600480360361014081101561108c57600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff16906020019092919080359060200190929190803590602001906401000000008111156110d357600080fd5b8201836020820111156110e557600080fd5b8035906020019184600183028401116401000000008311171561110757600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f820116905080830192505050505050509192919290803560ff169060200190929190803590602001909291908035906020019092919080359060200190929190803573ffffffffffffffffffffffffffffffffffffffff169060200190929190803573ffffffffffffffffffffffffffffffffffffffff16906020019092919080359060200190929190505050613f41565b6040518080602001828103825283818151815260200191508051906020019080838360005b8381101561120e5780820151818401526020810190506111f3565b50505050905090810190601f16801561123b5780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b34801561125557600080fd5b5061125e614193565b6040518082815260200191505060405180910390f35b34801561128057600080fd5b506112ed6004803603606081101561129757600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190803573ffffffffffffffffffffffffffffffffffffffff16906020019092919080359060200190929190505050614199565b005b3480156112fb57600080fd5b506113046146f7565b6040518080602001828103825283818151815260200191508051906020019080838360005b83811015611344578082015181840152602081019050611329565b50505050905090810190601f1680156113715780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b6000807f60b3cbf8b4a223d68d641b3b6ddf9a298e7f33710cf3d3a9d1146b5a6150fbca6001028380519060200120604051602001808381526020018281526020019250505060405160208183030381529060405280519060200120905060197f01000000000000000000000000000000000000000000000000000000000000000260017f0100000000000000000000000000000000000000000000000000000000000000026006548360405160200180857effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff19167effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff19168152600101847effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff19167effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916815260010183815260200182815260200194505050505060405160208183030381529060405280519060200120915050919050565b3073ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff161415156115bd576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252602c8152602001807f4d6574686f642063616e206f6e6c792062652063616c6c65642066726f6d207481526020017f68697320636f6e7472616374000000000000000000000000000000000000000081525060400191505060405180910390fd5b600073ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff16141580156116275750600173ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff1614155b151561169b576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252601e8152602001807f496e76616c6964206f776e657220616464726573732070726f7669646564000081525060200191505060405180910390fd5b600073ffffffffffffffffffffffffffffffffffffffff16600260008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1614151561179e576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252601b8152602001807f4164647265737320697320616c726561647920616e206f776e6572000000000081525060200191505060405180910390fd5b60026000600173ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff16600260008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055508160026000600173ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055506003600081548092919060010191905055507f9465fa0c962cc76958e6373a993326400c1c94f8be2fe3a952adfa7f60b2ea2682604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390a18060045414151561198557611984816122c7565b5b5050565b6000600102600654141515611a06576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252601d8152602001807f446f6d61696e20536570617261746f7220616c7265616479207365742100000081525060200191505060405180910390fd5b7f035aff83d86937d35b32e04f0ddc6ff469290eef2f1b692d8a815c89404d474960010230604051602001808381526020018273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019250505060405160208183030381529060405280519060200120600681905550611b1b868680806020026020016040519081016040528093929190818152602001838360200280828437600081840152601f19601f82011690508083019250505050505050858585858080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f82011690508083019250505050505050614730565b505050505050565b7f035aff83d86937d35b32e04f0ddc6ff469290eef2f1b692d8a815c89404d474960010281565b600080611b9a86868080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f8201169050808301925050505050505061137f565b90506000848490501415611bc7576000600760008381526020019081526020016000205414159150611c5f565b611c5c8187878080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f8201169050808301925050505050505086868080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f82011690508083019250505050505050600061474a565b91505b50949350505050565b60008073ffffffffffffffffffffffffffffffffffffffff16600260008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1614159050919050565b60008073ffffffffffffffffffffffffffffffffffffffff16600160003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1614151515611e2b576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260308152602001807f4d6574686f642063616e206f6e6c792062652063616c6c65642066726f6d206181526020017f6e20656e61626c6564206d6f64756c650000000000000000000000000000000081525060400191505060405180910390fd5b611e38858585855a614bfe565b9050949350505050565b60076020528060005260406000206000915090505481565b3073ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff16141515611f23576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252602c8152602001807f4d6574686f642063616e206f6e6c792062652063616c6c65642066726f6d207481526020017f68697320636f6e7472616374000000000000000000000000000000000000000081525060400191505060405180910390fd5b600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff1614158015611f8d5750600173ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff1614155b1515612001576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252601f8152602001807f496e76616c6964206d6f64756c6520616464726573732070726f76696465640081525060200191505060405180910390fd5b600073ffffffffffffffffffffffffffffffffffffffff16600160008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16141515612104576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252601d8152602001807f4d6f64756c652068617320616c7265616479206265656e20616464656400000081525060200191505060405180910390fd5b60016000600173ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff16600160008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055508060016000600173ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055507fecdf3a3effea5783a3c4c2140e677577666428d44ed9d474a0b3a4c9943f844081604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390a150565b3073ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff16141515612390576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252602c8152602001807f4d6574686f642063616e206f6e6c792062652063616c6c65642066726f6d207481526020017f68697320636f6e7472616374000000000000000000000000000000000000000081525060400191505060405180910390fd5b6003548111151515612430576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260238152602001807f5468726573686f6c642063616e6e6f7420657863656564206f776e657220636f81526020017f756e74000000000000000000000000000000000000000000000000000000000081525060400191505060405180910390fd5b600181101515156124cf576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260248152602001807f5468726573686f6c64206e6565647320746f206265206772656174657220746881526020017f616e20300000000000000000000000000000000000000000000000000000000081525060400191505060405180910390fd5b806004819055507f610f7ff2b304ae8903c3de74c60c6ab1f7d6226b3f52c5161905bb5ad4039c936004546040518082815260200191505060405180910390a150565b6000805a905060606125728f8f8f8f8080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f820116905080830192505050505050508e8e8e8e8e8e600554613f41565b90506125cc81805190602001208287878080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f82011690508083019250505050505050600161474a565b1515612640576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252601b8152602001807f496e76616c6964207369676e6174757265732070726f7669646564000000000081525060200191505060405180910390fd5b600560008154809291906001019190505550895a101515156126f0576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252602a8152602001807f4e6f7420656e6f7567682067617320746f20657865637574652073616665207481526020017f72616e73616374696f6e0000000000000000000000000000000000000000000081525060400191505060405180910390fd5b61275c8f8f8f8f8080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f820116905080830192505050505050508e60008f14801561274b575060008d145b612755578e612757565b5a5b614bfe565b92508215156127a4577fabfd711ecdd15ae3a6b3ad16ff2e9d81aec026a39d16725ee164be4fbf857a7c81805190602001206040518082815260200191505060405180910390a15b60008811156127bb576127ba828a8a8a8a614d11565b5b50509c9b505050505050505050505050565b6008602052816000526040600020602052806000526040600020600091509150505481565b3073ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff161415156128bb576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252602c8152602001807f4d6574686f642063616e206f6e6c792062652063616c6c65642066726f6d207481526020017f68697320636f6e7472616374000000000000000000000000000000000000000081525060400191505060405180910390fd5b600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff1614151515612986576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260248152602001807f496e76616c6964206d617374657220636f707920616464726573732070726f7681526020017f696465640000000000000000000000000000000000000000000000000000000081525060400191505060405180910390fd5b806000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff16021790555050565b3073ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff16141515612a92576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252602c8152602001807f4d6574686f642063616e206f6e6c792062652063616c6c65642066726f6d207481526020017f68697320636f6e7472616374000000000000000000000000000000000000000081525060400191505060405180910390fd5b600160076000612ae585858080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f8201169050808301925050505050505061137f565b8152602001908152602001600020819055505050565b600181565b600181565b606080600354604051908082528060200260200182016040528015612b395781602001602082028038833980820191505090505b5090506000809050600060026000600173ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1690505b600173ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff16141515612c9757808383815181101515612bec57fe5b9060200190602002019073ffffffffffffffffffffffffffffffffffffffff16908173ffffffffffffffffffffffffffffffffffffffff1681525050600260008273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1690508180600101925050612ba7565b82935050505090565b6040805190810160405280600b81526020017f476e6f736973205361666500000000000000000000000000000000000000000081525081565b60055481565b60606000809050600060016000600173ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1690505b600173ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff16141515612df157600160008273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1690508180600101925050612d4c565b606082604051908082528060200260200182016040528015612e225781602001602082028038833980820191505090505b5090506000925060016000600173ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1691505b600173ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff16141515612f7d57818184815181101515612ed257fe5b9060200190602002019073ffffffffffffffffffffffffffffffffffffffff16908173ffffffffffffffffffffffffffffffffffffffff1681525050600160008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1691508280600101935050612e8d565b80935050505090565b7f60b3cbf8b4a223d68d641b3b6ddf9a298e7f33710cf3d3a9d1146b5a6150fbca60010281565b60003073ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff16141515613078576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252602c8152602001807f4d6574686f642063616e206f6e6c792062652063616c6c65642066726f6d207481526020017f68697320636f6e7472616374000000000000000000000000000000000000000081525060400191505060405180910390fd5b60005a90506130ce878787878080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f82011690508083019250505050505050865a614bfe565b15156130d957600080fd5b60005a8203905080604051602001808281526020019150506040516020818303038152906040526040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825283818151815260200191508051906020019080838360005b8381101561316657808201518184015260208101905061314b565b50505050905090810190601f1680156131935780820380516001836020036101000a031916815260200191505b509250505060405180910390fd5b7f14d461bc7412367e924637b363c7bf29b8f47e2f84869f4426e5633d8af47b2060010281565b600073ffffffffffffffffffffffffffffffffffffffff16600260003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16141515156132cc576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252601e8152602001807f4f6e6c79206f776e6572732063616e20617070726f766520612068617368000081525060200191505060405180910390fd5b6001600860003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008381526020019081526020016000208190555050565b60006133398b8b8b8b8b8b8b8b8b8b613f41565b8051906020012090509a9950505050505050505050565b3073ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff16141515613419576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252602c8152602001807f4d6574686f642063616e206f6e6c792062652063616c6c65642066726f6d207481526020017f68697320636f6e7472616374000000000000000000000000000000000000000081525060400191505060405180910390fd5b600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff16141580156134835750600173ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff1614155b15156134f7576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252601f8152602001807f496e76616c6964206d6f64756c6520616464726573732070726f76696465640081525060200191505060405180910390fd5b8073ffffffffffffffffffffffffffffffffffffffff16600160008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1614151561361f576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260288152602001807f496e76616c696420707265764d6f64756c652c206d6f64756c6520706169722081526020017f70726f766964656400000000000000000000000000000000000000000000000081525060400191505060405180910390fd5b600160008273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff16600160008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055506000600160008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055507faab4fa2b463f581b2b32cb3b7e3b704b9ce37cc209b5fb4d77e593ace405427681604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390a15050565b3073ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff161415156138ab576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252602c8152602001807f4d6574686f642063616e206f6e6c792062652063616c6c65642066726f6d207481526020017f68697320636f6e7472616374000000000000000000000000000000000000000081525060400191505060405180910390fd5b600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff16141580156139155750600173ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff1614155b1515613989576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252601e8152602001807f496e76616c6964206f776e657220616464726573732070726f7669646564000081525060200191505060405180910390fd5b600073ffffffffffffffffffffffffffffffffffffffff16600260008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16141515613a8c576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252601b8152602001807f4164647265737320697320616c726561647920616e206f776e6572000000000081525060200191505060405180910390fd5b600073ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff1614158015613af65750600173ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff1614155b1515613b6a576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252601e8152602001807f496e76616c6964206f776e657220616464726573732070726f7669646564000081525060200191505060405180910390fd5b8173ffffffffffffffffffffffffffffffffffffffff16600260008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16141515613c92576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260268152602001807f496e76616c696420707265764f776e65722c206f776e6572207061697220707281526020017f6f7669646564000000000000000000000000000000000000000000000000000081525060400191505060405180910390fd5b600260008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff16600260008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff16021790555080600260008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055506000600260008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055507ff8d49fc529812e9a7c5c50e69c20f0dccc0db8fa95c98bc58cc9a4f1c1299eaf82604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390a17f9465fa0c962cc76958e6373a993326400c1c94f8be2fe3a952adfa7f60b2ea2681604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390a1505050565b6000600454905090565b606060007f14d461bc7412367e924637b363c7bf29b8f47e2f84869f4426e5633d8af47b206001028c8c8c805190602001208c8c8c8c8c8c8c604051602001808c81526020018b73ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020018a8152602001898152602001886002811115613fd157fe5b60ff1681526020018781526020018681526020018581526020018473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020018373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020018281526020019b50505050505050505050505060405160208183030381529060405280519060200120905060197f01000000000000000000000000000000000000000000000000000000000000000260017f0100000000000000000000000000000000000000000000000000000000000000026006548360405160200180857effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff19167effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff19168152600101847effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff19167effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff191681526001018381526020018281526020019450505050506040516020818303038152906040529150509a9950505050505050505050565b60065481565b3073ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff16141515614262576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252602c8152602001807f4d6574686f642063616e206f6e6c792062652063616c6c65642066726f6d207481526020017f68697320636f6e7472616374000000000000000000000000000000000000000081525060400191505060405180910390fd5b8060016003540310151515614305576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260358152602001807f4e6577206f776e657220636f756e74206e6565647320746f206265206c61726781526020017f6572207468616e206e6577207468726573686f6c64000000000000000000000081525060400191505060405180910390fd5b600073ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff161415801561436f5750600173ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff1614155b15156143e3576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252601e8152602001807f496e76616c6964206f776e657220616464726573732070726f7669646564000081525060200191505060405180910390fd5b8173ffffffffffffffffffffffffffffffffffffffff16600260008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1614151561450b576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260268152602001807f496e76616c696420707265764f776e65722c206f776e6572207061697220707281526020017f6f7669646564000000000000000000000000000000000000000000000000000081525060400191505060405180910390fd5b600260008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff16600260008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055506000600260008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff160217905550600360008154809291906001900391905055507ff8d49fc529812e9a7c5c50e69c20f0dccc0db8fa95c98bc58cc9a4f1c1299eaf82604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390a1806004541415156146f2576146f1816122c7565b5b505050565b6040805190810160405280600581526020017f302e312e3000000000000000000000000000000000000000000000000000000081525081565b61473a8484614f43565b6147448282615430565b50505050565b6000604160045402835110156147635760009050614bf6565b600080905060008060008060008090505b600454811015614beb576147888982615693565b80945081955082965050505060008460ff161415614949578260019004945060606020838b010190508573ffffffffffffffffffffffffffffffffffffffff166320c13b0b8c836040518363ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401808060200180602001838103835285818151815260200191508051906020019080838360005b8381101561483e578082015181840152602081019050614823565b50505050905090810190601f16801561486b5780820380516001836020036101000a031916815260200191505b50838103825284818151815260200191508051906020019080838360005b838110156148a4578082015181840152602081019050614889565b50505050905090810190601f1680156148d15780820380516001836020036101000a031916815260200191505b50945050505050602060405180830381600087803b1580156148f257600080fd5b505af1158015614906573d6000803e3d6000fd5b505050506040513d602081101561491c57600080fd5b81019080805190602001909291905050501515614943576000975050505050505050614bf6565b50614b01565b60018460ff161415614a9657826001900494508473ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff16141580156149e857506000600860008773ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008d815260200190815260200160002054145b156149fc5760009650505050505050614bf6565b878015614a3557508473ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff1614155b15614a91576000600860008773ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008d8152602001908152602001600020819055505b614b00565b60018b85858560405160008152602001604052604051808581526020018460ff1660ff1681526020018381526020018281526020019450505050506020604051602081039080840390855afa158015614af3573d6000803e3d6000fd5b5050506020604051035194505b5b8573ffffffffffffffffffffffffffffffffffffffff168573ffffffffffffffffffffffffffffffffffffffff16111580614bc75750600073ffffffffffffffffffffffffffffffffffffffff16600260008773ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16145b15614bdb5760009650505050505050614bf6565b8495508080600101915050614774565b600196505050505050505b949350505050565b6000806002811115614c0c57fe5b836002811115614c1857fe5b1415614c3157614c2a868686856156c2565b9050614d08565b60016002811115614c3e57fe5b836002811115614c4a57fe5b1415614c6257614c5b8685846156db565b9050614d07565b6000614c6d856156f2565b9050600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff16141591507f4db17dd5e4732fb6da34a148104a592783ca119a1e7bb8829eba6cbadef0b51181604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390a1505b5b95945050505050565b6000614d4a84614d3c87614d2e5a8b61570490919063ffffffff16565b61572690919063ffffffff16565b61574790919063ffffffff16565b905060008073ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff1614614d875782614d89565b325b9050600073ffffffffffffffffffffffffffffffffffffffff168473ffffffffffffffffffffffffffffffffffffffff161415614e94578073ffffffffffffffffffffffffffffffffffffffff166108fc839081150290604051600060405180830381858888f193505050501515614e8f576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260228152602001807f436f756c64206e6f74207061792067617320636f73747320776974682065746881526020017f657200000000000000000000000000000000000000000000000000000000000081525060400191505060405180910390fd5b614f3a565b614e9f848284615785565b1515614f39576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260228152602001807f436f756c64206e6f74207061792067617320636f737473207769746820746f6b81526020017f656e00000000000000000000000000000000000000000000000000000000000081525060400191505060405180910390fd5b5b50505050505050565b6000600454141515614fbd576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252601e8152602001807f4f776e657273206861766520616c7265616479206265656e207365747570000081525060200191505060405180910390fd5b8151811115151561505c576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260238152602001807f5468726573686f6c642063616e6e6f7420657863656564206f776e657220636f81526020017f756e74000000000000000000000000000000000000000000000000000000000081525060400191505060405180910390fd5b600181101515156150fb576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260248152602001807f5468726573686f6c64206e6565647320746f206265206772656174657220746881526020017f616e20300000000000000000000000000000000000000000000000000000000081525060400191505060405180910390fd5b60006001905060008090505b835181101561539c576000848281518110151561512057fe5b906020019060200201519050600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff16141580156151965750600173ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff1614155b151561520a576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252601e8152602001807f496e76616c6964206f776e657220616464726573732070726f7669646564000081525060200191505060405180910390fd5b600073ffffffffffffffffffffffffffffffffffffffff16600260008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1614151561530d576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260208152602001807f4475706c6963617465206f776e657220616464726573732070726f766964656481525060200191505060405180910390fd5b80600260008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff160217905550809250508080600101915050615107565b506001600260008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff160217905550825160038190555081600481905550505050565b600073ffffffffffffffffffffffffffffffffffffffff1660016000600173ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1614151561555a576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260258152602001807f4d6f64756c6573206861766520616c7265616479206265656e20696e6974696181526020017f6c697a656400000000000000000000000000000000000000000000000000000081525060400191505060405180910390fd5b6001806000600173ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff160217905550600073ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff1614151561568f5761561a82825a6156db565b151561568e576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252601f8152602001807f436f756c64206e6f742066696e69736820696e697469616c697a6174696f6e0081525060200191505060405180910390fd5b5b5050565b60008060008360410260208101860151925060408101860151915060ff60418201870151169350509250925092565b6000806000845160208601878987f19050949350505050565b60008060008451602086018786f490509392505050565b60008151602083016000f09050919050565b600082821115151561571557600080fd5b600082840390508091505092915050565b600080828401905083811015151561573d57600080fd5b8091505092915050565b60008083141561575a576000905061577f565b6000828402905082848281151561576d57fe5b0414151561577a57600080fd5b809150505b92915050565b600060608383604051602401808373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001828152602001925050506040516020818303038152906040527fa9059cbb000000000000000000000000000000000000000000000000000000007bffffffffffffffffffffffffffffffffffffffffffffffffffffffff19166020820180517bffffffffffffffffffffffffffffffffffffffffffffffffffffffff838183161783525050505090506000808251602084016000896127105a03f16040513d6000823e3d6000811461588157602081146158895760009450615893565b829450615893565b8151158315171594505b50505050939250505056fea165627a7a7230582064e96a402388d815557c42c895e326e30e38037c7a14938e1d44aa7d01c0cbb00029"
proxy_code: "0x60806040526004361061004c576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680634555d5c91461008b5780635c60da1b146100b6575b73ffffffffffffffffffffffffffffffffffffffff600054163660008037600080366000845af43d6000803e6000811415610086573d6000fd5b3d6000f35b34801561009757600080fd5b506100a061010d565b6040518082815260200191505060405180910390f35b3480156100c257600080fd5b506100cb610116565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b60006002905090565b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1690509056fea165627a7a723058201cddd95839fb6a2721e9db6df2726cacc48f77a2b18ba97008f236afad1ada7f0029"
```

[v0.1.0]: <https://github.com/gnosis/safe-contracts/releases/tag/v0.1.0>
[fii]: <https://github.com/runtimeverification/verified-smart-contracts/blob/a3ca2bcbc152cd0b597669f6d3ac067fab363e33/gnosis/verification.k#L346-L421>
[resources]: </README.md#resources>
[eDSL]: </resources/edsl.md>

[`signatureSplit`]: <https://github.com/gnosis/safe-contracts/blob/v0.1.0/contracts/common/SignatureDecoder.sol#L32>
[`encodeTransactionData`]: <https://github.com/gnosis/safe-contracts/blob/v0.1.0/contracts/GnosisSafe.sol#L284>
[`getTransactionHash`]: <https://github.com/gnosis/safe-contracts/blob/v0.1.0/contracts/GnosisSafe.sol#L318>
[`handlePayment`]: <https://github.com/gnosis/safe-contracts/blob/v0.1.0/contracts/GnosisSafe.sol#L106>
[`checkSignatures`]: <https://github.com/gnosis/safe-contracts/blob/v0.1.0/contracts/GnosisSafe.sol#L134>
[`execTransaction`]: <https://github.com/gnosis/safe-contracts/blob/v0.1.0/contracts/GnosisSafe.sol#L69>
[`addOwnerWithThreshold`]: <https://github.com/gnosis/safe-contracts/blob/v0.1.0/contracts/base/OwnerManager.sol#L52>
[`removeOwner`]: <https://github.com/gnosis/safe-contracts/blob/v0.1.0/contracts/base/OwnerManager.sol#L74>
[`swapOwner`]: <https://github.com/gnosis/safe-contracts/blob/v0.1.0/contracts/base/OwnerManager.sol#L97>
[`enableModule`]: <https://github.com/gnosis/safe-contracts/blob/v0.1.0/contracts/base/ModuleManager.sol#L33>
[`disableModule`]: <https://github.com/gnosis/safe-contracts/blob/v0.1.0/contracts/base/ModuleManager.sol#L50>
[`execTransactionFromModule`]: <https://github.com/gnosis/safe-contracts/blob/v0.1.0/contracts/base/ModuleManager.sol#L67>
[`changeMasterCopy`]: <https://github.com/gnosis/safe-contracts/blob/v0.1.0/contracts/common/MasterCopy.sol#L14>

[line 115]: <https://github.com/gnosis/safe-contracts/blob/v0.1.0/contracts/GnosisSafe.sol#L115>

