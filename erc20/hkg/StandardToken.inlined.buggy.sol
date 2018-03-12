pragma solidity ^0.4.2;

/*
 * Token - is a smart contract interface
 * for managing common functionality of
 * a token.
 *
 * ERC.20 Token standard: https://github.com/eth ereum/EIPs/issues/20
 */
contract TokenInterface {


    // total amount of tokens
    uint totalSupply;


    /**
     *
     * balanceOf() - constant function check concrete tokens balance
     *
     *  @param owner - account owner
     *
     *  @return the value of balance
     */
    function balanceOf(address owner) constant returns (uint256 balance);

    function transfer(address to, uint256 value) returns (bool success);

    function transferFrom(address from, address to, uint256 value) returns (bool success);

    /**
     *
     * approve() - function approves to a person to spend some tokens from
     *           owner balance.
     *
     *  @param spender - person whom this right been granted.
     *  @param value   - value to spend.
     *
     *  @return true in case of succes, otherwise failure
     *
     */
    function approve(address spender, uint256 value) returns (bool success);

    /**
     *
     * allowance() - constant function to check how much is
     *               permitted to spend to 3rd person from owner balance
     *
     *  @param owner   - owner of the balance
     *  @param spender - permitted to spend from this balance person
     *
     *  @return - remaining right to spend
     *
     */
    function allowance(address owner, address spender) constant returns (uint256 remaining);

    // events notifications
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/*
 * StandardToken - is a smart contract
 * for managing common functionality of
 * a token.
 *
 * ERC.20 Token standard:
 *         https://github.com/eth ereum/EIPs/issues/20
 */
contract StandardToken is TokenInterface {


    // token ownership
    mapping (address => uint256) balances;

    // spending permision management
    mapping (address => mapping (address => uint256)) allowed;



    function StandardToken(){
    }


    /**
     * transfer() - transfer tokens from msg.sender balance
     *              to requested account
     *
     *  @param to    - target address to transfer tokens
     *  @param value - ammount of tokens to transfer
     *
     *  @return - success / failure of the transaction
     */
    function transfer(address to, uint256 value) returns (bool success) {


        if (balances[msg.sender] >= value && value > 0) {

            // do actual tokens transfer
            balances[msg.sender] -= value;
            balances[to]         += value;

            // rise the Transfer event
            Transfer(msg.sender, to, value);
            return true;
        } else {

            return false;
        }
    }




    /**
     * transferFrom() - used to move allowed funds from other owner
     *                  account
     *
     *  @param from  - move funds from account
     *  @param to    - move funds to account
     *  @param value - move the value
     *
     *  @return - return true on success false otherwise
     */
    function transferFrom(address from, address to, uint256 value) returns (bool success) {

        if ( balances[from] >= value &&
             allowed[from][msg.sender] >= value &&
             value > 0) {


            // do the actual transfer
            balances[from] -= value;
            balances[to] =+ value;


            // addjust the permision, after part of
            // permited to spend value was used
            allowed[from][msg.sender] -= value;

            // rise the Transfer event
            Transfer(from, to, value);
            return true;
        } else {

            return false;
        }
    }




    /**
     *
     * balanceOf() - constant function check concrete tokens balance
     *
     *  @param owner - account owner
     *
     *  @return the value of balance
     */
    function balanceOf(address owner) constant returns (uint256 balance) {
        return balances[owner];
    }



    /**
     *
     * approve() - function approves to a person to spend some tokens from
     *           owner balance.
     *
     *  @param spender - person whom this right been granted.
     *  @param value   - value to spend.
     *
     *  @return true in case of succes, otherwise failure
     *
     */
    function approve(address spender, uint256 value) returns (bool success) {



        // now spender can use balance in
        // ammount of value from owner balance
        allowed[msg.sender][spender] = value;

        // rise event about the transaction
        Approval(msg.sender, spender, value);

        return true;
    }

    /**
     *
     * allowance() - constant function to check how mouch is
     *               permited to spend to 3rd person from owner balance
     *
     *  @param owner   - owner of the balance
     *  @param spender - permited to spend from this balance person
     *
     *  @return - remaining right to spend
     *
     */
    function allowance(address owner, address spender) constant returns (uint256 remaining) {
      return allowed[owner][spender];
    }

}
