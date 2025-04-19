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

    uint256 private s_interestRate = 5e10; // interest rate per second in 1e18 

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
}