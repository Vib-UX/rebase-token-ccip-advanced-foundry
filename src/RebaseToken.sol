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
    mapping(address => uint256) private s_userInterestRate;
    mapping(address => uint256) private s_userLastUpdatedTimestamp;

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

    function mint(address _to, uint256 _amount) external {
        _mintAccruedInterest(_to);
        s_userInterestRate[_to] = s_interestRate;
        _mint(_to, _amount);
    }

    function balanceOf(address _account) public view override returns (uint256) {
        // get the current principle balance of the user that is
        uint256 _interest = (block.timestamp - s_userLastUpdatedTimestamp[_account]) * s_userInterestRate[_account];
        return super.balanceOf(_account) + _interest;
    }

    function _mintAccruedInterest(address _user) internal {
        // (1) find the current balance of rebase tokens that have been minted to the user
        // (2) calculate their current balance including any interest -> balanceOf
        // calculate the number of tokens that need to be mitned to the user -> (2) -(1)
        // call the _mint to mint the tokens to the user
        // set the user last updated timestamp
        uint256 _interest = (block.timestamp - s_userLastUpdatedTimestamp[_user]) * s_userInterestRate[_user];
        s_userLastUpdatedTimestamp[_user] = block.timestamp;
        _mint(_user, _interest);
    }

    /*
    * @notice Get the interest rate for the user
    * @param _user The user for which the interest rate is to be fetched
    * @return The interest rate for the user
    */
    function getUserInterestRate(address _user) external view returns (uint256) {
        return s_userInterestRate[_user];
    }
}
