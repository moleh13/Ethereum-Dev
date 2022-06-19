//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract SaveGas {
    uint public n = 5;

    function noCache() external view returns (uint) {
        uint s = 0;
        for (uint i = 0; i < n; i++) {
            s += 1;
        }

        return s; 
    }

    function cache() external view returns (uint) {
        uint s = 0;
        uint _n = n;
        for (uint i = 0; i < _n; i++) {
            s += 1;
        }

        return s;
    }
}

/*
## no cache ##
n    | gas
------------
5    | 5430
10   | 9780
100  | 88102
1000 | 871080

## cache ##
n    | gas
------------
5    | 1421
10   | 1771
100  | 8071
1000 | 71071
*/
