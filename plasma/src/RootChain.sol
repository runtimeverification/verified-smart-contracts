pragma solidity ^0.4.0;

import "./SafeMath.sol";
import "./Math.sol";
import "./PlasmaRLP.sol";
import "./Merkle.sol";
import "./Validate.sol";
import "./PriorityQueue.sol";

import "./ERC20.sol";


/**
 * @title RootChain
 * @dev This contract secures a utxo payments plasma child chain to ethereum.
 */
contract RootChain {
    using SafeMath for uint256;
    using Merkle for bytes32;
    using PlasmaRLP for bytes;


    /*
     * Events
     */

    event Deposit(
        address indexed depositor,
        uint256 indexed depositBlock,
        address token,
        uint256 amount
    );

    event ExitStarted(
        address indexed exitor,
        uint256 indexed utxoPos,
        address token,
        uint256 amount
    );

    event BlockSubmitted(
        uint256 blockNumber
    );

    event TokenAdded(
        address token
    );


    /*
     * Storage
     */

    uint256 public constant CHILD_BLOCK_INTERVAL = 1000;

    address public operator;

    uint256 public currentChildBlock;
    uint256 public currentDepositBlock;
    uint256 public currentFeeExit;

    mapping (uint256 => ChildBlock) public childChain;
    mapping (uint256 => Exit) public exits;
    mapping (address => address) public exitsQueues;

    struct Exit {
        address owner;
        address token;
        uint256 amount;
    }

    struct ChildBlock {
        bytes32 root;
        uint256 timestamp;
    }


    /*
     * Modifiers
     */

    modifier onlyOperator() {
        require(msg.sender == operator);
        _;
    }


    /*
     * Constructor
     */

    constructor()
        public
    {
        operator = msg.sender;
        currentChildBlock = CHILD_BLOCK_INTERVAL;
        currentDepositBlock = 1;
        currentFeeExit = 1;
        // Support only ETH on deployment; other tokens need
        // to be added explicitly.
        exitsQueues[address(0)] = address(new PriorityQueue());
    }


    /*
     * Public Functions
     */

    // @dev Allows anyone to add new token to Plasma chain
    // @param token The address of the ERC20 token
    function addToken(address _token)
        public
    {
        require(!hasToken(_token));
        exitsQueues[_token] = address(new PriorityQueue());
        TokenAdded(_token);
    }

    /**
     * @dev Allows Plasma chain operator to submit block root.
     * @param _root The root of a child chain block.
     */
    function submitBlock(bytes32 _root)
        public
        onlyOperator
    {
        uint256 submittedBlockNumber = currentChildBlock;
        childChain[currentChildBlock] = ChildBlock({
            root: _root,
            timestamp: block.timestamp
        });

        // Update block numbers.
        currentChildBlock = currentChildBlock.add(CHILD_BLOCK_INTERVAL);
        currentDepositBlock = 1;

        emit BlockSubmitted(submittedBlockNumber);
    }

    /**
     * @dev Allows anyone to deposit funds into the Plasma chain.
     */
    function deposit()
        public
        payable
    {
        // Only allow up to CHILD_BLOCK_INTERVAL deposits per child block.
        require(currentDepositBlock < CHILD_BLOCK_INTERVAL);

        writeDepositBlock(msg.sender, address(0), msg.value);
    }


    /**
     * @dev Deposits approved amount of ERC20 token. Approve must be called first. Note: does not check if token was added.
     */
    function depositFrom(address _owner, address _token, uint256 _amount)
        public
    {
        // Only allow up to CHILD_BLOCK_INTERVAL deposits per child block.
        require(currentDepositBlock < CHILD_BLOCK_INTERVAL);

        // Warning, check your ERC20 implementation. TransferFrom should return bool
        require(ERC20(_token).transferFrom(_owner, address(this), _amount));
        writeDepositBlock(_owner, _token, _amount);
    }

    /**
     * @dev Starts an exit from a deposit.
     * @param _depositPos UTXO position of the deposit.
     * @param _token Token type to deposit.
     * @param _amount Deposit amount.
     */
    function startDepositExit(uint256 _depositPos, address _token, uint256 _amount)
        public
    {
        uint256 blknum = _depositPos / 1000000000;

        // Check that the given UTXO is a deposit.
        require(blknum % CHILD_BLOCK_INTERVAL != 0);

        // Validate the given owner and amount.
        bytes32 root = childChain[blknum].root;
        bytes32 depositHash = keccak256(msg.sender, _token, _amount);
        require(root == depositHash);

        addExitToQueue(_depositPos, msg.sender, _token, _amount, childChain[blknum].timestamp);
    }

    /**
     * @dev Allows the operator withdraw any allotted fees. Starts an exit to avoid theft.
     * @param _token Token to withdraw.
     * @param _amount Amount in fees to withdraw.
     */
    function startFeeExit(address _token, uint256 _amount)
        public
        onlyOperator
    {
        addExitToQueue(currentFeeExit, msg.sender, _token, _amount, block.timestamp + 1);
        currentFeeExit = currentFeeExit.add(1);
    }

    /**
     * @dev Starts to exit a specified utxo.
     * @param _utxoPos The position of the exiting utxo in the format of blknum * 1000000000 + index * 10000 + oindex.
     * @param _txBytes The transaction being exited in RLP bytes format.
     * @param _proof Proof of the exiting transactions inclusion for the block specified by utxoPos.
     * @param _sigs Both transaction signatures and confirmations signatures used to verify that the exiting transaction has been confirmed.
     */
    function startExit(
        uint256 _utxoPos,
        bytes _txBytes,
        bytes _proof,
        bytes _sigs
    )
        public
    {
        uint256 blknum = _utxoPos / 1000000000;
        uint256 txindex = (_utxoPos % 1000000000) / 10000;
        uint256 oindex = _utxoPos - blknum * 1000000000 - txindex * 10000;

        // Check the sender owns this UTXO.
        var exitingTx = _txBytes.createExitingTx(oindex);
        require(msg.sender == exitingTx.exitor);

        // Check the transaction was included in the chain and is correctly signed.
        bytes32 root = childChain[blknum].root;
        bytes32 merkleHash = keccak256(keccak256(_txBytes), ByteUtils.slice(_sigs, 0, 130));
        require(Validate.checkSigs(keccak256(_txBytes), root, exitingTx.inputCount, _sigs));
        require(merkleHash.checkMembership(txindex, root, _proof));

        addExitToQueue(_utxoPos, exitingTx.exitor, exitingTx.token, exitingTx.amount, childChain[blknum].timestamp);
    }

    /**
     * @dev Allows anyone to challenge an exiting transaction by submitting proof of a double spend on the child chain.
     * @param _cUtxoPos The position of the challenging utxo.
     * @param _eUtxoIndex The output position of the exiting utxo.
     * @param _txBytes The challenging transaction in bytes RLP form.
     * @param _proof Proof of inclusion for the transaction used to challenge.
     * @param _sigs Signatures for the transaction used to challenge.
     * @param _confirmationSig The confirmation signature for the transaction used to challenge.
     */
    function challengeExit(
        uint256 _cUtxoPos,
        uint256 _eUtxoIndex,
        bytes _txBytes,
        bytes _proof,
        bytes _sigs,
        bytes _confirmationSig
    )
        public
    {
        uint256 eUtxoPos = _txBytes.getUtxoPos(_eUtxoIndex);
        uint256 txindex = (_cUtxoPos % 1000000000) / 10000;
        bytes32 root = childChain[_cUtxoPos / 1000000000].root;
        var txHash = keccak256(_txBytes);
        var confirmationHash = keccak256(txHash, root);
        var merkleHash = keccak256(txHash, _sigs);
        address owner = exits[eUtxoPos].owner;

        // Validate the spending transaction.
        require(owner == ECRecovery.recover(confirmationHash, _confirmationSig));
        require(merkleHash.checkMembership(txindex, root, _proof));

        // Delete the owner but keep the amount to prevent another exit.
        delete exits[eUtxoPos].owner;
    }

    /**
     * @dev Processes exits that have completed the challenge period.
     * @param _token Token type to process.
     * @param _topUtxoPos First exit that should be processed. Set to zero to skip the check.
     * @param _exitsToProcess Maximal number of exits to process.
     */
    function finalizeExits(address _token, uint256 _topUtxoPos, uint256 _exitsToProcess)
        public
    {
        uint256 utxoPos;
        uint256 exitable_at;
        uint256 _exitsLeft = _exitsToProcess;
        (utxoPos, exitable_at) = getNextExit(_token);
        require(_topUtxoPos == utxoPos || _topUtxoPos == 0);
        Exit memory currentExit = exits[utxoPos];
        PriorityQueue queue = PriorityQueue(exitsQueues[_token]);
        while (exitable_at < block.timestamp && _exitsLeft > 0) {
            currentExit = exits[utxoPos];

            queue.delMin();

            // Send funds only if exit was not successfully challenged.
            if (exits[utxoPos].owner != address(0)) {
                if (_token == address(0)) {
                    currentExit.owner.transfer(currentExit.amount);
                }
                else {
                    require(ERC20(_token).transfer(currentExit.owner, currentExit.amount));
                }
            }
            delete exits[utxoPos].owner;

            if (queue.currentSize() > 0) {
                (utxoPos, exitable_at) = getNextExit(_token);
                _exitsLeft = _exitsLeft.sub(1);
            } else {
                return;
            }
        }
    }


    /*
     * Public view functions
     */

    /**
     * @dev Checks if queue for particular token was created.
     * @param _token Address of the token.
     */
    function hasToken(address _token)
        view
        public
        returns (bool)
    {
        return exitsQueues[_token] != address(0);
    }

    /**
     * @dev Queries the child chain.
     * @param _blockNumber Number of the block to return.
     * @return Child chain block at the specified block number.
     */
    function getChildChain(uint256 _blockNumber)
        public
        view
        returns (bytes32, uint256)
    {
        return (childChain[_blockNumber].root, childChain[_blockNumber].timestamp);
    }

    /**
     * @dev Determines the next deposit block number.
     * @return Block number to be given to the next deposit block.
     */
    function getDepositBlock()
        public
        view
        returns (uint256)
    {
        return currentChildBlock.sub(CHILD_BLOCK_INTERVAL).add(currentDepositBlock);
    }

    /**
     * @dev Returns information about an exit.
     * @param _utxoPos Position of the UTXO in the chain.
     * @return A tuple representing the active exit for the given UTXO.
     */
    function getExit(uint256 _utxoPos)
        public
        view
        returns (address, address, uint256)
    {
        return (exits[_utxoPos].owner, exits[_utxoPos].token, exits[_utxoPos].amount);
    }

    /**
     * @dev Determines the next exit to be processed.
     * @param _token Asset type to be exited.
     * @return A tuple of the position and time when this exit can be processed.
     */
    function getNextExit(address _token)
        public
        view
        returns (uint256, uint256)
    {
        uint256 priority = PriorityQueue(exitsQueues[_token]).getMin();
        uint256 utxoPos = uint256(uint128(priority));
        uint256 exitable_at = priority >> 128;
        return (utxoPos, exitable_at);
    }


    /*
     * Private functions
     */


    /**
     * @dev Adds deposit block to chain of blocks.
     * @param _owner Owner of deposit and created UTXO.
     * @param _token Deposited token (0x0 represents ETH).
     * @param _amount The amount deposited.
     */
    function writeDepositBlock(address _owner, address _token, uint256 _amount)
        private
    {
        bytes32 root = keccak256(_owner, _token, _amount);
        uint256 depositBlock = getDepositBlock();
        childChain[depositBlock] = ChildBlock({
            root: root,
            timestamp: block.timestamp
        });
        currentDepositBlock = currentDepositBlock.add(1);

        emit Deposit(_owner, depositBlock, _token, _amount);
    }


    /**
     * @dev Adds an exit to the exit queue.
     * @param _utxoPos Position of the UTXO in the child chain.
     * @param _exitor Owner of the UTXO.
     * @param _token Token to be exited.
     * @param _amount Amount to be exited.
     * @param _created_at Time when the UTXO was created.
     */
    function addExitToQueue(
        uint256 _utxoPos,
        address _exitor,
        address _token,
        uint256 _amount,
        uint256 _created_at
    )
        private
    {
        // Check that we're exiting a known token.
        require(exitsQueues[_token] != address(0));

        // Calculate priority.
        uint256 exitable_at = Math.max(_created_at + 2 weeks, block.timestamp + 1 weeks);
        uint256 priority = exitable_at << 128 | _utxoPos;

        // Check exit is valid and doesn't already exist.
        require(_amount > 0);
        require(exits[_utxoPos].amount == 0);

        PriorityQueue queue = PriorityQueue(exitsQueues[_token]);
        queue.insert(priority);

        exits[_utxoPos] = Exit({
            owner: _exitor,
            token: _token,
            amount: _amount
        });

        emit ExitStarted(msg.sender, _utxoPos, _token, _amount);
    }
}
