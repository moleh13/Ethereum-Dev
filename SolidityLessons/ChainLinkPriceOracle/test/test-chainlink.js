const TestChainlink = artifacts.require("TestChainlink")

const WBTC = "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599"
const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F"
const WBTC_WHALE = "0xe78388b4ce79068e89bf8aa7f218ef6b9ab0e9d0"
const DAI_WHALE = "0x075e72a5edf65f0a5f44699c7654c1a76941ddc8"
const CWBTC = "0xccF4429DB6322D5C611ee964527D42E5d685DD6a"
const CDAI = "0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643"
const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"

contract("TestChainlink", () => {
    let testChainlink
    beforeEach(async () => {
        testChainlink = await TestChainlink.new()
    })

    it("getLatestPrice", async () => {
        const price = await testChainlink.getLatestPrice()
        console.log(`price: ${price}`)
    })
})