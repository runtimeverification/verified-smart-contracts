pragma solidity 0.5.0;


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
        bytes memory data,
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
        returns (bytes memory)
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
        returns (bytes memory)
    {
        return abi.encode(SAFE_TX_TYPEHASH, to, value, keccakOut, operation, safeTxGas, dataGas, gasPrice, gasToken, refundReceiver, _nonce);
    }

    function testKeccak(bytes memory data)
        public
        pure
        returns (bytes32)
    {
        return keccak256(data);
    }

    function testAbiEncodePacked(bytes32 safeTxHash)
        public
        view
        returns (bytes memory)
    {
        return abi.encodePacked(byte(0x19), byte(0x01), domainSeparator, safeTxHash);
    }

    function testEcrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s)
        public
        pure
        returns (address)
    {
        return ecrecover(hash, v, r, s);
    }
}
