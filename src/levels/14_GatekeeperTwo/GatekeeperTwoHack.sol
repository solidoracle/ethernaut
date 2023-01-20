// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import 'lib/openzeppelin-contracts/contracts/utils/math/SafeMath.sol'; // Path change of openzeppelin contract

interface IGatekeeperTwo {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract GatekeeperTwoHack {

}