pragma solidity ^0.4.11;

import "erc20/erc20.sol";

contract TransactionManager {

    function execute(bytes balances, bytes steps) {
        pullBalances(balances);
        callContracts(steps);

        returnBalances(balances);
    }

    // pulls requested amount of each token from the sender
    function pullBalances(bytes balancesData) internal {
        for (uint index = 0; index < balancesData.length/0x34; index++) {
            address token = getAddressAt(balancesData, 0x34*index);
            uint256 value = getWordAt(balancesData, 0x34*index + 0x14);

            ERC20(token).transferFrom(msg.sender, this, value);
        }
    }

    // returns remaining balances of each token to the sender
    function returnBalances(bytes balancesData) internal {
        for (uint index = 0; index < balancesData.length/0x34; index++) {
            address token = getAddressAt(balancesData, 0x34*index);

            ERC20(token).transfer(msg.sender, ERC20(token).balanceOf(this));
        }
    }

    function callContracts(bytes stepsData) internal {
        // execute steps
        uint256 stepLocation = 0;
        while (stepLocation < stepsData.length) {
            uint256 stepLength = getWordAt(stepsData, stepLocation);
            address stepAddress = getAddressAt(stepsData, stepLocation + 0x20);

            assembly {
                let succeeded := call(sub(gas, 5000), stepAddress, 0, add(add(add(stepsData, 0x20), stepLocation), 0x34), sub(stepLength, 0x14), 0, 0)
                jumpi(invalidJumpLabel, iszero(succeeded))
            }
            stepLocation = stepLocation + 0x20 + stepLength;
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
