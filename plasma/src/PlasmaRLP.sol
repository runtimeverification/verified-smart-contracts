pragma solidity ^0.4.0;

import "./RLP.sol";


library PlasmaRLP {

    struct exitingTx {
        address exitor;
        address token;
        uint256 amount;
        uint256 inputCount;
    }

    /* Public Functions */

    function getUtxoPos(bytes memory challengingTxBytes, uint256 oIndex)
        internal
        constant
        returns (uint256)
    {
        var txList = RLP.toList(RLP.toRlpItem(challengingTxBytes));
        uint256 oIndexShift = oIndex * 3;
        uint256 blknum = RLP.toUint(txList[0 + oIndexShift]);
        uint256 txindex = RLP.toUint(txList[1 + oIndexShift]);
        uint256 oindex = RLP.toUint(txList[2 + oIndexShift]);
        return (blknum * 1000000000) + (txindex * 10000) + oindex;
    }

    function createExitingTx(bytes memory exitingTxBytes, uint256 oindex)
        internal
        constant
        returns (exitingTx)
    {
        var txList = RLP.toList(RLP.toRlpItem(exitingTxBytes));
        return exitingTx({
            exitor: RLP.toAddress(txList[7 + 2 * oindex]),
            token: RLP.toAddress(txList[6]),
            amount: RLP.toUint(txList[8 + 2 * oindex]),
            inputCount: RLP.toUint(txList[0]) * RLP.toUint(txList[3])
        });
    }
}
