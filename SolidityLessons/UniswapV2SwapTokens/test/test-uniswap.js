const BN = require("bn.js");
const IERC20 = artifacts.require("IERC20");
const TestUniswap = artifacts.require("TestUniswap");

contract("TestUniswap", (accounts) => {
    const DAI = "0x6b175474e89094c44da98b954eedeac495271d0f"
    const DAI_WHALE = "0x28c6c06298d514db089934071355e5743bf21d60"
    const WBTC = "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599"

    const WHALE = DAI_WHALE;
    const AMOUNT_IN = new BN(10).pow(new BN(18)).mul(new BN(1000000));
    const AMOUNT_OUT_MIN = 1;
    const TOKEN_IN = DAI;
    const TOKEN_OUT = WBTC;
    const TO = accounts[0];

    it("should swap", async() => {
        const tokenIn = await IERC20.at(TOKEN_IN);
        const tokenOut = await IERC20.at(TOKEN_OUT);
        const testUniswap = await TestUniswap.new();

        await tokenIn.approve(testUniswap.address, AMOUNT_IN, { from: WHALE });
        await testUniswap.swap(
            tokenIn.address,
            tokenOut.address,
            AMOUNT_IN,
            AMOUNT_OUT_MIN,
            TO,
            {
                from: WHALE
            }
        );

        console.log(`out ${await tokenOut.balanceOf(TO)}`);
    });
});

// ganache-cli --fork https://mainnet.infura.io/v3/a4155fc243904279b40139e3bbebf282 --unlock 0x28c6c06298d514db089934071355e5743bf21d60