const BN = require("bn.js");
const { sendEther, pow } = require("./util");

const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const WETH_WHALE = "0xe78388b4ce79068e89bf8aa7f218ef6b9ab0e9d0";
const DAI_WHALE = "0x075e72a5edf65f0a5f44699c7654c1a76941ddc8";

const IERC20 = artifacts.require("IERC20");
const TestUniswapLiquidity = artifacts.require("TestUniswapLiquidity");

contract("TestUniswapLiquidity", (accounts) => {
    const CALLER = accounts[0];
    const TOKEN_A = WETH;
    const TOKEN_B = DAI;
    const TOKEN_A_WHALE = WETH_WHALE;
    const TOKEN_B_WHALE = DAI_WHALE;
    const TOKEN_A_AMOUNT = pow(10, 18);
    const TOKEN_B_AMOUNT = pow(10, 18);

    let contract;
    let tokenA;
    let tokenB;
    beforeEach(async () => {
        tokenA = await IERC20.at(TOKEN_A);
        tokenB = await IERC20.at(TOKEN_B);
        contract = await TestUniswapLiquidity.new();
        
        //send ETH to cover tx fee
        await sendEther(web3, accounts[0], TOKEN_A_WHALE, 1);
        await sendEther(web3, accounts[0], TOKEN_B_WHALE, 1);

        await tokenA.transfer(CALLER, TOKEN_A_AMOUNT, { from: TOKEN_A_WHALE });
        await tokenB.transfer(CALLER, TOKEN_B_AMOUNT, { from: TOKEN_B_WHALE });

        await tokenA.approve(contract.address, TOKEN_A_AMOUNT, { from: CALLER });
        await tokenB.approve(contract.address, TOKEN_B_AMOUNT, { from: CALLER });
    });

    it ("add liquidity and remove liquidity", async () => {
        let tx = await contract.addLiquidity(
            tokenA.address,
            tokenB.address,
            TOKEN_A_AMOUNT,
            TOKEN_B_AMOUNT,
            {
                from: CALLER,
            }
        )
        console.log("=== add liquidity ===");
        for (const log of tx.logs) {
            console.log(`${log.args.message} ${log.args.val}`)
        }

        tx = await contract.removeLiquidity(tokenA.address, tokenB.address, {
            from: CALLER,
        });
        console.log("=== remove liquidity ===");
        for (const log of tx.logs) {
            console.log(`${log.args.message} ${log.args.val}`);
        }
    });
});



