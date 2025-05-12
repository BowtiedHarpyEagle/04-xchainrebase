// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";

import {CCIPLocalSimulatorFork, Register} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";

import {RebaseToken} from "../src/RebaseToken.sol";
import {Vault} from "../src/Vault.sol";
import {RebaseTokenPool} from "../src/RebaseTokenPool.sol";

import {IRebaseToken} from "../src/interfaces/IRebaseToken.sol";

contract CrossChainTest is Test {
    address constant owner = makeAddr("owner");
    uint256 ethSepoliaFork;
    uint256 arbSepoliaFork;

    CCIPLocalSimulatorFork ccipLocalSimulatorFork;

    RebaseToken ethSepoliaToken;
    RebaseToken arbSepoliaToken;

    Vault vault;

    RebaseTokenPool ethSepoliaPool;
    RebaseTokenPool arbSepoliaPool;

    Register.NetworkDetails ethSepoliaNetworkDetails;
    Register.NetworkDetails arbSepoliaNetworkDetails;

    function setUp() public {
        ethSepoliaFork = vm.createSelectFork("sepolia-eth");
        arbSepoliaFork = vm.createFork("sepolia-arb");

        ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();
        vm.makePersistent(address(ccipLocalSimulatorFork));

        //deploy and configure on ethSepolia
        ethSepoliaNetworkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainId);
        vm.startPrank(owner);
        ethSepoliaToken = new RebaseToken();
        vault = new Vault(IRebaseToken(address(ethSepoliaToken)));
        ethSepoliaPool = new RebaseTokenPool();
        vm.stopPrank();

        //deploy and configure on arbSepolia
        vm.selectFork(arbSepoliaFork);
        arbSepoliaNetworkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainId);
        vm.startPrank(owner);
        arbSepoliaToken = new RebaseToken();
        vm.stopPrank();
    }

}