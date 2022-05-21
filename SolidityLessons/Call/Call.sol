//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/*
call - low level method available on address type 
examples
    - call exisiting function
    - call non-existing function (triggers the fallback function) 
*/

contract Receiver {
    event Received(address caller, uint amount, string message);
    
    fallback() external payable {
        emit Received(msg.sender, msg.value, "Fallback was called");
    }
    receive() external payable {}

    function foo(string memory _message, uint _x) public payable returns (uint) {
        emit Received(msg.sender, msg.value, _message);

        return _x + 1;
    }
}

contract Caller {
    event Response(bool success, bytes data);

    function testCallFoo(address payable _address) public payable {
        (bool success, bytes memory data) = _address.call{value: msg.value, gas: 5000}(
            abi.encodeWithSignature("foo(string,uint256)", "call foo", 123) 
        );

        emit Response(success, data);
    }

    function testCallDoesNotExist(address _address) public {
        (bool success, bytes memory data) = _address.call(
            abi.encodeWithSignature("DoesNotExist()") 
        );

        emit Response(success, data);
    }
}

