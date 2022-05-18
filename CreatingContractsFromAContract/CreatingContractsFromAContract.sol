//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/*
Contarct that creates other contracts

How is it useful?
- pass fixed inputs to a new contract
- manage many contracts from a single contract

Examples
- create a new contract
- send ether and create a new contract
*/

contract Car {
    string public model;
    address public owner;

    constructor(string memory _model, address _owner) payable {
        model = _model;
        owner = _owner;
    }
}

contract CarFactory {
    Car[] public cars;

    function create(string memory _model) public {
        Car car = new Car(_model, address(this));
        cars.push(car);
    }

    function createAndSendEther(address _owner, string memory _model) public payable {
        Car car = (new Car){value: msg.value}(_model, _owner);
        cars.push(car);
        // contract.func{value: 1 ether}(x, y, z)
        // (new contract){value: 1 ether}(a, b, c)
    }
}

