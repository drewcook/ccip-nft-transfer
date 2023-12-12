-include .env

# These have already been deployed
# https://sepolia.etherscan.io/address/0xFE34895B4113c6c8431620B349C599e68B6AC4A6
ETHEREUM_CONTRACT := 0xFE34895B4113c6c8431620B349C599e68B6AC4A6
# https://sepolia.arbiscan.io/address/0x9B5F6Aa927802A8129CdD8d52888020d7EEacA02
ARBITRUM_CONTRACT := 0x9B5F6Aa927802A8129CdD8d52888020d7EEacA02

# Step 1 - Deploy on Ethereum Sepolia network
deployEthereum :; forge create --rpc-url ethereumSepolia --private-key $(ALT_PRIVATE_KEY) src/XNFT.sol:XNFT --constructor-args 0x0bf3de8c5d3e8a2b34d2beeb17abfcebaf363a59 0x779877A7B0D9E8603169DdbD7836e478b4624789 16015286601757825753 --verify --etherscan-api-key $ETHERSCAN_API_KEY

# Step 2 - Deploy on Arbitrum Sepolia network
deployArbitrum :; forge create --rpc-url arbitrumTestnet --private-key $(ALT_PRIVATE_KEY) src/XNFT.sol:XNFT --constructor-args 0x2a9c5afb0d0e4bab2bcdae109ec4b0c4be15a165 0xb1D4538B4571d411F07960EF2838Ce337FE1E80E 3478487238524512106 --verify --etherscan-api-key $ETHERSCAN_API_KEY

# Step 3 - Enable Arbitrum Sepolia chain as a source chain
enableArbitrumChain :; cast send $(ETHEREUM_CONTRACT) --rpc-url ethereumSepolia --private-key $(ALT_PRIVATE_KEY) "enableChain(uint64,address,bytes)" 3478487238524512106 $(ARBITRUM_CONTRACT) 0x97a657c90000000000000000000000000000000000000000000000000000000000030d40

# Step 4 - Enable Ethereum Sepolia chain as a destination chain
enableEthereumChain :; cast send $(ARBITRUM_CONTRACT) --rpc-url arbitrumSepolia --private-key $(ALT_PRIVATE_KEY) "enableChain(uint64,address,bytes)" 16015286601757825753 $(ETHEREUM_CONTRACT) 0x97a657c90000000000000000000000000000000000000000000000000000000000030d40

# Step 5 - Transfer LINK tokens to the Arbitrum Sepolia contract to pay for CCIP fees

# Step 6 - Mint a token
mintToken :; cast send $(ARBITRUM_CONTRACT) --rpc-url arbitrumSepolia --private-key $(ALT_PRIVATE_KEY) "mint()"

# Step 7 - Transfer a token from Arbitrum Sepolia to Ethereum Sepolia
transferToken :; cast send $(ARBITRUM_CONTRACT) --rpc-url arbitrumSepolia --private-key $(ALT_PRIVATE_KEY) "crossChainTransferFrom(address,address,uint256,uint64,uint8)" 0x847F115314b635F58A53471768D14E67e587cb56 0x5B4C6e68637618285d2792d2934dF552E23c62C2 0 16015286601757825753 1