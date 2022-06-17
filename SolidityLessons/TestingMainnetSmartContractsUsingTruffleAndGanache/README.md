# Testing Truffle Contracts with Ganache Mainnet Fork

### Setup

- infura API
- npm install truffle ganache-cli
- edit truffle config

### Test example

- query mainnet DAI balance
- unlock account and transfer DAI

DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F
DAI_WHALE=0x28c6c06298d514db089934071355e5743bf21d60

INFURA_API_KEY=a4155fc243904279b40139e3bbebf282

ganache-cli --fork https://mainnet.infura.io/v3/$INFURA_API_KEY \
--unlock $DAI_WHALE
--networkId 999