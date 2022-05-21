// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
Import

Examples 
- local files
- github (only in Remix) (different branches)

Folder

browser
├── TestImport.sol
└── Foo.sol
*/

import "./Foo.sol";

contract TestImport {
    Foo foo = new Foo();

    function getFooName() public view returns(string memory) {
        return foo.name();
    }
}

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor() ERC20("MyToken", "MT") {}
}
