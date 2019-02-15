pragma solidity ^0.5.0;

contract SimpleStorage {
    uint storedData;

    function set(uint x) public {
        storedData = x;
    }

    function increment(uint x) public {
        storedData += x;
    }

    function get() public view returns (uint) {
        return storedData;
    }
}
// call some function in contract 0x......
// 1. "set(uint)" -> keccak256 -> 256bit (32byte) integer -> take first 4 bytes
// 2. argument: uint x -> 32 bytes
// -> [ 4 bytes sig ] [ 32 bytes x ]

// storage is not byte addressable: not like memory, index for each WORD(32 bytes)

// 2^256 slots (0 ~ 2^256 -1), 32bytes each
// storedData: 0
// asdf: 1
// 2, 3, 4
//
// contract:
// - function signature table
// - function header: sanity check, prepare args
// - function footer: return value
// - function body
//
// external call: sig table -> header -> body -> footer
// internal call: prepare args -> jump into body -> jump back
