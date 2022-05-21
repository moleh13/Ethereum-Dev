// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
Library
- no storage, no ether
- helps you keep your code DRY (Don't Repeat Yourself)
    - add functionality types
    // uint x
    // x.myFuncFromLibrary()
- can save gas

Embedded or linked
- embedded (library has only internal functions)
- must be deployed and then linked (library has public or external functions)

Examples
- safe math (preven uint overflow)
- deleting element from array without gaps
*/

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint) {
        uint z = x + y;
        require(z >= x, "uint overflow");

        return z;
    }
}

contract TestSafeMath {
    using SafeMath for uint;
    // using A for B
    // attach functions from libary A to type B

    uint public MAX_UINT = 2 ** 256 - 1;

    uint x = 123;
    function testAdd(uint _x, uint _y) public pure returns(uint) {
        return _x.add(_y);
    }
}

library Array {
    function remove(uint[] storage arr, uint index) public {
        arr[index] = arr[arr.length - 1];
        arr.pop();
    }
}

contract TestArray {
    using Array for uint[];

    uint[] public arr;

    function testArrayRemove() public {
        for (uint i = 0; i < 3; i++) {
            arr.push(i);
        }
        // [0, 1, 2]

        arr.remove(1);

        // [0,2]
        assert(arr.length == 2);
        assert(arr[0] == 0);
        assert(arr[1] == 2);
    }
}
