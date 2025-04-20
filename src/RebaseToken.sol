// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
    * @title RebaseToken
    * @author Bowtied HarpyEagle - Based on Cyfrin Updraft Course
    * @notice This is a cross chain rebase token that incentivizes users to deposit
    * @notice into a vault and gain interest on their deposits. The interest rate of the 
    * @notice contract can only be decreased.
    * @notice Each user has an individual interest rate that is based on the global interest
    * @notice rate of the contract rate of the contract at the time of deposit.

*/ 
contract RebaseToken is ERC20{
    event InterestRateSet(uint256 newInterestRate);

    error RebaseToken__InterestRateCanOnlyDecrease(uint256 oldInterestRate, uint256 newInterestRate);

    uint256 private constant PRECISION_FACTOR = 1e18; 
    uint256 private s_interestRate = 5e10; // interest rate per second in 1e18
    mapping (address => uint256) private s_userInterestRate;
    mapping (address => uint256) private s_userLastUpdatedTimestamp;

    constructor() ERC20("RebaseToken", "RBT") {

    }

    /*
    * @notice This function sets the new interest rate for the contract.
    * @param _newInterestRate The new interest rate for the contract.
    * @dev The interest rate can only be decreased. If the new interest rate is greater than
    * @dev the current interest rate, the transaction will revert.
    */

    function setInterestRate(uint256 _newInterestRate)  external {
        if (_newInterestRate >= s_interestRate) {
            revert RebaseToken__InterestRateCanOnlyDecrease(s_interestRate, _newInterestRate);
        }
        // set the interest rate
        s_interestRate = _newInterestRate;
        emit InterestRateSet(_newInterestRate);
    }

    /*
    * @notice Mint the user tokens when they deposit into the vault.
    * @param _to The address of the user to mint the tokens to.
    * @param _amount The amount of tokens to mint.
    */

    function mint(address _to, uint256 _amount) external {
        _mintAccruedInterest(_to);
        s_userInterestRate[_to] = s_interestRate;
        _mint(_to, _amount);
    }
    /*
    * @notice Burn the user tokens when they withdraw from the vault.
    * @param _from The address of the user to burn the tokens from.
    * @param _amount The amount of tokens to burn.
    */
    function burn(address _from, uint256 _amount) external {
        if(_amount == type(uint256).max) {
            _amount = balanceOf(_from);
        }
        _mintAccruedInterest(_from);
        _burn(_from, _amount);
    }

    /*
    * @notice calculate the balance of the user including interest accrued since the last update.
    * @notice (principal) + interest accrued since the last update
    * @param _user The address of the user to calculate the balance for.
    * @return The balance of the user including interest accrued since the last update.
    */

    function balanceOf(address _user) public view override returns (uint256) {
        // get the current principal balance of the user (already minted tokens)
        // multiply the principal balance by the interest rate
        return super.balanceOf(_user) * _calculateUserAccumulatedInterestRateSinceLastUpdate(_user) / PRECISION_FACTOR;
    }

    /*
    * @notice Transfer tokens from msg.sender to another.
    * @param _recipient The address of the user to transfer the tokens to.
    * @param _amount The amount of tokens to transfer.
    * @return True if the transfer was successful, false otherwise.
    */

    function transfer(address _recipient, uint256 _amount) public override returns (bool) {
        _mintAccruedInterest(msg.sender);
        _mintAccruedInterest(_recipient);
        if (_amount == type(uint256).max) {
            _amount = balanceOf(msg.sender);
        }
        if (balanceOf(_recipient) == 0) {
            s_userInterestRate[_recipient] = s_userInterestRate[msg.sender];
        }
        return super.transfer(_recipient, _amount);
    }

    /*
    * @notice Transfer tokens from one user to another.
    * @param _sender The address of the user to transfer the tokens from.
    * @param _recipient The address of the user to transfer the tokens to.
    * @param _amount The amount of tokens to transfer.
    * @return True if the transfer was successful, false otherwise.
    */

    function transferFrom(address _sender, address _recipient, uint256 _amount) public override returns (bool) {
        _mintAccruedInterest(_sender);
        _mintAccruedInterest(_recipient);
        if (_amount == type(uint256).max) {
            _amount = balanceOf(_sender);
        }
        if (balanceOf(_recipient) == 0) {
            s_userInterestRate[_recipient] = s_userInterestRate[_sender];
        }
        return super.transferFrom(_sender, _recipient, _amount);
    }

    /*
    * @notice calculate the interest rate for the user since the last update.
    * @param _user The address of the user to calculate the interest rate for.
    * @return The interest rate for the user since the last update.
    */

   function _calculateUserAccumulatedInterestRateSinceLastUpdate(address _user) internal view returns (uint256 linearInterest) {
        // we need to calculate the interest rate for the user since the last update
        // this is going to be linear growth with time
        // 1. calculate the time since the last update
        // 2. calculate the amount of linear growth
        // (principal amount) + (principal amount * interest rate * time since last update)
        // or (principal amount) * (1 + interest rate * time since last update)
        // say, you deposit 10 tokens 
        // and the interest rate is 0.5 tokens per second
        // and the last update was 2 seconds ago
        // the new balance would be 10 + (10 * 0.5 * 2) = 10 + 10 = 20
        uint256 timeElapsed = block.timestamp - s_userLastUpdatedTimestamp[_user];
        linearInterest = PRECISION_FACTOR + (s_userInterestRate[_user] * timeElapsed);
    }

    /*
    * @notice Mint the user accrued interest since the last update.
    * @param _user The address of the user to mint the tokens to.
    */

    function _mintAccruedInterest(address _user) internal {
        // (1) find the current balance of already minted tokens to the user -> principal
        uint256 previousPrincipalBalance = super.balanceOf(_user);
        // (2) calculate the current balance including interest
        uint256 currentBalance = balanceOf(_user);
        // calculate difference between the current balance and the new balance
        uint256 balanceIncrease = currentBalance - previousPrincipalBalance;
        // call _mint to mint the necessary amount
        // set the user last updated timestamp to the current block timestamp
        s_userLastUpdatedTimestamp[_user] = block.timestamp;
        _mint(_user, balanceIncrease);
    }

    function getUserInterestRate(address _user) external view returns (uint256) {
        return s_userInterestRate[_user];
    }

    function getInterestRate() external view returns (uint256) {
        return s_interestRate;
    }




}