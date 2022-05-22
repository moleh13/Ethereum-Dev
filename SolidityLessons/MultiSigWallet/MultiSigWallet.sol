// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/* Multi Sig Wallet
Topics

event 
array
mapping
struct
constructor
error
for loop
fallback and payable
function modifier
call
view function

Demo
1. Send Ether to an account
2. Call another contract

["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]
0xdD870fA1b7C4700F2BD7f44238821C26f7392148, 1000000000000000000, 0x
*/

contract MultiSigWallet {
    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(
        address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data
    );
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeTransaction(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

    address[] public owners;
    mapping(address => bytes32[]) public confirmedTransactions;
    uint public numConfirmationsRequired;
    mapping (address => bool) isOwner;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }


    Transaction[] public transactions;

    constructor(address[] memory _owners, uint _numConfirmationsRequired)  {
        require(_owners.length > 0, "owners required");
        require(_numConfirmationsRequired > 0
        && _numConfirmationsRequired <= _owners.length, "invalid number of required confirmations");

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        numConfirmationsRequired = _numConfirmationsRequired;
    }

    receive() payable external {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    //NOTE: helper function to easily deposit in Remix
    function deposit() payable external {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }


    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    function submitTransaction(address _to, uint _value, bytes memory _data) public onlyOwner {
        uint txIndex = transactions.length;
        
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            numConfirmations: 0
        }));

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        require(!isConfirmed(msg.sender, _txIndex));
       _;
    }

    

    function confirmTransaction(uint _txIndex) public 
        onlyOwner 
        txExists(_txIndex) 
        notExecuted(_txIndex) 
        notConfirmed(_txIndex) 
    {
        Transaction storage transaction = transactions[_txIndex];

        confirmedTransactions[msg.sender].push(keccak256(abi.encodePacked(_txIndex + 1)));
        transaction.numConfirmations += 1;

        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    function executeTransaction(uint _txIndex) 
        public 
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(
            transaction.numConfirmations >= numConfirmationsRequired,
            "cannot execute tx"
        );

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "tx failed");

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    function isConfirmed(address _addr, uint _txIndex) internal view returns (bool) {
        bool inside = false;
        
        for (uint i = 0; i < confirmedTransactions[_addr].length; i++) {
            if (confirmedTransactions[_addr][i] == keccak256(abi.encodePacked(_txIndex + 1))) {
                inside = true;
            }
        }

        return inside;
    }

    function revokeTransaction(uint _txIndex) 
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(isConfirmed(msg.sender, _txIndex), "tx not confirmed");

        for (uint i = 0; i < confirmedTransactions[msg.sender].length; i++) {
            if (confirmedTransactions[msg.sender][i] == keccak256(abi.encodePacked(_txIndex + 1))) {
                confirmedTransactions[msg.sender][i] = 0;
            }
        }
        transaction.numConfirmations -= 1;

        emit RevokeTransaction(msg.sender, _txIndex);
    }
}

contract TestContrac {
    uint public i;

    function callMe(uint j) public {
        i += j;
    }

    function getData() public pure returns (bytes memory)  {
        return abi.encodeWithSignature("callMe(uint256)", 123);
    }
}