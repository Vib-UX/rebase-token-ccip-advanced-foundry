// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
* @title RebaseToken
* @author Vibhav Sharma
* @notice This is a cross-chain rebase token that incentivises users to deposit into a vault and earn rewards.
* @notice The interest rate in the smart contract can only decrease.
* @notice Each users will have their own interest rate that is the global interest rate at teh time of deposit.
*/

contract RebaseToken is ERC20 {
    error RebaseToken__InterestRateCanOnlyDecrease(uint256 oldInterestRate, uint256 newInterestRate);

    uint256 private s_interestRate = 5e10;

    event InterestRateSet(uint256 interestRate);

    constructor() ERC20("Rebase Token", "RBT") {}

    /*
    * @notice Set the interest rate for the smart contract
    * @param _newInterestRate The new interest rate for the smart contract
    * @dev The interest rate can only decrease
    */
    function setInterestRate(uint256 _newInterestRate) external {
        if (_newInterestRate < s_interestRate) {
            revert RebaseToken__InterestRateCanOnlyDecrease(s_interestRate, _newInterestRate);
        }
        s_interestRate = _newInterestRate;
        emit InterestRateSet(_newInterestRate);
    }
}
