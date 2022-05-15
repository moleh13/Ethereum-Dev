// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ReceiveEther {
    fallback() external payable {}

    function getBalance() public view returns(uint) {
        return(address(this).balance);
    }
}

contract SendEther {
    function sendViaTransfer(address payable _to) public payable {
        _to.transfer(msg.value);
    } 

    function sendViaSend(address payable _to) public payable {
        bool sent = _to.send(msg.value);
        require(sent, "Failed to send Ether");
    }

    function sendViaCall(address payable _to) public payable {
        //_to.call{value: msg.value, gas: 1000}("");
        (bool sent, bytes memory data) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
}