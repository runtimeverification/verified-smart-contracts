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

    //same set of arguments as encodeTransactionData
    function testAbiEncode(
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

    function testKeccak(bytes data)
        public
        pure
        returns (bytes32)
    {
        return keccak256(data);
    }
}
