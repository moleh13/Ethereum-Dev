// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract vault_3 {
    mapping (address => uint) vaultBalances;

    function deposit(uint _amount) public payable {
        require(msg.value == _amount);
        vaultBalances[msg.sender] += msg.value;
    }

    receive() external payable {}

    function getBalance() public view returns(uint){
        return vaultBalances[msg.sender];
    }

    function withdraw(uint _amount) public payable {
        require(vaultBalances[msg.sender] >= _amount);
        vaultBalances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
    }
}