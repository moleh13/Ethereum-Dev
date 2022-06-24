/*
Solidity 0.8
* safe math
* custom errors
* functions outside contract
* import {symbol1 as alias, symbol2} from "filename";
* Salted contract creations / create2
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// safe math
contract SafeMath  {
    function testUnderflow() public pure returns (uint) {
        uint x = 0;
        x--;
        return x;
    }

    function testUncheckedUnderflow() public pure returns (uint) {
        uint x = 0;
        unchecked {
            x--;
        }
        return x;
    }
}


// custom error
error Unauthorized(address caller);

contract VendingMachine {
    address payable owner = payable(msg.sender);

    function withdraw() public {
        if (msg.sender != owner)
        revert Unauthorized(msg.sender);
        
        owner.transfer(address(this).balance);
    }
}

// functions outside contract
function helper(uint x) view returns (uint) {
    return x + 2;
}

contract TestHelper {
    function test() external view returns (uint) {
        return helper(123);
    }
}

// Salted contract creation - create2
contract D {
    uint public x;
    constructor(uint a) {
        x = a;
    }
}
contract Create2 {
    function getBytes32(uint salt) external pure returns (bytes32) {
        return bytes32(salt);
    }

    function getAddress(bytes32 salt, uint arg) external view returns (address) {
        address addr = address(uint160(uint256(keccak256(abi.encodePacked(
            bytes1(0xff),
            address(this),
            salt,
            keccak256(abi.encodePacked(
                type(D).creationCode,
                arg
            ))
        )))));

        return addr;
    }

    address public deployedAddr;

    function createDSalted(bytes32 salt, uint arg) public {
        D d = new D{salt: salt}(arg);
        deployedAddr = address(d);
    }
}