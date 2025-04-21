// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";

import {RebaseToken} from "../src/RebaseToken.sol";
import {Vault} from "../src/Vault.sol";

import {IRebaseToken} from "../src/interfaces/IRebaseToken.sol";

contract RebaseTokenTest is Test {
    RebaseToken private rebaseToken;
    Vault private vault;

    address public  owner = makeAddr("owner");
    address public  user = makeAddr("user");
    
    function setUp() public {
        // Deploy the RebaseToken contract
        vm.startPrank(owner);
        rebaseToken = new RebaseToken();
        // we cannot typecast the rebaseToke to IRebaseToken directly so
        // we need to use typecast address to IRebaseToken 
        vault = new Vault(IRebaseToken(address(rebaseToken)));
        rebaseToken.grantMintAndBurnRole(address(vault));
        vm.stopPrank();
    }

}

