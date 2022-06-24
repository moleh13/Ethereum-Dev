// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// create2 - deterministically precompute contract address
// code
// demo

contract Factory {
    event Deployed(address addr, uint256 salt);
    
    // 1. Get bytecode of contract to be deployed
    function getByteCode(address _owner, uint _foo) public pure returns (bytes memory) {
        bytes memory bytecode = type(TestContract).creationCode;
        return abi.encodePacked(bytecode, abi.encode(_owner, _foo));
    }
    
    // 2. Compute the address of the contract to be deployed
    // keccak256(0xff + sender address + salt + keccak256(creation code))
    // take last 20 bytes
    function getAddress(bytes memory bytecode, uint _salt) public view returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                _salt,
                keccak256(bytecode)
            )
        );
        // cast last 20 bytes of hash to address
        return address(uint160(uint256(hash)));
    }

    // 3. Deploy the contract
    function deploy(bytes memory bytecode, uint _salt) public payable {
        address addr;

        /*
        How to call create2

        create2(v, p, n, s)
        v - amount of ETH to send
        p - pointer to start of code in memory
        n - size of code
        s - salt
        */
        assembly {
            addr := create2(
                callvalue(), // wei sent with current call
                // Actual code starts after skipping the first 32 bytes
                add(bytecode, 0x20),
                mload(bytecode), // Load the size of code contained in the first 32 bytes
                _salt // Salt from function arguments
            )

            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        emit Deployed(addr, _salt);
    }
}

contract TestContract {
    address public owner;
    uint public foo;

    constructor(address _owner, uint _foo) payable {
        owner = _owner;
        foo = _foo;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}