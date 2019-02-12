# solc 0.5.0

https://github.com/ethereum/solidity/releases/tag/v0.5.0

## Compile options

* `--asm`
* `--bin`, `--bin-runtime`
* `--hashes`

## getting opcodes

```k
module NAME-OPCODE
  imports ETHEREUM-SIMULATION
  rule
    <k> #asMapOpCodes(#dasmOpCodes(#parseByteStack("0x..."), BYZANTIUM)) =>  _ </k>
endmodule
```

```
kprove -v -d <evm-semantics/.build/java> name-opcode.k --log --log-cells "(k)"
```

# Intro to EVM bytecode: `SimpleStorage.sol`

## Layout of EVM bytecode

* Contracts
may ignore super-contracts section, as all of the codes are already in the sub-contract section

* Constructor

* Function table: `calldataload`, 4 byte sig (`--hashes`)

## useful features of `--asm` output

* comments
* tags, mapping with PC
* some syntatic sugars, e.g. no `push`, `mload(0x40)`

## Running a function: `set`

* check function sig
  * encoding of calldata: `[4 byte sig][32 byte uint x]`
* check `callvalue`,
* check calldata (args)
* push args and return loc, jump to body

## stack ops

* draw the stack


# EVM bytecode details: `Coin.sol`

## Inheritance

## fallback

## External & internal functions

## Storage

* 2^256 slots, 256bits for each.
* slot calculation

## Some redundancies

## array

## Memory

* not slot. byte addressable
* no `malloc`, `free`, ...
* NEXT_LOC: mload(0x40)

## ~~packing~~

# More KEVM semantics

## `#call`

## More internal ops

# writing lemmas

