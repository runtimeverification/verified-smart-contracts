pragma solidity ^0.4.0;

import "./ECRecovery.sol";
import "./ByteUtils.sol";


/**
 * @title Merkle
 * @dev Library for working with Merkle trees.
 */
library Merkle {
    /*
     * Storage
     */

    using ByteUtils for bytes;


    /*
     * Internal functions
     */

    /**
     * @dev Checks that a leaf hash is contained in a root hash.
     * @param leaf Leaf hash to verify.
     * @param index Position of the leaf hash in the Merkle tree.
     * @param rootHash Root of the Merkle tree.
     * @param proof A Merkle proof demonstrating membership of the leaf hash.
     * @return True of the leaf hash is in the Merkle tree. False otherwise.
    */
    function checkMembership(bytes32 leaf, uint256 index, bytes32 rootHash, bytes proof)
        internal
        pure
        returns (bool)
    {
        require(proof.length % 32 == 0);

        bytes32 proofElement;
        bytes32 computedHash = leaf;
        uint256 j = index;
        for (uint256 i = 32; i <= proof.length; i += 32) {
            assembly {
                proofElement := mload(add(proof, i))
            }
            if (j % 2 == 0) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
            j = j / 2;
        }

        return computedHash == rootHash;
    }
}
