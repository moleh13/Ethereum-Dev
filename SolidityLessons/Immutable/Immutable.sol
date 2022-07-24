// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract Immutable {
    address public immutable owner;  // save some gas

    constructor() {
        owner = msg.sender;
    }

    uint public x;
    function foo() external {
        require(msg.sender == owner);
        x += 1;
    }
}