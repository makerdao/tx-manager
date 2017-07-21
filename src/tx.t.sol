pragma solidity ^0.4.8;

import "ds-test/test.sol";
import "ds-token/base.sol";
import './tx.sol';

contract TxManagerTest is DSTest {
    TxManager tx;
    ERC20     token1;
    ERC20     token2;

    function setUp() {
        tx = new TxManager();
        token1 = new DSTokenBase(1000000);
        token2 = new DSTokenBase(1000000);
    }

    function testNoTokensNoScript() {
        tx.execute(new address[](0), new bytes(0));
    }

}
