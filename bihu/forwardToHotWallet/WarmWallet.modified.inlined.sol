pragma solidity ^0.4.18;

contract ERC20 {
    function totalSupply() constant returns (uint supply);
    function balanceOf( address who ) constant returns (uint value);
    function allowance( address owner, address spender ) constant returns (uint _allowance);

    function transfer( address to, uint value) returns (bool ok);
    function transferFrom( address from, address to, uint value) returns (bool ok);
    function approve( address spender, uint value ) returns (bool ok);

    event Transfer( address indexed from, address indexed to, uint value);
    event Approval( address indexed owner, address indexed spender, uint value);
}

contract DSToken {
    // dummy
}

contract WarmWalletEvents {
    event LogSetWithdrawer (address indexed withdrawer);
    event LogSetWithdrawLimit (address indexed sender, uint value);
    event LogSetOwner(address indexed _owner);
}

contract WarmWallet is WarmWalletEvents{

    DSToken public key;
    address public hotWallet;
    address public coldWallet;

    //@note
    address public withdrawer;
    uint public withdrawLimit;
    uint256 public lastWithdrawTime;
    address public owner;
    bool public paused;

    modifier onlyWithdrawer {
        require(msg.sender == withdrawer);
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier notPaused {
        require(!paused);
        _;
    }

    // overrideable for easy testing
    function time() public constant returns (uint) {
        return now;
    }

    function WarmWallet(DSToken _key, address _hot, address _cold, address _withdrawer, uint _limit) public {
        require(_key != address(0) );
        require(_hot != address(0) );
        require(_cold != address(0) );
        require(_withdrawer != address(0) );
        require(_limit > 0);

        require(_key != _hot);
        require(_key != _cold);
        require(_key != _withdrawer);

        key = _key;
        hotWallet = _hot;
        coldWallet = _cold;

        withdrawer = _withdrawer;
        withdrawLimit = _limit;
        lastWithdrawTime = 0;

        owner = msg.sender;
        paused = false;
    }

    function forwardToHotWallet(uint _amount) public notPaused onlyWithdrawer returns (uint) {
        require(_amount > 0);
        uint _time = time();
        require(_time > (lastWithdrawTime + 24 hours));

        uint amount = _amount;
        if (amount > withdrawLimit) {
            amount = withdrawLimit;
        }

        lastWithdrawTime = _time;
        return amount;
        // key.transfer(hotWallet, amount);
    }

    function restoreToColdWallet(uint _amount) public onlyWithdrawer returns (uint) {
        require(_amount > 0);
        return _amount;
        // key.transfer(coldWallet, _amount);
    }

    function setWithdrawer(address _withdrawer) public onlyOwner {
        require(_withdrawer != address(0) );

        withdrawer = _withdrawer;
        LogSetWithdrawer(_withdrawer);
    }

    function setOwner(address _owner) public onlyOwner {
        owner = _owner;
        LogSetOwner(_owner);
    }

    function setWithdrawLimit(uint _limit) public onlyOwner {
        require(_limit > 0);

        withdrawLimit = _limit;
        LogSetWithdrawLimit(msg.sender, _limit);
    }


    function pauseStart() public onlyOwner {
        paused = true;
    }

    function pauseEnd() public onlyOwner {
        paused = false;
    }

    // @notice This method can be used by the controller to extract mistakenly
    //  sent tokens to this contract.
    // @param dst The address that will be receiving the tokens
    // @param wad The amount of tokens to transfer
    // @param _token The address of the token contract that you want to recover
    function transferTokens(address dst, uint wad, address _token) public onlyWithdrawer {
        require(_token != address(key));
        if (wad > 0) {
            ERC20 token = ERC20(_token);
            token.transfer(dst, wad);
        }
    }



}
