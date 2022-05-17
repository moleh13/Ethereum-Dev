//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/*
Calling other contracts

Examples
- call non-payable function in another contract
- call payable function in another contract
*/

contract Callee {
    uint public x;
    uint public value;

    function setX(uint _x) public returns (uint) {
        x = _x;
        return x;
    }

    function setXandSendEther(uint _x) public payable returns(uint, uint) {
        x = _x;
        value = msg.value;

        return (x, value);
    }
}

contract Foo {
    uint public x;

    function setX(uint _x) public returns(uint) {
        x = _x + 1;
        return x;
    }
}

contract Caller {
    function setX(Callee _callee, uint _x) public returns (uint) {
        uint x = _callee.setX(_x);
        return x;
    }

    function setXFromAddress(address _addr, uint _x) public returns (uint) {
        Callee callee = Callee(_addr);
        uint x = callee.setX(_x);
        return x;
    } 

    function setXAndSendEther(Callee _callee, uint _x) public payable returns (uint, uint) {
        (uint x, uint value) = _callee.setXandSendEther{value: msg.value}(_x);
        return (x, value);
    }
}