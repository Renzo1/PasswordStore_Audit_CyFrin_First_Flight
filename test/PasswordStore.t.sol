// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {PasswordStore} from "../src/PasswordStore.sol";
import {DeployPasswordStore} from "../script/DeployPasswordStore.s.sol";

contract PasswordStoreTest is Test {
    PasswordStore public passwordStore;
    DeployPasswordStore public deployer;
    address public owner;

    function setUp() public {
        deployer = new DeployPasswordStore();
        passwordStore = deployer.run();
        owner = msg.sender;
    }

    function test_owner_can_set_password() public {
        vm.startPrank(owner);
        string memory expectedPassword = "myNewPassword";
        passwordStore.setPassword(expectedPassword);
        string memory actualPassword = passwordStore.getPassword();
        assertEq(actualPassword, expectedPassword);
    }

    function test_non_owner_reading_password_reverts() public {
        vm.startPrank(address(1));

        vm.expectRevert(PasswordStore.PasswordStore__NotOwner.selector);
        passwordStore.getPassword();
    }
}

// My Additional Tests

contract MorePasswordStoreTest is Test {
    PasswordStore public passwordStore;
    DeployPasswordStore public deployer;
    address public owner;
    address public notOwner;

    function setUp() public {
        deployer = new DeployPasswordStore();
        passwordStore = deployer.run();
        owner = msg.sender;
        notOwner = address(1);
        string memory expectedPassword = "originalPassword";
        passwordStore.setPassword(expectedPassword);
    }

    /** @notice This test checks if other users who are not owner can set a new password. */
    function test_anyone_can_set_password() public {
        // Start Prank passes calls to another user -- notOwner
        // notOwner changes the password
        vm.startPrank(notOwner);
        string memory changedPassword = "newPassword";
        passwordStore.setPassword(changedPassword);

        // Control is passed by back to owner to be able to call getPassword
        vm.startPrank(owner);
        string memory currentPassword = passwordStore.getPassword();

        // This assert tests that the password was changed
        // and that the current password is changedPassword
        assertEq(currentPassword, changedPassword);
    }
}

// forge test --match-path test/ --match PasswordStoreTest --match MorePasswordStoreTest  --match-test "test_anyone_can_set_password"
// forge test --match-path test/PasswordStore.t.sol:MorePasswordStoreTest --match-test "test_anyone_can_set_password"
// forge test --match-test "test_anyone_can_set_password"
