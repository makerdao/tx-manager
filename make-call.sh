#!/bin/sh

[ -z ${DS_PROXY} ] && echo "Please set DS_PROXY" && exit -1
[ -z ${ETH_FROM} ] && echo "Please set ETH_FROM" && exit -1

dapp clean
dapp build
seth send $DS_PROXY "execute(bytes,bytes)(bytes32)" $(cat out/ProxyCall.bin) $(seth calldata 'call()')

