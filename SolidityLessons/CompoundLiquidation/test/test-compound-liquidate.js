const { time } = require("@openzeppelin/test-helpers")
const assert = require("assert")
const BN = require("bn.js")
const { sendEther, pow } = require("./util")
const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F"
const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
const USDT = "0xdAC17F958D2ee523a2206206994597C13D831ec7"
const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
const WBTC = "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599"
const CDAI = "0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643"
const CUSDC = "0x39AA39c021dfbaE8faC545936693aC917d5E7563"
const CWBTC = "0xccF4429DB6322D5C611ee964527D42E5d685DD6a"
const CETH = "0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5"
const DAI_WHALE = "0x075e72a5edf65f0a5f44699c7654c1a76941ddc8"
const WBTC_WHALE = "0xe78388b4ce79068e89bf8aa7f218ef6b9ab0e9d0"
const { web3 } = require("@openzeppelin/test-helpers/src/setup")

const IERC20 = artifacts.require("IERC20")
const CErc20 = artifacts.require("CErc20")
const TestCompoundLiquidate = artifacts.require("TestCompoundLiquidate")
const CompoundLiquidator = artifacts.require("CompoundLiquidator")

contract("TestCompoundLiquidate", (accounts) => {
    const SUPPLY_WHALE = WBTC_WHALE
    const TOKEN_SUPPLY = WBTC
    const C_TOKEN_SUPPLY = CWBTC
    const TOKEN_BORROW = DAI
    const C_TOKEN_BORROW = CDAI
    const LIQUIDATOR = DAI_WHALE

    const SUPPLY_DECIMALS = 8
    const SUPPLY_AMOUNT = pow(10, SUPPLY_DECIMALS).mul(new BN(1))
    const BORROW_DECIMALS = 18

    let testCompound 
    let tokenSupply 
    let cTokenSupply 
    let tokenBorrow 
    let cTokenBorrow 
    let liquidator 
    beforeEach(async () => {
        await sendEther(web3, accounts[0], SUPPLY_WHALE, 1)
        await sendEther(web3, accounts[0], LIQUIDATOR, 1)

        testCompound = await TestCompoundLiquidate.new(TOKEN_SUPPLY, C_TOKEN_SUPPLY, TOKEN_BORROW, C_TOKEN_BORROW)
        tokenSupply = await IERC20.at(TOKEN_SUPPLY)
        cTokenSupply = await CErc20.at(C_TOKEN_SUPPLY)
        tokenBorrow = await IERC20.at(TOKEN_BORROW)
        cTokenBorrow = await CErc20.at(C_TOKEN_BORROW)
        liquidator = await CompoundLiquidator.new(TOKEN_BORROW, C_TOKEN_BORROW)

        const supplyBal = await tokenSupply.balanceOf(SUPPLY_WHALE)
        console.log(`supply whale balance: ${supplyBal.div(pow(10, SUPPLY_DECIMALS))}`)
        assert(supplyBal.gte(SUPPLY_AMOUNT), "bal < supply")
    })

    const snapshot = async (testCompound, liquidator) => {
        const supplied = await testCompound.getSupplyBalance.call()
        const borrowed = await testCompound.getBorrowBalance.call()
        const colFactor = await testCompound.getCollateralFactor()
        const { liquidity, shortfall } = await testCompound.getAccountLiquidity()
        const price = await testCompound.getPriceFeed(C_TOKEN_BORROW)
        const closeFactor = await liquidator.getCloseFactor()
        const incentive = await liquidator.getLiquidationIncentive()
        const liquidated = await liquidator.getSupplyBalance.call(C_TOKEN_SUPPLY)

        return {
            colFactor: colFactor.div(pow(10, 18 - 2)),
            supplied: supplied.div(pow(10, SUPPLY_DECIMALS - 2)) / 100,
            borrowed: borrowed.div(pow(10, BORROW_DECIMALS - 2)) / 100,
            price: price.div(pow(10, 18 - 2)) / 100,
            liquidity: liquidity.div(pow(10, 14)) / 10000,
            shortfall: shortfall.div(pow(10, 14)) / 10000,
            closeFactor: closeFactor.div(pow(10, 18 - 2)),
            incentive: incentive.div(pow(10, 18 - 2)) / 100,
            liquidated: liquidated.div(pow(10, SUPPLY_DECIMALS - 4)) / 10000,
        }
    }

    it("should liquidate", async () => {
        // used for debugging
        let tx
        let snap

        // supply
        await tokenSupply.approve(testCompound.address, SUPPLY_AMOUNT, {
            from: SUPPLY_WHALE,
        })
        tx = await testCompound.supply(SUPPLY_AMOUNT, {
            from: SUPPLY_WHALE,
        })

        snap = await snapshot(testCompound, liquidator)
        console.log(`--- supplied ---`)
        console.log(`col factor: ${snap.colFactor} %`)
        console.log(`supplied: ${snap.supplied}`)

        // enter market
        tx = await testCompound.enterMarket({ from: accounts[0] })

        // borrow
        const { liquidity } = await testCompound.getAccountLiquidity()
        const price = await testCompound.getPriceFeed(C_TOKEN_BORROW)
        const maxBorrow = liquidity.mul(pow(10, BORROW_DECIMALS)).div(price)
        // NOTE: tweak borrow amount if borrow fails
        const borrowAmount = maxBorrow.mul(new BN(9997)).div(new BN(10000))

        console.log(`--- entered market ---`)
        console.log(`liquidity: $ ${liquidity.div(pow(10, 18))}`)
        console.log(`price: $ ${price.div(pow(10, 18))}`)
        console.log(`max borrow: ${maxBorrow.div(pow(10, 18))}`)
        console.log(`borrow amount: ${borrowAmount.div(pow(10, 18))}`)

        tx = await testCompound.borrow(borrowAmount, { from: accounts[0] })

        snap = await snapshot(testCompound, liquidator)
        console.log(`--- borrowed ---`)
        console.log(`liquidity: $ ${snap.liquidity}`)
        console.log(`borrowed: ${snap.borrowed}`)

        // accrue interest on borrow
        const block = await web3.eth.getBlockNumber()
        // NOTE: tweak this to increase borrowed amount
        await time.advanceBlockTo(block + 100)

        // send any tx to Compound to update liquidity and shortfall
        await testCompound.getBorrowBalance()

        snap = await snapshot(testCompound, liquidator)
        console.log(`--- after some blocks ---`)
        console.log(`liquidity: $ ${snap.liquidity}`)
        console.log(`shortfall: $ ${snap.shortfall}`)
        console.log(`borrowed: ${snap.borrowed}`)

        // liquidate
        const closeFactor = await liquidator.getCloseFactor()
        const repayAmount = (await testCompound.getBorrowBalance.call()).mul(closeFactor).div(pow(10, 18))

        const liqBal = await tokenBorrow.balanceOf(LIQUIDATOR)
        console.log(`liquidator balance: ${liqBal.div(pow(10, BORROW_DECIMALS))}`)
        assert(liqBal.gte(repayAmount), "bal < repay")

        const amountToBeLiquidated = await liquidator.getAmountToBeLiquidated(C_TOKEN_BORROW, C_TOKEN_SUPPLY, repayAmount)
        console.log(
            `amount to be liquidated (cToken collateral): ${amountToBeLiquidated.div(pow(10, SUPPLY_DECIMALS - 2)) / 100}`
        )

        await tokenBorrow.approve(liquidator.address, repayAmount, {
            from: LIQUIDATOR
        })
        tx = await liquidator.liquidate(testCompound.address, repayAmount, C_TOKEN_SUPPLY, {
            from: LIQUIDATOR
        })

        snap = await snapshot(testCompound, liquidator)
        console.log(`--- liquidated ---`)
        console.log(`close factor: ${snap.closeFactor} %`)
        console.log(`liquidation incentive: ${snap.incentive}`)
        console.log(`supplied: ${snap.supplied}`)
        console.log(`liquidity: ${snap.liquidity}`)
        console.log(`shortfall: ${snap.shortfall}`)
        console.log(`borrowed: ${snap.borrowed}`)
        console.log(`liquidated: ${snap.liquidated}`)

        /* memo
        c = 31572
        r = c * 0.65 * 0.5
        b = 1
        i = 1.08
        r * i * b / c
        */
    })
})