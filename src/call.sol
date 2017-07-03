pragma solidity ^0.4.11;

import "ds-auth/auth.sol";
import "ds-note/note.sol";
import "erc20/erc20.sol";

contract TransactionManager is DSAuth, DSNote {

    function execute(address[] tokens, bytes script) {
        // pull the entire amount of each token from the sender
        for (uint i = 0; i < tokens.length; i++)
            ERC20(tokens[i]).transferFrom(msg.sender, this, ERC20(tokens[i]).balanceOf(msg.sender));

        // sequentially call contacts, abort on failed calls
        invokeContracts(script);

        // returns remaining balances of each token to the sender
        for (uint j = 0; j < tokens.length; j++)
            ERC20(tokens[j]).transfer(msg.sender, ERC20(tokens[j]).balanceOf(this));
    }

    function invokeContracts(bytes script) internal {
        uint256 location = 0;
        while (location < script.length) {
            uint256 length = uint256At(script, location);

            address contractAddress = addressAt(script, location + 0x20);
            uint256 calldataStart = locationOf(script, location + 0x20 + 0x14);
            uint256 calldataLength = length - 0x14;
            assembly {
                let ok := call(sub(gas, 5000), contractAddress, 0, calldataStart, calldataLength, 0, 0)
                jumpi(invalidJumpLabel, iszero(ok))
            }

            location += (0x20 + length);
        }
    }

    function uint256At(bytes data, uint256 location) internal returns (uint256 result) {
        assembly {
            result := mload(add(data, add(0x20, location)))
        }
    }

    function addressAt(bytes data, uint256 location) internal returns (address result) {
        uint256 word = uint256At(data, location);
        assembly {
            result := div(and(word, 0xffffffffffffffffffffffffffffffffffffffff000000000000000000000000),
                          0x1000000000000000000000000)
        }
    }

    function locationOf(bytes data, uint256 location) internal returns (uint256 result) {
        assembly {
            result := add(data, add(0x20, location))
        }
    }
}
