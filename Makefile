build:; dapp build
test:; dapp test
deploy: build; ETH_GAS=2000000 dapp deploy TxManager
clean:; dapp clean
