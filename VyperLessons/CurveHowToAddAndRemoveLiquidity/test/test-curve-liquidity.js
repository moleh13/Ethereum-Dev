const BN = require("bn.js")
const { sendEther, pow } = require("./util")

const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const USDT = "0xdAC17F958D2ee523a2206206994597C13D831ec7";
const WETH_WHALE = "0xe78388b4ce79068e89bf8aa7f218ef6b9ab0e9d0";
const DAI_WHALE = "0x28c6c06298d514db089934071355e5743bf21d60";
const USDC_WHALE = "0x47ac0fb4f2d84898e4d9e7b4dab3c24507a6d503";
const USDT_WHALE = "0x5754284f345afc66a98fbb0a0afe71e0f007b949";
const ROUTER = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";

const IERC20 = artifacts.require("IERC20")
const CurveHowToAddAndRemoveLiquidity = artifacts.require("CurveHowToAddAndRemoveLiquidity")

contract("CurveHowToAddAndRemoveLiquidity", (accounts) => {
    const WHALE = USDC_WHALE
    const TOKEN = USDC
    const TOKEN_INDEX = 1
    const DECIMALS = 6
    const TOKEN_AMOUNT = pow(10, DECIMALS).mul(new BN(1000))

    let testContract
    let token
    beforeEach(async () => {
        token = await IERC20.at(TOKEN)
        testContract = await CurveHowToAddAndRemoveLiquidity.new()

        await sendEther(web3, accounts[0], WHALE, 1)

        const bal = await token.balanceOf(WHALE)
        assert(bal.gte(TOKEN_AMOUNT), "balance < TOKEN_AMOUNT")

        await token.transfer(testContract.address, TOKEN_AMOUNT, {
            from: WHALE,
        })
    })

    it("add / remove liquidity", async () => {
        // add liquidity
        await testContract.addLiquidity()
        let shares = await testContract.getShares()

        console.log(`--- add liquidity ---`)
        console.log(`shares: ${shares}`)

        // remove liquidity
        await testContract.removeLiquidity()
        let bals = await testContract.getBalances()

        console.log(`--- remove liquidity ---`)
        console.log(`DAI: ${bals[0]}`)
        console.log(`USDC: ${bals[1]}`)
        console.log(`USDT: ${bals[2]}`)

        // add liquidity
        await testContract.addLiquidity()
        shares = await testContract.getShares()

        console.log(`--- add liquidity ---`)
        console.log(`shares: ${shares}`)

        const calc = await testContract.calcWithdrawOneCoin(TOKEN_INDEX)

        console.log(`--- calc withdraw one coin ---`)
        console.log(`calc_withdraw_one_coin: ${calc[0]}`)
        console.log(`shares * virtual price: ${calc[1]}`)

        // remove liquidity one coin
        await testContract.removeLiquidityOneCoin(TOKEN_INDEX)
        bals = await testContract.getBalances()

        console.log(`--- remove liquidity one coin ---`)
        console.log(`DAI: ${bals[0]}`)
        console.log(`USDC: ${bals[1]}`)
        console.log(`USDT: ${bals[2]}`)
    })
})