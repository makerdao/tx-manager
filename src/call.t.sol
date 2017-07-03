pragma solidity ^0.4.11;

import "ds-test/test.sol";

import "./call.sol";

contract TransactionManagerTest is DSTest {

    function testExecute() {
        bytes memory param = hex"01010101010202020202030303030304040404040000000000000000000000000000000000000000000000000000000000000004";
        bytes memory param2 = hex"";

       var tx = new TransactionManager();
       tx.execute(param, param2);
    }
}

