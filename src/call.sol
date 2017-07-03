pragma solidity ^0.4.11;

import "erc20/erc20.sol";

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
            address stepAddress = getAddressAt(steps, stepLocation + 0x20);

            assembly {
                let succeeded := call(sub(gas, 5000), stepAddress, 0, add(add(add(steps, 0x20), stepLocation), 0x34), sub(stepLength, 0x14), 0, 0)
                jumpi(invalidJumpLabel, iszero(succeeded))
            }
            stepLocation = stepLocation + 0x20 + stepLength;
        }

        returnBalances(balances);
    }

    // transfer remaining balances back to the caller
    function returnBalances(bytes balances) internal {
        for (uint i = 0; i < balances.length/52; i++) {
            address token = getAddressAt(balances, 0x34*i);

            ERC20(token).transfer(msg.sender, ERC20(token).balanceOf(this));
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

contract TestContract {
    uint256 public counter;

    function inc(uint256 value) {
        counter += value;
    }
}

