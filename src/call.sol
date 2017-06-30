pragma solidity ^0.4.11;

import "erc20/erc20.sol";

contract ProxyCall { 
	function call()
	{
        address token = 0x224c2202792B11c5ac5bAaAA8284e6edb60f7174;
        address source = 0x002ca7F9b416B2304cDd20c26882d1EF5c53F611;
        address target = 0x00348E4084567Ce2E962B64ABe5A54BaB256Bc26;

        ERC20(token).transferFrom(source, target, 10 wei);
	}
}
