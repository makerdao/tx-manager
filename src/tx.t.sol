pragma solidity ^0.4.13;

import "ds-test/test.sol";
import "ds-token/base.sol";
import './tx.sol';

contract Tester {
    ERC20 public token;
    uint256 public value;

    function Tester(ERC20 token_) {
        token = token_;
    }

    function ok(uint256 value_) {
        value = value_;
    }

    function balance() {
        value = token.balanceOf(msg.sender);
    }

    function fail() {
        revert();
    }
}

contract TxManagerTest is DSTest {
    TxManager tx;
    ERC20     token1;
    ERC20     token2;
    Tester    tester1;
    Tester    tester2;

    function setUp() {
        tx = new TxManager();
        token1 = new DSTokenBase(1000000);
        token2 = new DSTokenBase(2000000);
        tester1 = new Tester(token1);
        tester2 = new Tester(token2);
    }

    function testNoTokensNoCalls() {
        tx.execute(new address[](0), new bytes(0));
    }

    function testNoTokensOneCall() {
        assertEq(tester1.value(), 0);
        assertEq(tester2.value(), 0);

        // seth calldata 'ok(uint256)' 10
        bytes memory data = "\x80\x97\x2a\x7d\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x0a";
        bytes memory call = joinBytes(addressToBytes(tester1), uintToBytes(data.length), data);

        tx.execute(new address[](0), call);

        assertEq(tester1.value(), 10);
        assertEq(tester2.value(), 0);
    }

    function testNoTokensTwoCalls() {
        assertEq(tester1.value(), 0);
        assertEq(tester2.value(), 0);

        // seth calldata 'ok(uint256)' 10
        bytes memory data1 = "\x80\x97\x2a\x7d\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x0a";
        bytes memory call1 = joinBytes(addressToBytes(tester1), uintToBytes(data1.length), data1);

        // seth calldata 'ok(uint256)' 13
        bytes memory data2 = "\x80\x97\x2a\x7d\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x0d";
        bytes memory call2 = joinBytes(addressToBytes(tester2), uintToBytes(data2.length), data2);

        tx.execute(new address[](0), joinBytes(call1, call2));

        assertEq(tester1.value(), 10);
        assertEq(tester2.value(), 13);
    }

    function testFailOnFailedCall() {
        // seth calldata 'fail()'
        bytes memory data = "\xa9\xcc\x47\x18";
        bytes memory call = joinBytes(addressToBytes(tester1), uintToBytes(data.length), data);

        tx.execute(new address[](0), call);
    }

    function testNoTokenTransferIfNotApproved() {
        // seth calldata 'balance()'
        bytes memory data = "\xb6\x9e\xf8\xa8";
        bytes memory call = joinBytes(addressToBytes(tester1), uintToBytes(data.length), data);

        tx.execute(tokens(token1), call);

        assertEq(tester1.value(), 0);
    }

    function testTransferTokenAllowanceAndReturnFunds() {
        token1.approve(tx, 1000);

        // seth calldata 'balance()'
        bytes memory data = "\xb6\x9e\xf8\xa8";
        bytes memory call = joinBytes(addressToBytes(tester1), uintToBytes(data.length), data);

        tx.execute(tokens(token1), call);

        assertEq(tester1.value(), 1000);
        assertEq(token1.balanceOf(this), 1000000);
    }

    function testTransferNoMoreThanTokenBalance() {
        token1.approve(tx, 1000000000000);

        // seth calldata 'balance()'
        bytes memory data = "\xb6\x9e\xf8\xa8";
        bytes memory call = joinBytes(addressToBytes(tester1), uintToBytes(data.length), data);

        tx.execute(tokens(token1), call);

        assertEq(tester1.value(), 1000000);
    }

    function testTransferTwoTokensAndReturnFunds() {
        token1.approve(tx, 1000);
        token2.approve(tx, 1500);

        // seth calldata 'balance()'
        bytes memory data1 = "\xb6\x9e\xf8\xa8";
        bytes memory call1 = joinBytes(addressToBytes(tester1), uintToBytes(data1.length), data1);
        // seth calldata 'balance()'
        bytes memory data2 = "\xb6\x9e\xf8\xa8";
        bytes memory call2 = joinBytes(addressToBytes(tester2), uintToBytes(data2.length), data2);

        tx.execute(tokens(token1, token2), joinBytes(call1, call2));

        assertEq(tester1.value(), 1000);
        assertEq(tester2.value(), 1500);

        // check if funds returned after calls have been made
        assertEq(token1.balanceOf(this), 1000000);
        assertEq(token2.balanceOf(this), 2000000);
    }

    // --- --- ---

    function uintToBytes(uint256 x) internal returns (bytes b) {
        b = new bytes(32);
        assembly { mstore(add(b, 32), x) }
    }

    function addressToBytes(address a) internal constant returns (bytes b) {
       assembly {
            let m := mload(0x40)
            mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, a))
            mstore(0x40, add(m, 52))
            b := m
       }
    }

    function joinBytes(bytes a, bytes b) internal constant returns (bytes) {
        return joinBytes(a, b, new bytes(0));
    }

    function joinBytes(bytes a, bytes b, bytes c) internal constant returns (bytes) {
        bytes memory result = new bytes(a.length + b.length + c.length);
        uint k = 0;
        uint i;
        for (i = 0; i < a.length; i++) result[k++] = a[i];
        for (i = 0; i < b.length; i++) result[k++] = b[i];
        for (i = 0; i < c.length; i++) result[k++] = c[i];
        return result;
    }

    function tokens(address a1) returns (address[]) {
        address[] memory tokens = new address[](1);
        tokens[0] = a1;
        return tokens;
    }

    function tokens(address a1, address a2) returns (address[]) {
        address[] memory tokens = new address[](2);
        tokens[0] = a1;
        tokens[1] = a2;
        return tokens;
    }
}
