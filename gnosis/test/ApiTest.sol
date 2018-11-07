pragma solidity 0.4.24;


/// @title Enum - Collection of enums
/// @author Richard Meissner - <richard@gnosis.pm>
contract ApiTest {
    enum Operation {
        Call,
        DelegateCall,
        Create
    }

    bytes32 public constant SAFE_TX_TYPEHASH = 0x14d461bc7412367e924637b363c7bf29b8f47e2f84869f4426e5633d8af47b20;
    bytes32 public domainSeparator;

    //same set of arguments as encodeTransactionData
    function testAbiEncodeAndKeccak(
        address to,
        uint256 value,
        bytes data,
        Operation operation,
        uint256 safeTxGas,
        uint256 dataGas,
        uint256 gasPrice,
        address gasToken,
        address refundReceiver,
        uint256 _nonce
    )
        public
        pure
        returns (bytes)
    {
        return abi.encode(SAFE_TX_TYPEHASH, to, value, keccak256(data), operation, safeTxGas, dataGas, gasPrice, gasToken, refundReceiver, _nonce);
    }

    function testAbiEncode(
        address to,
        uint256 value,
        bytes32 keccakOut,
        Operation operation,
        uint256 safeTxGas,
        uint256 dataGas,
        uint256 gasPrice,
        address gasToken,
        address refundReceiver,
        uint256 _nonce
    )
        public
        pure
        returns (bytes)
    {
        return abi.encode(SAFE_TX_TYPEHASH, to, value, keccakOut, operation, safeTxGas, dataGas, gasPrice, gasToken, refundReceiver, _nonce);
    }

    function testKeccak(bytes data)
        public
        pure
        returns (bytes32)
    {
        return keccak256(data);
    }

    function testAbiEncodePacked(bytes32 safeTxHash)
        public
        view
        returns (bytes)
    {
        return abi.encodePacked(byte(0x19), byte(1), domainSeparator, safeTxHash);
    }

    /// @dev divides bytes signature into `uint8 v, bytes32 r, bytes32 s`
    /// @param pos which signature to read
    /// @param signatures concatenated rsv signatures
    function signatureSplit(bytes signatures, uint256 pos)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        // The signature format is a compact form of:
        //   {bytes32 r}{bytes32 s}{uint8 v}
        // Compact means, uint8 is not padded to 32 bytes.
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let signaturePos := mul(0x41, pos)
            r := mload(add(signatures, add(signaturePos, 0x20)))
            s := mload(add(signatures, add(signaturePos, 0x40)))
            // Here we are loading the last 32 bytes, including 31 bytes
            // of 's'. There is no 'mload8' to do this.
            //
            // 'byte' is not working due to the Solidity parser, so lets
            // use the second best option, 'and'
            v := and(mload(add(signatures, add(signaturePos, 0x41))), 0xff)
        }
    }

    function testSignatureSplit(bytes signatures, uint256 pos)
        public
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        (v, r, s) = signatureSplit(signatures, pos);
    }

    function testEcrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s)
        public
        pure
        returns (address)
    {
        return ecrecover(hash, v, r, s);
    }
}
