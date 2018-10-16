pragma solidity ^0.4.0;


/**
 * @title ByteUtils
 * @dev Utilties for working with bytes.
 */
library ByteUtils {
    /*
     * Internal functions
     */

    /**
     * @dev Slices off bytes from a byte string.
     * @param _bytes Byte string to slice.
     * @param _start Starting index of the slice.
     * @param _length Length of the slice.
     * @return The slice of the byte string.
     */
    function slice(bytes _bytes, uint _start, uint _length)
        internal
        pure
        returns (bytes)
    {
        require(_bytes.length >= (_start + _length));

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                tempBytes := mload(0x40)

                let lengthmod := and(_length, 31)

                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }
}
