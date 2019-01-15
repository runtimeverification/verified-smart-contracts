pragma solidity ^0.5.0;

contract ExternalContract {

    function isValidSignature(
        bytes calldata _data,
        bytes calldata _signature)
        external
        returns (bool isValid)
    {
        isValid = false;
    }
}