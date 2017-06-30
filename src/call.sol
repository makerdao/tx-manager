pragma solidity ^0.4.11;

import "erc20/erc20.sol";

contract ProxyCall { 
	function call()
	{
        address token = 0x224c2202792B11c5ac5bAaAA8284e6edb60f7174;
        address source = 0x002ca7F9b416B2304cDd20c26882d1EF5c53F611;
        address target = 0x00348E4084567Ce2E962B64ABe5A54BaB256Bc26;

        ERC20(token).transferFrom(source, target, 10 wei);

        //ERC20(token).transferFrom(target, source, 4 wei);
        assembly {
            // 0x23b872dd00000000000000000000000000348e4084567ce2e962b64abe5a54bab256bc26000000000000000000000000002ca7f9b416b2304cdd20c26882d1ef5c53f6110000000000000000000000000000000000000000000000000000000000000004
            mstore(0x2000, 0x23b872dd00000000000000000000000000348e4084567ce2e962b64abe5a54ba)
            mstore(0x2020, 0xb256bc26000000000000000000000000002ca7f9b416b2304cdd20c26882d1ef)
            mstore(0x2040, 0x5c53f61100000000000000000000000000000000000000000000000000000000)
            mstore(0x2060, 0x0000000400000000000000000000000000000000000000000000000000000000)
            let succeeded := call(sub(gas, 5000), token, 0, 0x2000, 0x64, 0, 32)
            jumpi(invalidJumpLabel, iszero(succeeded))
        }
	}
}
