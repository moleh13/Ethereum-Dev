// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract vault {
    mapping (address => uint) vaultBalances;

    function deposit(uint _amount) public payable {
        vaultBalances[msg.sender] += _amount;
    }

    function withdraw(uint _amount) public payable {
        vaultBalances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
    }
}