// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Compound.sol";
import "./IERC20.sol";

// supply
// borrow max
// wait few blocks and let borrowed balance > supplied balance * col factor
// liquidate 

contract TestCompoundLiquidate {
    Comptroller public comptroller = Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);

    PriceFeed public priceFeed = PriceFeed(0x922018674c12a7F0D394ebEEf9B58F186CdE13c1);

    IERC20 public tokenSupply;
    CErc20 public cTokenSupply;
    IERC20 public tokenBorrow;
    CErc20 public cTokenBorrow;

    event Log(string message, uint val);

    constructor(
        address _tokenSupply,
        address _cTokenSupply,
        address _tokenBorrow,
        address _cTokenBorrow
    ) {
        tokenSupply = IERC20(_tokenSupply);
        cTokenSupply = CErc20(_cTokenSupply);

        tokenBorrow = IERC20(_tokenBorrow);
        cTokenBorrow = CErc20(_cTokenBorrow);
    }

    function supply(uint _amount) external {
        tokenSupply.transferFrom(msg.sender, address(this), _amount);
        tokenSupply.approve(address(cTokenSupply), _amount);
        require(cTokenSupply.mint(_amount) == 0, "mint failed");
    }

    //not view function
    function getSupplyBalance() external returns (uint) {
        return cTokenSupply.balanceOfUnderlying(address(this));
    }

    function getCollateralFactor() external view returns (uint) {
        (, uint colFactor, ) = comptroller.markets(address(cTokenSupply));
        return colFactor; // divide by 1e18 to get in %
    }

    function getAccountLiquidity()
    external
    view
    returns (uint liquidity, uint shortfall) {
        // liquidity and shorfall in USD scaled up by 1e18
        (uint error, uint _liquidity, uint _shortfall) = comptroller.getAccountLiquidity(
            address(this)
        );
        require(error == 0, "error");
        return (_liquidity, _shortfall);
    }

    function getPriceFeed(address _cToken) external view returns (uint) {
        // scaled up by 1e18
        return priceFeed.getUnderlyingPrice(_cToken);
    }

    function enterMarket() external {
        address[] memory cTokens = new address[](1);
        cTokens[0] = address(cTokenSupply);
        uint[] memory errors = comptroller.enterMarkets(cTokens);
        require(errors[0] == 0, "Comptroller.enterMarkets failed");
    }

    function borrow(uint _amount) external {
        require(cTokenBorrow.borrow(_amount) == 0, "borrow failed");
    }

    // not view function
    function getBorrowBalance() external returns (uint) {
        return cTokenBorrow.borrowBalanceCurrent(address(this));
    }
}

contract CompoundLiquidator {
    Comptroller public comptroller = Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);

    IERC20 public tokenBorrow;
    CErc20 public cTokenBorrow;

    constructor(address _tokenBorrow, address _cTokenBorrow) {
        tokenBorrow = IERC20(_tokenBorrow);
        cTokenBorrow = CErc20(_cTokenBorrow);
    }
    
    // close factor
    function getCloseFactor() external view returns (uint) {
        return comptroller.closeFactorMantissa();
    }

    // liquidation incentive
    function getLiquidationIncentive() external view returns (uint) {
        return comptroller.liquidationIncentiveMantissa();
    }

    // get amount of collateral to be liquidated
    function getAmountToBeLiquidated(
        address _cTokenBorrowed,
        address _cTokenCollateral,
        uint _actualRepayAmount
    ) external view returns (uint) {
        /*
        Get the exchange rate and calculate the number of the collateral token to seize:
        seizeAmount = actualRepayAmount * liquidationIncentive * priceBorrowed / priceCollateral
        seizeTokens = seizeAmounts / exchangeRate
        = actualRepayAmount * (liquidationIncentive * priceBorrowed) / (priceCollateral * exchangeRate)
        */
        (uint error, uint cTokenCollateralAmount) = comptroller
        .liquidateCalculateSeizeTokens(
            _cTokenBorrowed,
            _cTokenCollateral,
            _actualRepayAmount
        );

        require(error == 0, "error");

        return cTokenCollateralAmount;
    }

    // liquidate
    function liquidate(
        address _borrower,
        uint _repayAmount,
        address _cTokenCollateral
    ) external {
        tokenBorrow.transferFrom(msg.sender, address(this), _repayAmount);
        tokenBorrow.approve(address(cTokenBorrow), _repayAmount);

        require(
            cTokenBorrow.liquidateBorrow(_borrower, _repayAmount, _cTokenCollateral) == 0,
            "liquidation failed"
        );
    }

    // get amount liquidated
    // not view function
    function getSupplyBalance(address _cTokenCollateral) external returns (uint) {
        return CErc20(_cTokenCollateral).balanceOfUnderlying(address(this));
    }
}