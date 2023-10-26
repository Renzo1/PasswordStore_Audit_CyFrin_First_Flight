// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Script, console2} from "forge-std/Script.sol";
import {PasswordStore} from "../src/PasswordStore.sol";

contract DeployPasswordStore is Script {
    function run() public returns (PasswordStore) {
        vm.startBroadcast();
        PasswordStore passwordStore = new PasswordStore();
        passwordStore.setPassword("myPassword");
        vm.stopBroadcast();
        return passwordStore;
    }
}

// forge script script/DeployPasswordStore.s.sol:DeployPasswordStore --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast -vv

// cast storage 0xPasswordStoreContractAddress 1 --rpc-url $SEPOLIA_RPC_URL

// 0x0046aAA6DFCACA10B6f721b356aB870eca5dcd7a
// cast storage 0x0046aAA6DFCACA10B6f721b356aB870eca5dcd7a 1 --rpc-url $SEPOLIA_RPC_URL

// 0x6d7950617373776f726400000000000000000000000000000000000000000014

// You can read the data by converting it from byte32 to ASCII
// cast --to-ascii 0x98765ReturnedByte32Data321000000000000000000000000000000000000014

// cast --to-ascii    0x6d7950617373776f726400000000000000000000000000000000000000000014
