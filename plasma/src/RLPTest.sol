pragma solidity ^0.4.0;

import "./RLP.sol";


contract RLPTest {
    function eight(bytes tx_bytes)
        public
        view
        returns (uint256, address, address)
    {
        var txList = RLP.toList(RLP.toRlpItem(tx_bytes));
        return (
            RLP.toUint(txList[5]),
            RLP.toAddress(txList[6]),
            RLP.toAddress(txList[7])
        );
    }

    function eleven(bytes tx_bytes)
        public
        view
        returns (uint256, address, address, address)
    {
        var txList = RLP.toList(RLP.toRlpItem(tx_bytes));
        return (
            RLP.toUint(txList[7]),
            RLP.toAddress(txList[8]),
            RLP.toAddress(txList[9]),
            RLP.toAddress(txList[10])
        );
    }
}
