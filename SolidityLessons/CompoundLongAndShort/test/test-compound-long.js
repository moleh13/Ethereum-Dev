const { time } = require("@openzeppelin/test-helpers")
const assert = require("assert")
const BN = require("bn.js")
const { sendEther, pow, frac } = require("./util")

const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F"
const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
const USDT = "0xdAC17F958D2ee523a2206206994597C13D831ec7"
const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
const WBTC = "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599"
const CDAI = "0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643"
const CUSDC = "0x39AA39c021dfbaE8faC545936693aC917d5E7563"
const CWBTC = "0xccF4429DB6322D5C611ee964527D42E5d685DD6a"
const CETH = "0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5"
const WBTC_WHALE = "0xe78388b4ce79068e89bf8aa7f218ef6b9ab0e9d0"
const DAI_WHALE = "0x075e72a5edf65f0a5f44699c7654c1a76941ddc8"

const { web3 } = require("@openzeppelin/test-helpers/src/setup")

const IERC20 = artifacts.require("IERC20")
const TestCompoundLong = artifacts.require("TestCompoundLong")

contract("TestCompoundLong", (accounts) => {
    const ETH_WHALE = accounts[0]
    const TOKEN_BORROW = DAI
    const C_TOKEN_BORROW = CDAI
    const REPAY_WHALE = DAI_WHALE

    const ETH_AMOUNT = pow(10, 18).mul(new BN(10))
    const BORROW_DECIMALS = 18
    const BORROW_INTEREST = pow(10, BORROW_DECIMALS).mul(new BN(1000))

    let testCompound
    let tokenBorrow
    beforeEach(async () => {
        testCompound = await TestCompoundLong.new(CETH, C_TOKEN_BORROW, TOKEN_BORROW, 18)
        tokenBorrow = await IERC20.at(TOKEN_BORROW)

        const borrowBal = await tokenBorrow.balanceOf(REPAY_WHALE)
        console.log(`repay whale balance: ${borrowBal.div(pow(10, BORROW_DECIMALS))}`)
        assert(borrowBal.gte(BORROW_INTEREST), "bal < borrow interest")
    })

    const snapshot = async (testCompound, tokenBorrow) => {
        const maxBorrow = await testCompound.getMaxBorrow()
        const ethBal = await web3.eth.getBalance(testCompound.address)
        const tokenBorrowBal = await tokenBorrow.balanceOf(testCompound.address)
        const supplied = await testCompound.getSuppliedBalance.call()
        const borrowed = await testCompound.getBorrowBalance.call()
        const { liquidity } = await testCompound.getAccountLiquidity()

        return {
            maxBorrow,
            eth: new BN(ethBal),
            tokenBorrow: tokenBorrowBal,
            supplied,
            borrowed,
            liquidity,
        }
    }

    it("should long", async () => {

        let tx
        let snap

        tx = await testCompound.supply({
            from: ETH_WHALE,
            value: ETH_AMOUNT
        })

        snap = await snapshot(testCompound, tokenBorrow)
        console.log(`--- supplied ---`)
        console.log(`liquidity: ${snap.liquidity.div(pow(10, 18))}`)
        console.log(`max borrow: ${snap.maxBorrow.div(pow(10, BORROW_DECIMALS))}`)

        const maxBorrow = await testCompound.getMaxBorrow()
        const borrowAmount = frac(maxBorrow, 50, 100)
        console.log(`borrow amount: ${borrowAmount.div(pow(10, BORROW_DECIMALS))}`)
        tx = await testCompound.long(borrowAmount, { from: ETH_WHALE })

        snap = await snapshot(testCompound, tokenBorrow)
        console.log(`--- long ---`)
        console.log(`liquidity: ${snap.liquidity.div(pow(10, 18))}`)
        console.log(`borrowed: ${snap.borrowed.div(pow(10, BORROW_DECIMALS))}`)
        console.log(`eth: ${snap.eth.div(pow(10, 18))}`)

        const block = await web3.eth.getBlockNumber()
        await time.advanceBlockTo(block + 100)

        await tokenBorrow.transfer(testCompound.address, BORROW_INTEREST, { from: REPAY_WHALE })
        tx = await testCompound.repay({
            from: ETH_WHALE
        })

        snap = await snapshot(testCompound, tokenBorrow)
        console.log(`--- repay ---`)
        console.log(`liquidity: ${snap.liquidity.div(pow(10, 18))}`)
        console.log(`borrowed: ${snap.borrowed.div(pow(10, BORROW_DECIMALS))}`)
        console.log(`eth: ${snap.eth.div(pow(10, 18))}`)
        console.log(`token borrow: ${snap.tokenBorrow.div(pow(10, BORROW_DECIMALS))}`)
    })
})