//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/* Denial of Service
Denial of service by rejecting to accept Ether
Code and Demo
Preventative Technique (Push vs Pull)
*/

contract KingOfEther {
    address public king;
    uint public balance;
    mapping (address => uint) balances;

    // Alice sends 1 Ether (king = Alice, balance = 1 ether)
    // Bob   sends 2 Ether

    function claimThrone() external payable {
        require(msg.value > balance, "Need to pay more to become the king");

        //(bool sent, ) = king.call{value: balance}("");
        //require(sent, "Failed to send Ether");

        balances[king] += balance;

        balance = msg.value;
        king = msg.sender;
    }

    function withdraw() public {
        require(msg.sender != king, "Current king cannot withdraw");

        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Attack {
    function attack(KingOfEther _kingOfEther) public payable {
        _kingOfEther.claimThrone{value: msg.value}();
    }
}