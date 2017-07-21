Overview
========

This repository contains a transaction manager contract, allowing its owner
to make multiple contract calls in one Ethereum transaction. This saves time,
but what's most important it allows things like multi-step arbitrage to be
executed in one transaction. 

This transaction manager also helps to deal with ERC20 token transfers.
If we haven't done anything to solve this issue, the transaction manager contract
would have to own all funds (ERC20 tokens) any of the calls made by it may need.
In our approach, requested ERC20 tokens all transferred from the caller to
the transaction manager contract before the first call is made and returned
to the caller after the last call.

The transaction manager needs to be approved to access ERC20 tokens.
Because of that, the transaction manager can be used only by its owner. 


Contract deployment
===================

The `TxManager` contract takes no parameters.

Use Dapp (<https://github.com/dapphub/dapp>) to build and deploy
the contract:

```bash
dapp build
ETH_GAS=2000000 dapp deploy TxManager
```


Contract usage
==============

The contract has only one public function:

```
function execute(address[] tokens, bytes script) { … }
```

The `tokens` parameter is an array of ERC20 token addresses. For each of them,
the maximum available allowance will be transferred from the caller to the
contract before the first call. Remaining balances of each of these tokens
will be returned to the caller after the last call.

The `script` parameter is a byte array representing the sequence of
contract calls to be made. It consists of multiple call records concatenated
together, whereas each record is built as follows:

```
+----------------+-------------+----------------...------+
|     length     |   address   |         calldata        |
|                |             |                         |
|   (32 bytes)   |  (20 bytes) |                         |
+----------------+-------------+----------------...------+

```

`length` is the size of `address` and `calldata` in bytes.

For example, if you want to make one call to `0x11111222223333344444333332222211111122222`,
the script may look like this `000000000000000000000000000000000000000000000000000000000000003811111222223333344444333332222211111122222a39f1c6c0000000000000000000000000000000000000000000000000000000000000064`,
the last part of it being calldata encoded with:

```bash
$ seth calldata 'cork(uint256)' 100
0xa39f1c6c0000000000000000000000000000000000000000000000000000000000000064
```

The script parameter should be a concatenation of records of all calls to be made.
