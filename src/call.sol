pragma solidity ^0.4.11;

import "erc20/erc20.sol";

contract ProxyCall { 
	function call()
	{
        address token = 0x224c2202792B11c5ac5bAaAA8284e6edb60f7174;
        address source = 0x002ca7F9b416B2304cDd20c26882d1EF5c53F611;
        address target = 0x00348E4084567Ce2E962B64ABe5A54BaB256Bc26;

        //ERC20(token).transferFrom(source, target, 10 wei);
        ERC20(token).transferFrom(msg.sender, target, 10 wei);
        //ERC20(token).transfer(target, 10 wei);

        //ERC20(token).transferFrom(target, source, 4 wei);
        assembly {
            // 0x23b872dd00000000000000000000000000348e4084567ce2e962b64abe5a54bab256bc26000000000000000000000000002ca7f9b416b2304cdd20c26882d1ef5c53f6110000000000000000000000000000000000000000000000000000000000000004
            mstore(0x2000, 0x23b872dd00000000000000000000000000348e4084567ce2e962b64abe5a54ba)
            mstore(0x2020, 0xb256bc26000000000000000000000000002ca7f9b416b2304cdd20c26882d1ef)
            mstore(0x2040, 0x5c53f61100000000000000000000000000000000000000000000000000000000)
            mstore(0x2060, 0x0000000400000000000000000000000000000000000000000000000000000000)
            let succeeded := call(sub(gas, 5000), token, 0, 0x2000, 0x64, 0, 0)
            jumpi(invalidJumpLabel, iszero(succeeded))
        }
	}
}

contract TransactionManager {

    function execute(bytes balances, bytes steps) {
        // transfer balances from the caller to the contract
        for (uint i = 0; i < balances.length/52; i++) {
            address token = getAddressAt(balances, 0x34*i);
            uint256 value = getWordAt(balances, 0x34*i + 0x14);
            ERC20(token).transferFrom(msg.sender, this, value);
        }

        // execute steps
        uint256 stepLocation = 0;
        while (stepLocation < steps.length) {
            uint256 stepLength = getWordAt(steps, stepLocation);
            //TODO
        }
        // TODO

        // transfer remaining balances back to the caller
        for (uint i2 = 0; i2 < balances.length/52; i2++) {
            address token2 = getAddressAt(balances, 0x34*i2);
            ERC20(token2).transfer(msg.sender, ERC20(token2).balanceOf(this));
        }
    }

    function getWordAt(bytes array, uint256 location) internal returns (uint256 result) {
        assembly {
            result := mload(add(array, add(0x20, location)))
        }
    }

    function getAddressAt(bytes array, uint256 location) internal returns (address result) {
        uint256 word = getWordAt(array, location);
        assembly {
            result := div(and(word, 0xffffffffffffffffffffffffffffffffffffffff000000000000000000000000), 0x1000000000000000000000000)
        }
    }
}

