//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
Front Running
- What is it?
- Code
*/

contract FindThisHash {
    bytes32 constant public hash = 0x564ccaf7594d66b1eaaea24fe01f0585bf52ee70852af4eac0cc4b04711cd0e2;

    constructor() payable {}

    function solve(string memory _solution) public {
        require(hash == keccak256(abi.encodePacked(_solution)), "Incorrect answer");

        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}