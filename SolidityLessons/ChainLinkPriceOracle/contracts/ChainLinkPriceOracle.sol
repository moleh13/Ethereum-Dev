// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract TestChainLink {
    AggregatorV3Interface internal priceFeed;

    constructor() {
        // ETH / USD
        priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    }

    function getLatestPrice() public view returns (int) {
        (
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRount
        ) = priceFeed.latestRoundData();
        // For ETH / USD price is scaled up by 1e8
        return price / 1e8;
    }
}

interface AggregatorV3Interface {
    function latestRoundData()
    external
    view
    returns (
        uint80 roundId,
        int answer,
        uint startedAt,
        uint updatedAt,
        uint80 answeredInRound
    );

}