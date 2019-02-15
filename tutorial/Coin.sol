pragma solidity ^0.5.0;

library SafeArithmetic {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
       require(b <= a);
       uint256 c = a - b;
       return c;
    }
}

contract Owned {
    mapping(address => address) internal owners;
    uint256 ownerCount;

    // does not occupy storage slot
    address public constant SENTINEL = address(0x1);

    function addOwners(address[] memory _owners) public {
        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0) && owner != SENTINEL && owners[owner] == address(0),
                    "Invalid owner address");
            owners[owner] = owners[SENTINEL];
            owners[SENTINEL] = owner;
        }
        ownerCount += _owners.length;
    }

    function isOwner(address owner) public view returns (bool) {
        return owner != SENTINEL && owners[owner] != address(0);
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "Only allowed for owners");
        _;
    }

}

contract Coin is Owned {
    using SafeArithmetic for uint;

    address public master;   // 20 bytes
    bool public placeholder; // 1 byte -> two vars packed in to one location
    mapping (address => uint) public balances;
    mapping (address => mapping (address => uint256)) public minted;

    event Sent(address from, address to, uint amount);

    constructor() public {
        master = msg.sender;
    }

    function addOwners(address[] memory _owners) public {
        require(msg.sender == master);
        // internal
        super.addOwners(_owners);
    }


    function mint(address receiver, uint amount) public onlyOwner {
        // equivalent to add(..., ...), syntatic sugar enabled by `using ... for ...`
        balances[receiver] = balances[receiver].add(amount);
        minted[msg.sender][receiver] = minted[msg.sender][receiver].add(amount);
    }

    function send(address receiver, uint amount) public {
        require(amount <= balances[msg.sender], "Insufficient balance.");
        balances[msg.sender] = balances[msg.sender].sub(amount);
        balances[receiver] = balances[receiver].add(amount);
        emit Sent(msg.sender, receiver, amount);
    }

    function () external payable {}

    function withdrawEther() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    }
}

