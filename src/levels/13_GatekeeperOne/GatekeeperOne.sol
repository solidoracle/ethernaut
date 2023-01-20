// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import 'lib/openzeppelin-contracts/contracts/utils/math/SafeMath.sol'; // Path change of openzeppelin contract

contract GatekeeperOne {

  using SafeMath for uint256;
  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    // no remainder when divided by 8191, ie the gas left must be a multiple of 8191
    require(gasleft().mod(8191) == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    // assume key 0x B1 B2 B3 B4 B5 B6 B7 B8
    // Note (Implicit Conversions) https://docs.soliditylang.org/en/latest/types.html#conversions-between-elementary-types
    // implicitly to compare the two strings with different uint casting, the greater will be applied and 0 will be applied for the lower uint casting value
    // ex uint64(uint32(uint64(_gateKey)) so the higher part of uint32(uint64(_gateKey) initially truncated will be 0 as it is cast through uint64

    // half of the key must be equal to its quarter
    // 0x B5 B6 B7 B8 == 0x 00 00 B7 B8 if B5 and B6 are 0
      require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
    // its half must be different from the whole
    // 0x 00 00 00 00 B5 B6 B7 B8 != 0x B1 B2 B3 B4 B5 B6 B7 B8 if B1-B4!=0
      require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");

    // its half must be equal to the last 2 bytes (16 bits) of the tx.origin address that has 160 bits (20 bytes)
    // 0x B5 B6 B7 B8 = 0x 00 00 SECOND_LAST_BYTE_OF_YOUR_ADDR LAST_BYTE_OF_YOUR_ADDR
    // B7 and B8 will be the last two bytes of the address of our tx.origin.
      require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
    // therefore the key will be:
    // 0x ANY_DATA ANY_DATA ANY_DATA ANY_DATA 00 00 SECOND_LAST_BYTE_OF_ADDRESS LAST_BYTE_OF_ADDRESS
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}