pragma solidity 0.4.24;


/// Contracts for testing kprove reasoning engine.
contract KTest {

    function ecrecImplication(address a1, bytes32 p1, uint8 a2v, bytes32 p3, bytes32 p4, address a3)
        public
        pure
        returns (bool)
    {
        address a2 = ecrecover(p1, a2v, p3, p4);
        return a1 < a2 && a2 < a3;
    }

    function ecrecConstraint(address a1, bytes32 p1, uint8 a2v, bytes32 p3, bytes32 p4, address a3)
        public
        pure
        returns (bool)
    {
        address a2 = ecrecover(p1, a2v, p3, p4);
        if (a1 < a2 && a2 < a3) {
            return true;
        }
        return false;
    }

}
