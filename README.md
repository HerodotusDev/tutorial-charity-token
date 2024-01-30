# Solidity Contracts

1. Get your Private Key from MetaMask
2. Get Infura, Alchemy or any other provider rpc url for Goerli Testnet
3. Get etherscan API Key
4. Code the contract
5. Deploy: `source .env && forge script script/Deploy.s.sol --rpc-url $GOERLI_RPC_URL --private-key $PRIVATE_KEY --broadcast -vvv --etherscan-api-key $ETHERSCAN_API_KEY --verify`
6. See the deployed contract: https://goerli.etherscan.io/address/0xE094D4b0DA108Ed7bd7a5b6163EDA187eAAA4056
7. Check storage layout: `forge inspect Charity storage-layout --pretty`
8. benefactors mapping is at slot 0
