/**
 *Submitted for verification at Etherscan.io on 2018-11-14
*/

// CryptoIndex token smart contract.
// Developed by Phenom.Team <info@phenom.team>

pragma solidity ^0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    _owner = msg.sender;
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(_owner);
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

/**
 *   @title ERC20
 *   @dev Standart ERC20 token interface
 */

contract ERC20 {
    mapping(address => uint) balances;
    mapping(address => mapping (address => uint)) allowed;

    function balanceOf(address _owner) public view returns (uint);
    function transfer(address _to, uint _value) public returns (bool);
    function transferFrom(address _from, address _to, uint _value) public returns (bool);
    function approve(address _spender, uint _value) public returns (bool);
    function allowance(address _owner, address _spender) public view returns (uint);

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint a, uint b) internal pure returns (uint) {
    if (a == 0) {
      return 0;
    }
    uint c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint a, uint b) internal pure returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 *   @title CryptoIndexToken
 *   @dev СryptoIndexToken smart-contract
 */
contract CryptoIndexToken is ERC20, Ownable() {
    using SafeMath for uint;

    string public name = "Cryptoindex 100";
    string public symbol = "CIX100";
    uint public decimals = 18;

    uint public totalSupply = 300000000*1e18;
    uint public mintedAmount;

    uint public advisorsFundPercent = 3; // 3% of private sale for advisors fund
    uint public teamFundPercent = 7; // 7% of private sale for team fund

    uint public bonusFundValue;
    uint public forgetFundValue;

    bool public mintingIsStarted;
    bool public mintingIsFinished;

    address public teamFund;
    address public advisorsFund;
    address public bonusFund;
    address public forgetFund;
    address public reserveFund;

    modifier onlyController() {
        require(controllers[msg.sender] == true);
        _;
    }

    // controllers
    mapping(address => bool) public controllers;

    //event
    event Burn(address indexed from, uint value);
    event MintingStarted(uint timestamp);
    event MintingFinished(uint timestamp);


   /**
    *   @dev Contract constructor function sets Ico address
    *   @param _teamFund       team fund address
    */
    constructor(address _forgetFund, address _teamFund, address _advisorsFund, address _bonusFund, address _reserveFund) public {
        controllers[msg.sender] = true;
        forgetFund = _forgetFund;
        teamFund = _teamFund;
        advisorsFund = _advisorsFund;
        bonusFund = _bonusFund;
        reserveFund = _reserveFund;
    }

   /**
    *   @dev Start minting
    *   @param _forgetFundValue        number of tokens for forgetFund
    *   @param _bonusFundValue         number of tokens for bonusFund
    */
    function startMinting(uint _forgetFundValue, uint _bonusFundValue) public onlyOwner {
        forgetFundValue = _forgetFundValue;
        bonusFundValue = _bonusFundValue;
        mintingIsStarted = true;
        emit MintingStarted(now);
    }

   /**
    *   @dev Finish minting
    */
    function finishMinting() public onlyOwner {
        require(mint(forgetFund, forgetFundValue));
        uint currentMintedAmount = mintedAmount;
        require(mint(teamFund, currentMintedAmount.mul(teamFundPercent).div(100)));
        require(mint(advisorsFund, currentMintedAmount.mul(advisorsFundPercent).div(100)));
        require(mint(bonusFund, bonusFundValue));
        require(mint(reserveFund, totalSupply.sub(mintedAmount)));
        mintingIsFinished = true;
        emit MintingFinished(now);
    }

   /**
    *   @dev Get balance of tokens holder
    *   @param _holder        holder's address
    *   @return               balance of investor
    */
    function balanceOf(address _holder) public view returns (uint) {
        return balances[_holder];
    }

   /**
    *   @dev Send coins
    *   throws on any error rather then return a false flag to minimize
    *   user errors
    *   @param _to           target address
    *   @param _amount       transfer amount
    *
    *   @return true if the transfer was successful
    */
    function transfer(address _to, uint _amount) public returns (bool) {
        require(mintingIsFinished);
        require(_to != address(0) && _to != address(this));
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    /**
    *   @dev Transfer token in batches
    *
    *   @param _adresses     token holders' adresses
    *   @param _values       token holders' values
    */
    function batchTransfer(address[] _adresses, uint[] _values) public returns (bool) {
        require(_adresses.length == _values.length);
        for (uint i = 0; i < _adresses.length; i++) {
            require(transfer(_adresses[i], _values[i]));
        }
        return true;
    }

   /**
    *   @dev An account/contract attempts to get the coins
    *   throws on any error rather then return a false flag to minimize user errors
    *
    *   @param _from         source address
    *   @param _to           target address
    *   @param _amount       transfer amount
    *
    *   @return true if the transfer was successful
    */
    function transferFrom(address _from, address _to, uint _amount) public returns (bool) {
        require(mintingIsFinished);

        require(_to != address(0) && _to != address(this));
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }

    /**
    *   @dev Add controller address
    *
    *   @param _controller     controller's address
    */
    function addController(address _controller) public onlyOwner {
        require(mintingIsStarted);
        controllers[_controller] = true;
    }

    /**
    *   @dev Remove controller address
    *
    *   @param _controller     controller's address
    */
    function removeController(address _controller) public onlyOwner {
        controllers[_controller] = false;
    }

    /**
    *   @dev Mint token in batches
    *
    *   @param _adresses     token holders' adresses
    *   @param _values       token holders' values
    */
    function batchMint(address[] _adresses, uint[] _values) public onlyController {
        require(_adresses.length == _values.length);
        for (uint i = 0; i < _adresses.length; i++) {
            require(mint(_adresses[i], _values[i]));
            emit Transfer(address(0), _adresses[i], _values[i]);
        }
    }

    function burn(address _from, uint _value) public {
        if (msg.sender != _from) {
          require(!mintingIsFinished);
          // burn tokens from _from only if minting stage is not finished
          // allows owner to correct initial balance before finishing minting
          require(msg.sender == this.owner());
          mintedAmount = mintedAmount.sub(_value);
        } else {
          require(mintingIsFinished);
          totalSupply = totalSupply.sub(_value);
        }
        balances[_from] = balances[_from].sub(_value);
        emit Burn(_from, _value);
    }
   /**
    *   @dev Allows another account/contract to spend some tokens on its behalf
    *   throws on any error rather then return a false flag to minimize user errors
    *
    *   also, to minimize the risk of the approve/transferFrom attack vector
    *   approve has to be called twice in 2 separate transactions - once to
    *   change the allowance to 0 and secondly to change it to the new allowance
    *   value
    *
    *   @param _spender      approved address
    *   @param _amount       allowance amount
    *
    *   @return true if the approval was successful
    */
    function approve(address _spender, uint _amount) public returns (bool) {
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }


   /**
    *   @dev Function to check the amount of tokens that an owner allowed to a spender.
    *
    *   @param _owner        the address which owns the funds
    *   @param _spender      the address which will spend the funds
    *
    *   @return              the amount of tokens still avaible for the spender
    */
    function allowance(address _owner, address _spender) public view returns (uint) {
        return allowed[_owner][_spender];
    }

    /**
    *   @dev Allows to transfer out any accidentally sent ERC20 tokens
    *   @param _tokenAddress  token address
    *   @param _amount        transfer amount
    */
    function transferAnyTokens(address _tokenAddress, uint _amount)
        public
        returns (bool success) {
        return ERC20(_tokenAddress).transfer(this.owner(), _amount);
    }

    function mint(address _to, uint _value) internal returns (bool) {
        // Mint tokens only if minting stage is not finished
        require(mintingIsStarted);
        require(!mintingIsFinished);
        require(mintedAmount.add(_value) <= totalSupply);
        balances[_to] = balances[_to].add(_value);
        mintedAmount = mintedAmount.add(_value);
        return true;
    }
}
