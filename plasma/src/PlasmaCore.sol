pragma solidity ^0.4.0;

import "./ByteUtils.sol";
import "./RLP.sol";


/**
 * @title PlasmaCore
 * @dev Utilities for working with and decoding Plasma MVP transactions.
 */
library PlasmaCore {
    using ByteUtils for bytes;
    using RLP for bytes;
    using RLP for RLP.RLPItem;


    /*
     * Storage
     */
    uint256 constant internal NUM_TXS = 2;
    uint256 constant internal BLOCK_OFFSET = 1000000000;
    uint256 constant internal TX_OFFSET = 10000;
    uint256 constant internal PROOF_SIZE_BYTES = 32;
    uint256 constant internal SIGNATURE_SIZE_BYTES = 65;

    struct TransactionInput {
        uint256 blknum;
        uint256 txindex;
        uint256 oindex;
    }

    struct TransactionOutput {
        address owner;
        uint256 amount;
    }

    struct Transaction {
        TransactionInput[NUM_TXS] inputs;
        TransactionOutput[NUM_TXS] outputs;
    }

    
    /*
     * Internal functions
     */
    
    /**
     * @dev Decodes an RLP encoded transaction.
     * @param _tx RLP encoded transaction.
     * @return Decoded transaction.
     */
    function decode(bytes memory _tx)
        internal
        view
        returns (Transaction)
    {
        RLP.RLPItem[] memory txList = _tx.toRlpItem().toList();
        RLP.RLPItem[] memory inputs = txList[0].toList();
        RLP.RLPItem[] memory outputs = txList[1].toList();

        Transaction memory decodedTx;
        for (uint i = 0; i < NUM_TXS; i++) {
            RLP.RLPItem[] memory input = inputs[i].toList();
            decodedTx.inputs[i] = TransactionInput({
                blknum: input[0].toUint(),
                txindex: input[1].toUint(),
                oindex: input[2].toUint()
            });

            RLP.RLPItem[] memory output = outputs[i].toList();
            decodedTx.outputs[i] = TransactionOutput({
                owner: output[0].toAddress(),
                amount: output[1].toUint()
            });
        }

        return decodedTx;
    }

    /**
     * @dev Given an output ID, returns the block number.
     * @param _outputId Output identifier to decode.
     * @return The output's block number.
     */
    function getBlknum(uint256 _outputId)
        internal
        pure
        returns (uint256)
    {
        return _outputId / BLOCK_OFFSET;
    }

    /**
     * @dev Given an output ID, returns the transaction index.
     * @param _outputId Output identifier to decode.
     * @return The output's transaction index.
     */
    function getTxindex(uint256 _outputId)
        internal
        pure
        returns (uint256)
    {
        return (_outputId % BLOCK_OFFSET) / TX_OFFSET;
    }

    /**
     * @dev Given an output ID, returns the output index.
     * @param _outputId Output identifier to decode.
     * @return The output's index.
     */
    function getOindex(uint256 _outputId)
        internal
        pure
        returns (uint8)
    {
        return uint8(_outputId % TX_OFFSET);
    }

    /**
     * @dev Returns the identifier for an input to a transaction.
     * @param _tx RLP encoded input.
     * @param _inputIndex Index of the input to return.
     * @return A combined identifier.
     */
    function getInputId(bytes memory _tx, uint256 _inputIndex)
        internal
        view
        returns (uint256)
    {
        Transaction memory decodedTx = decode(_tx);
        TransactionInput memory input = decodedTx.inputs[_inputIndex];
        return input.blknum * BLOCK_OFFSET + input.txindex * TX_OFFSET + input.oindex;
    }

    /**
     * @dev Returns an output to a transaction.
     * @param _tx RLP encoded transaction.
     * @param _outputIndex Index of the output to return.
     * @return The transaction output.
     */
    function getOutput(bytes memory _tx, uint256 _outputIndex)
        internal
        view
        returns (TransactionOutput)
    {
        Transaction memory decodedTx = decode(_tx);
        return decodedTx.outputs[_outputIndex];
    }

    /**
     * @dev Slices a signature off a list of signatures.
     * @param _signatures A list of signatures in bytes form.
     * @param _index Which signature to slice.
     * @return A signature in bytes form.
     */
    function sliceSignature(bytes memory _signatures, uint256 _index)
        internal
        pure
        returns (bytes)
    {
        return _sliceOne(_signatures, SIGNATURE_SIZE_BYTES, _index);
    }

    /**
     * @dev Slices a Merkle proof off a list of proofs.
     * @param _proofs A list of proofs in bytes form.
     * @param _index Which proof to slice.
     * @return A proof in bytes form.
     */
    function sliceProof(bytes memory _proofs, uint256 _index)
        internal
        pure
        returns (bytes)
    {
        return _sliceOne(_proofs, PROOF_SIZE_BYTES, _index);
    }


    /*
     * Private functions
     */

    /**
     * @dev Slices an element off a list of equal-sized elements in bytes form.
     * @param _list A list of equal-sized elements in bytes.
     * @param _length Size of each item.
     * @param _index Which item to slice.
     * @return A single element at the specified index.
     */
    function _sliceOne(bytes memory _list, uint256 _length, uint256 _index)
        private
        pure
        returns (bytes)
    {
        return _list.slice(_length * _index, _length);
    }
}
