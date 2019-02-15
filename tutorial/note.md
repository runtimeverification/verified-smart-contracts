# solc 0.5.0

https://github.com/ethereum/solidity/releases/tag/v0.5.0

## Compile options

* `--asm`
* `--bin`, `--bin-runtime`

bin-runtime:                                                                 608060405260043610610057576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806360fe47b11461005c5780636d4ce63c146100975780637cf5dab0146100c2575b600080fd5b34801561006857600080fd5b506100956004803603602081101561007f57600080fd5b81019080803590602001909291905050506100fd565b005b3480156100a357600080fd5b506100ac610107565b6040518082815260200191505060405180910390f35b3480156100ce57600080fd5b506100fb600480360360208110156100e557600080fd5b8101908080359060200190929190505050610110565b005b8060008190555050565b60008054905090565b8060008082825401925050819055505056fea165627a7a72305820e30770ef5b3fb7eeee92c4394717956ee394de33dbf703938cc833a35582f1cc0029
bin :        608060405234801561001057600080fd5b5061014e806100206000396000f3fe608060405260043610610057576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806360fe47b11461005c5780636d4ce63c146100975780637cf5dab0146100c2575b600080fd5b34801561006857600080fd5b506100956004803603602081101561007f57600080fd5b81019080803590602001909291905050506100fd565b005b3480156100a357600080fd5b506100ac610107565b6040518082815260200191505060405180910390f35b3480156100ce57600080fd5b506100fb600480360360208110156100e557600080fd5b8101908080359060200190929190505050610110565b005b8060008190555050565b60008054905090565b8060008082825401925050819055505056fea165627a7a72305820e30770ef5b3fb7eeee92c4394717956ee394de33dbf703938cc833a35582f1cc0029
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

# EVM bytecode details: `Coin.sol`

## Inheritance

## public variable

## fallback

## array

`set(123)`
```
     _ : _ : _ : _ :
 0|  #buf ( 32 , 123 )
```

f(uint[] a, uint[] b)
cd[4:36] = 64
cd[36:68] = 64 + size of a

```
     _ : _ : _ : _ :
 0|  #buf ( 32 , 64 )
32|  #buf ( 32 , 64 + (length of a)*32 + 32 )
64|  #buf ( 32 , length )
96|  #buf ( 32 , first elem of a )
..|  #buf ( 32 , second elem of a )
....
```

`addOwners([A ,B])`

```
   0|108 : 70 : 162 : 197 :
 0+4|  #buf ( 32 , 32 ) ++
32+4|  #buf ( 32 , 2 ) ++
64+4|  #buf ( 32 , A ) ++
96+4|  #buf ( 32 , B )

2 * 32

0   4                    36  68
|sig|head1(offset to arr)|len| ......|
    0                    32  64
```

https://solidity.readthedocs.io/en/develop/abi-spec.html, `#abiCallData`

exercise: `setupOwners`, `getOwners`

## Memory

0x40

## External & internal functions

`addOwners`, SafeMath ...

## maps

`isOwner`

`#hashedLocation`

exercise: `mint`

## call, transfer, send

`withdrawEther`

exercise: function with calldata

## packing

## event

`#abiEventLog`

# More KEVM semantics

