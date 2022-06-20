const BN = require("bn.js")
const { sendEther, pow } = require("./util.js")

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
const CurveExchange = artifacts.require("CurveExchange")

contract("CurveExchange", (accounts) => {
    const WHALE = USDC_WHALE
    const TOKEN_IN = USDC
    const TOKEN_IN_INDEX = 1
    const TOKEN_OUT = USDT
    const TOKEN_OUT_INDEX = 2
    const DECIMALS = 6
    const TOKEN_IN_AMOUNT = pow(10, DECIMALS).mul(new BN(1000000))

    let testContract
    let tokenIn
    let tokenOut
    beforeEach(async () => {
        tokenIn = await IERC20.at(TOKEN_IN)
        tokenOut = await IERC20.at(TOKEN_OUT)
        testContract = await CurveExchange.new()

        await sendEther(web3, accounts[0], WHALE, 1)

        const bal = await tokenIn.balanceOf(WHALE)
        assert(bal.gte(TOKEN_IN_AMOUNT), "balance < TOKEN_IN_AMOUNT")

        await tokenIn.transfer(testContract.address, TOKEN_IN_AMOUNT, {
            from: WHALE,
        })
    })

    it("exchange", async () => {
        const snapshot = async () => {
            return {
                tokenOut: await tokenOut.balanceOf(testContract.address),
            }
        }

        // const before = await snapshot()
        await testContract.swap(TOKEN_IN_INDEX, TOKEN_OUT_INDEX)
        const after = await snapshot()

        console.log(`Token out: ${after.tokenOut}`)
    })
})