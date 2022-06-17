// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/* 
Minimal Proxy Contract

- Why is it cheap to deploy contract? uses delegatecall
- Why is constructor not called? uses delegatecall
- Why is the original contract not affected? uses delegatecall
deploys a simple contract that forwards all calls using delegatecall
*/

contract PseudoMinimalProxy {
    address masterCopy;

    constructor(address _masterCopy) {
        // notice that constructor of master copy is not called
        masterCopy = _masterCopy;
    }

    function forward() external returns (bytes memory) {
        (bool success, bytes memory data) = masterCopy.delegatecall(msg.data);
        require(success);

        return data;
    }
}

// actual code
// 3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3

contract MinimalProxy {
    function clone(address target) external returns (address result) {
        // convert address to 20 bytes
        bytes20 targetBytes = bytes20(target);

        assembly {
            /*
            reads the 32 bytes of memory starting at pointer stored in 0x40

            In solidity, the 0x40 slot in memory is special: it contains the "free memory pointer"
            which points to the end of the currently allocated memory.
            */
            let clone := mload(0x40)
            // store 32 bytes to memory at "clone"
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)

            /*
                                20 bytes
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
                                                      ^
                                                      pointer
            */

            // store 32 bytes to memory starting at "clone" + 20 bytes
            // 0x14 = 20 
            mstore(add(clone, 0x14), targetBytes)

            /* 
              |               20 bytes               |                20 bytes               |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe
                                                                                              ^
                                                                                              pointer
            */
            // store 32 bytes to memory starting at "clone" + 40 bytes
            // 0x28 = 40
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

            /*
              |               20 bytes               |                20 bytes               |           15 bytes          |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3
            */
            // create new contract
            // send 0 Ether
            // code starts at pointer stored in "clone"
            // code size 0x37 (55 bytes)
            result := create(0, clone, 0x37)
        }   
    }
}