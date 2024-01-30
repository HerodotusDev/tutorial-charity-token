# Solidity Contracts

1. Install Foundry
2. Get your Private Key from MetaMask
3. Get Infura, Alchemy or any other provider rpc url for Goerli Testnet
4. Get etherscan API Key
5. Code the contract
6. Deploy: `source .env && forge script script/Deploy.s.sol --rpc-url $GOERLI_RPC_URL --private-key $PRIVATE_KEY --broadcast -vvv --etherscan-api-key $ETHERSCAN_API_KEY --verify`
7. See the deployed contract: https://goerli.etherscan.io/address/0x35A66288531947fc90Fb343D0A639f20A8f00369
8. Check storage layout: `forge inspect Charity storage-layout --pretty`
9. benefactors mapping is at slot 0

# Cairo Contracts

1. Install Scarb
2. https://github.com/HerodotusDev/herodotus-on-starknet/blob/develop/src/core/evm_facts_registry.cairo
3.

source .env && forge script script/Deploy.s.sol --broadcast -vvv --verify
