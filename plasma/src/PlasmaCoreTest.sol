pragma solidity ^0.4.0;

import "./PlasmaCore.sol";


/**
 * @title PlasmaCoreTest
 * @dev Tests PlasmaCore library
 */
contract PlasmaCoreTest {
    using PlasmaCore for bytes;

    function sliceProof(bytes memory _proofs, uint256 _index)
        public
        pure
        returns (bytes)
    {
        return PlasmaCore.sliceProof(_proofs, _index);
    }

    function sliceSignature(bytes memory _signatures, uint256 _index)
        public
        pure
        returns (bytes)
    {
        return PlasmaCore.sliceSignature(_signatures, _index);
    }

    function getOutput(bytes _tx, uint256 _outputIndex)
        public
        view
        returns (address, uint256)
    {
        PlasmaCore.TransactionOutput memory output = PlasmaCore.getOutput(_tx, _outputIndex);
        return (output.owner, output.amount);
    }

    function getInputId(bytes _tx, uint256 _inputIndex)
        public
        view
        returns (uint256)
    {
        return PlasmaCore.getInputId(_tx, _inputIndex);
    }

    function getOindex(uint256 _outputId)
        public
        pure
        returns (uint8)
    {
        return PlasmaCore.getOindex(_outputId);
    }

    function getTxindex(uint256 _outputId)
        public
        pure
        returns (uint256)
    {
        return PlasmaCore.getTxindex(_outputId);
    }

    function getBlknum(uint256 _outputId)
        public
        pure
        returns (uint256)
    {
        return PlasmaCore.getBlknum(_outputId);
    }
}