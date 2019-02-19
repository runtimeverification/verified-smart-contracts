pragma solidity ^0.5.0;

contract Cafe { // at 0xcafe
  // address[] -> 32 bytes padding
  // 1 byte   [32 bytes length][1 byte 1st elem][1 byte 2nd elem] .......[1 byte 32nd elem] .....
  // [0x1, 0x2] -> [0....02][0x1][0x2][0..0]
  //                32 bytes          ^^^^^^ 30 bytes of zero
  function make(bytes memory what) public returns (uint) { return 0xc0ffee; }
  function () external payable {}
}

contract Person {
  function getCoffee() public payable returns (uint) {
    return Cafe(0xcafe).make("latte");
    // [sig][offset of `what`][length of `what`][contents of `what`]
  }
  function sendMoney() public {
    address(0xcafe).send(16);
  }
  function transferMoney() public {
    address(0xcafe).transfer(16);
  }
}
