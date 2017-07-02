#!/bin/sh

[ -z ${DS_PROXY} ] && echo "Please set DS_PROXY" && exit -1
[ -z ${ETH_FROM} ] && echo "Please set ETH_FROM" && exit -1

dapp clean
dapp build
seth send $DS_PROXY "execute(bytes,bytes)(bytes32)" $(cat out/TransactionManager.bin) $(seth calldata 'execute(bytes)' '0x224c2202792B11c5ac5bAaAA8284e6edb60f717400000000000000000000000000000000000000000000000000000000000000041a7fec975a131707cf0fbca0f53a56a9eed8956b0000000000000000000000000000000000000000000000000000000000000005')

