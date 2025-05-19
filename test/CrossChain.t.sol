// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";

import {CCIPLocalSimulatorFork, Register} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";

import {RebaseToken} from "../src/RebaseToken.sol";
import {Vault} from "../src/Vault.sol";
import {RebaseTokenPool} from "../src/RebaseTokenPool.sol";

import {IRebaseToken} from "../src/interfaces/IRebaseToken.sol";
import {IERC20} from "@chainlink/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {RegistryModuleOwnerCustom} from "@chainlink/ccip/tokenAdminRegistry/RegistryModuleOwnerCustom.sol";


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
        ethSepoliaPool = new RebaseTokenPool(IERC20(address(ethSepoliaToken)), new address[](0), ethSepoliaNetworkDetails._rmnProxyAddress, ethSepoliaNetworkDetails._routerAddress);
        ethSepoliaToken.grantMintAndBurnRole(address(vault));
        ethSepoliaPool.grantMintAndBurnRole(address(vault));
        RegistryModuleOwnerCustom(ethSepoliaNetworkDetails.registryModuleOwnerCustomAddress).registerAdminViaOwner(address(ethSepoliaToken));
        vm.stopPrank();

        //deploy and configure on arbSepolia
        vm.selectFork(arbSepoliaFork);
        arbSepoliaNetworkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainId);
        vm.startPrank(owner);
        arbSepoliaToken = new RebaseToken();
        arbSepoliaPool = new RebaseTokenPool(IERC20(address(arbSepoliaToken)), new address[](0), arbSepoliaNetworkDetails._rmnProxyAddress, arbSepoliaNetworkDetails._routerAddress);
        arbSepoliaToken.grantMintAndBurnRole(address(vault));
        arbSepoliaPool.grantMintAndBurnRole(address(vault));
        RegistryModuleOwnerCustom(arbSepoliaNetworkDetails.registryModuleOwnerCustomAddress).registerAdminViaOwner(address(arbSepoliaToken));
        vm.stopPrank();
    }

}