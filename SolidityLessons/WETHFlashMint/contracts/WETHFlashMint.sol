// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./WETH10.sol";
import "./IERC20.sol";

contract TestWethFlashMint {
    address private WETH = 0xf4BB2e28688e89fCcE3c0580D37d36A7672E8A9F;
    bytes32 public immutable CALLBACK_SUCCESS = 
    keccak256("ERC3156FlashBorrower.onFlashLoan");

    address public sender;
    address public token;

    event Log(string name, uint val);
    
    function flash() external {
        uint total = IERC20(WETH).totalSupply();
        // borrow more than available
        uint amount = total + 1;

        emit Log("total supply", total);

        IERC20(WETH).approve(WETH, amount);

        bytes memory data = "";
        WETH10(WETH).flashLoan(address(this), WETH, amount, data);
    }

    // called by WETH10
    function onFlashLoan(
        address _sender,
        address _token,
        uint amount,
        uint fee,
        bytes calldata data
    ) external returns (bytes32) {
        // custom code
        uint bal = IERC20(WETH).balanceOf(address(this));
        sender = _sender;
        token = _token;

        emit Log("amount", amount);
        emit Log("fee", fee);
        emit Log("balance", bal);

        return CALLBACK_SUCCESS;
    }
}

