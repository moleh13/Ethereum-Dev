// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
Keccak256 (Cryptographic Hash Function)
- what is it?
    - function that takes in arbitrary size input and outputs a data of fixed size
    - properties
        - deterministic 
            - hash(x) = h, every time
        - quick to compute the hash
        - irreversible
            - given h, hard to find x such that hash(x) = h
        - small change in input change the output significantly
        - collision resistant
            - hard to find x, y such that hash(x) = hash(y)

Example
- guessing game (pseudo random)

*/

contract HashFunction {

    function hash(string memory _text, uint _num, address _addr) public pure returns (bytes32) {

        return keccak256(abi.encodePacked(_text, _num, _addr));
    }

    function collision(string memory _text, string memory _anotherText) public pure returns (bytes32) {
        
        // AAA BBB -> AAABBB
        // AA ABBB -> AAABBB
        return keccak256(abi.encode(_text, _anotherText)); // prevent collision
        // return keccak256(abi.encodePacked(_text, _anotherText)) may lead a collision
    }
}

contract GuessTheMagicWord {
    bytes32 public answer = 
    0x60298f78cc0b47170ba79c10aa3851d7648bd96f2f8e46a19dbc777c36fb0c00;
    
    function guess(string memory _word) public view returns (bool) {
        return keccak256(abi.encodePacked(_word)) == answer;
    }  
}

// 0x9bbd5de6eec05c380c2a2ac45c78e85a1f780625f8bb438aacf58ac542f4ebd8
// 0x0f7481c808d478210705b44b811098b6234ceccd7bd6c8f23cc556f88016ca43