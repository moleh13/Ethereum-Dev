// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract vault_4 {
    constructor() payable {}
    mapping (address => uint) vaultBalances;

    function deposit(uint _amount) public payable {
        require(msg.value >= _amount * (10 ** 18));
        vaultBalances[msg.sender] += msg.value / (10 ** 18);
    }

    function getBalance() public view returns(uint){
        return vaultBalances[msg.sender];
    }

    function withdraw(uint _amount) public payable {
        require(vaultBalances[msg.sender] >= _amount);
        vaultBalances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount * 10 ** 18);
    }
}