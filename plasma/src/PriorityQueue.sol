pragma solidity ^0.4.0;

import "./SafeMath.sol";


/**
 * @title PriorityQueue
 * @dev A priority queue implementation
 */
contract PriorityQueue {
    using SafeMath for uint256;

    /*
     *  Modifiers
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /* 
     *  Storage
     */
    address owner;
    uint256[] heapList;
    uint256 public currentSize;

    function PriorityQueue()
        public
    {
        owner = msg.sender;
        heapList = [0];
        currentSize = 0;
    }

    function insert(uint256 k) 
        public
        onlyOwner
    {
        heapList.push(k);
        currentSize = currentSize.add(1);
        percUp(currentSize);
    }

    function minChild(uint256 i)
        public
        view
        returns (uint256)
    {
        if (i.mul(2).add(1) > currentSize) {
            return i.mul(2);
        } else {
            if (heapList[i.mul(2)] < heapList[i.mul(2).add(1)]) {
                return i.mul(2);
            } else {
                return i.mul(2).add(1);
            }
        }
    }

    function getMin()
        public
        view
        returns (uint256)
    {
        return heapList[1];
    }

    function delMin()
        public
        onlyOwner
        returns (uint256)
    {
        uint256 retVal = heapList[1];
        heapList[1] = heapList[currentSize];
        delete heapList[currentSize];
        currentSize = currentSize.sub(1);
        percDown(1);
        heapList.length = heapList.length.sub(1);
        return retVal;
    }

    function percUp(uint256 i) 
        private
    {
        uint256 j = i;
        uint256 newVal = heapList[i];
        while (newVal < heapList[i.div(2)]) {
            heapList[i] = heapList[i.div(2)];
            i = i.div(2);
        }
        if (i != j) heapList[i] = newVal;
    }

    function percDown(uint256 i)
        private
    {
        uint256 j = i;
        uint256 newVal = heapList[i];
        uint256 mc = minChild(i);
        while (mc <= currentSize && newVal > heapList[mc]) {
            heapList[i] = heapList[mc];
            i = mc;
            mc = minChild(i);
        }
        if (i != j) heapList[i] = newVal;
    }
}