const BN = require("bn.js");
const { sendEther, pow } = require("./util");
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
const TestUniswapOptimal = artifacts.require("TestUniswapOptimal")

contract("TestUniswapOptimal", (accounts) => {
  const WHALE = DAI_WHALE
  const AMOUNT = pow(10, 18).mul(new BN(1000))

  let contract
  let fromToken
  let toToken
  let pair
  beforeEach(async () => {
    fromToken = await IERC20.at(DAI)
    toToken = await IERC20.at(WETH)
    contract = await TestUniswapOptimal.new()
    pair = await IERC20.at(await contract.getPair(fromToken.address, toToken.address))

    await sendEther(web3, accounts[0], WHALE, 1)
    await fromToken.approve(contract.address, AMOUNT, { from: WHALE })
  })

  const snapshot = async () => {
    return {
      lp: await pair.balanceOf(contract.address),
      fromToken: await fromToken.balanceOf(contract.address),
      toToken: await toToken.balanceOf(contract.address),
    }
  }

  it("optimal swap", async () => {
    // const before = await snapshot()
    await contract.zap(fromToken.address, toToken.address, AMOUNT, {
      from: WHALE,
    })
    const after = await snapshot()

    console.log("lp", after.lp.toString())
    console.log("from", after.fromToken.toString())
    console.log("to", after.toToken.toString())
    /*
    lp 8763217073660280308
    from 0
    to 0
    */
  })

  it("sub-optimal swap", async () => {
    // const before = await snapshot()
    await contract.subOptimalZap(fromToken.address, toToken.address, AMOUNT, {
      from: WHALE,
    })
    const after = await snapshot()
    console.log("lp", after.lp.toString())
    console.log("from", after.fromToken.toString())
    console.log("to", after.toToken.toString())
    /*
    lp 8751087326229174004
    from 1461445165602623834
    to 0
    */
  })
})