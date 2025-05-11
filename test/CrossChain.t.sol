// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";

import {CCIPLocalSimulatorFork} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";

import {RebaseToken} from "../src/RebaseToken.sol";
import {Vault} from "../src/Vault.sol";
import {RebaseTokenPool} from "../src/RebaseTokenPool.sol";

import {IRebaseToken} from "../src/interfaces/IRebaseToken.sol";

contract CrossChainTest is Test {
    uint256 ethSepoliaFork;
    uint256 arbSepoliaFork;

    function setUp() public {
        ethSepoliaFork = vm.createSelectFork("sepolia-eth");
        arbSepoliaFork = vm.createFork("sepolia-arb");
    }

}