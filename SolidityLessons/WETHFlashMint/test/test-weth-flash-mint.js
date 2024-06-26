const BN = require("bn.js")
const WETH_10 = "0xf4BB2e28688e89fCcE3c0580D37d36A7672E8A9F"

const IERC20 = artifacts.require("IERC20")
const TestWethFlashMint = artifacts.require("TestWethFlashMint")

contract("TestWethFlashMint", (accounts) => {
    let testWethFlashMint
    let weth 
    beforeEach(async () => {
        weth = await IERC20.at(WETH_10)
        testWethFlashMint = await TestWethFlashMint.new()

    })

    it("flash", async () => {
        const tx = await testWethFlashMint.flash()

        console.log(`contract: ${await testWethFlashMint.address}`)
        console.log(`sender: ${await testWethFlashMint.sender()}`)
        console.log(`token: ${await testWethFlashMint.token()}`)

        for (const log of tx.logs) {
            console.log(`${log.args.name} ${log.args.val}`)
        }
    })
})