const IERC20 = artifacts.require("IERC20");

contract("IERC20", (accounts) => {
    const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
    const DAI_WHALE = "0x28c6c06298d514db089934071355e5743bf21d60";
    it("get DAI balance", async () => {
        const dai = await IERC20.at(DAI);
        const bal = await dai.balanceOf(DAI_WHALE);
        console.log(`bal: ${bal}`);
    });

    it("should transfer", async () => {
        const dai = await IERC20.at(DAI);
        const bal = await dai.balanceOf(DAI_WHALE);
        await dai.transfer(accounts[0], bal, { from: DAI_WHALE });
    });
});