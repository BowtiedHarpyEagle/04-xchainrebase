// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IRebaseToken} from "./interfaces/IRebaseToken.sol";

contract Vault{
    // We need to pass the token address to the constructor
    // create a deposit function that mints the tokens to the user equal to the amount of ETH sent
    // create a redeem function that burns the tokens from the user and sends the ETH to the user
    // create a way to add rewards to the vault

    IRebaseToken private immutable i_rebaseToken;

    event Deposit(address indexed user, uint256 amount);
    event Redeem(address indexed user, uint256 amount);

    error Vault__RedeemFailed();

    constructor(IRebaseToken _rebaseToken) {
        i_rebaseToken = _rebaseToken;
    }

    receive() external payable {}

    /**
     * @notice allows users to deposit ETH into the vault and mint the rebase tokens in return
     */

    function deposit() external payable {
        // we need to use the amount of ETH the user sent to the contract to mint the tokens
        i_rebaseToken.mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @notice allows users to redeem their rebase tokens for ETH
     * @param _amount the amount of tokens to redeem
     */

    function redeem(uint256 _amount) external {
        if(_amount == type(uint256).max) {
            _amount = i_rebaseToken.balanceOf(msg.sender);
        }
        // 1. we need to burn the tokens from the user and 
        i_rebaseToken.burn(msg.sender, _amount);
        // 2. send the ETH to the user
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        if (!success) {
            revert Vault__RedeemFailed();
        }
        emit Redeem(msg.sender, _amount);
    }

    /**
     * @notice gets the address of the rebase token
     * @return the address of the rebase token
     */

    function getRebaseTokenAddress() external view returns (address) {
        return address(i_rebaseToken);
    }
}
