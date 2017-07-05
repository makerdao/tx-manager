/// tx.sol -- multiple smart contract calls in one transaction,
///           involving ERC20 tokens interaction

// This file is part of Maker Keeper Framework.
//
// Copyright (C) 2017 reverendus
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
// 
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.4.11;

import "ds-auth/auth.sol";
import "ds-math/math.sol";
import "ds-note/note.sol";
import "erc20/erc20.sol";

contract TxManager is DSAuth, DSMath, DSNote {

    function execute(address[] tokens, bytes script) note auth {
        // pull the entire allowance of each token from the sender
        for (uint i = 0; i < tokens.length; i++) {
            uint256 amount = min(ERC20(tokens[i]).balanceOf(msg.sender), ERC20(tokens[i]).allowance(msg.sender, this));
            ERC20(tokens[i]).transferFrom(msg.sender, this, amount);
        }

        // sequentially call contacts, abort on failed calls
        invokeContracts(script);

        // return entire remaining balances of each token to the sender
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