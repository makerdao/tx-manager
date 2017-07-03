pragma solidity ^0.4.11;

import "erc20/erc20.sol";

contract TransactionManager {

    function execute(bytes balancesData, bytes invocationsData) {
        pullBalances(balancesData);
        invokeContracts(invocationsData);
        returnBalances(balancesData);
    }

    // pulls requested amount of each token from the sender
    function pullBalances(bytes balancesData) internal {
        for (uint index = 0; index < balancesData.length/0x34; index++) {
            address token = addressAt(balancesData, 0x34*index);
            uint256 value = uint256At(balancesData, 0x34*index + 0x14);
            ERC20(token).transferFrom(msg.sender, this, value);
        }
    }

    // returns remaining balances of each token to the sender
    function returnBalances(bytes balancesData) internal {
        for (uint index = 0; index < balancesData.length/0x34; index++) {
            address token = addressAt(balancesData, 0x34*index);
            ERC20(token).transfer(msg.sender, ERC20(token).balanceOf(this));
        }
    }

    // sequentially call contacts, abort on failed calls
    function invokeContracts(bytes invocationsData) internal {
        // execute steps
        uint256 location = 0;
        while (location < invocationsData.length) {
            uint256 length = uint256At(invocationsData, location);

            address contractAddress = addressAt(invocationsData, location + 0x20);
            uint256 calldataStart = locationOf(invocationsData, location + 0x20 + 0x14);
            uint256 calldataLength = length - 0x14;
            assembly {
                let succeeded := call(sub(gas, 5000), contractAddress, 0, calldataStart, calldataLength, 0, 0)
                jumpi(invalidJumpLabel, iszero(succeeded))
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
            result := div(and(word, 0xffffffffffffffffffffffffffffffffffffffff000000000000000000000000), 0x1000000000000000000000000)
        }
    }

    function locationOf(bytes data, uint256 location) internal returns (uint256 result) {
        assembly {
            result := add(data, add(0x20, location))
        }
    }
}
