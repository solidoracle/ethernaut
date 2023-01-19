pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../src/levels/04_Telephone/TelephoneHack.sol";
import "../src/levels/04_Telephone/TelephoneFactory.sol";
import "../src/core/Ethernaut.sol";
import "./utils/vm.sol";
import "forge-std/console.sol";


contract TelephoneTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address attacker = address(100);
    

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal attacker address some ether
        vm.deal(attacker, 5 ether);
    }

    function testTelephoneHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        TelephoneFactory telephoneFactory = new TelephoneFactory();
        ethernaut.registerLevel(telephoneFactory);
        // Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance(telephoneFactory);
        Telephone ethernautTelephone = Telephone(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
 
        // Create TelephoneHack contract
        TelephoneHack telephoneFlipHack = new TelephoneHack(levelAddress);

        // Run the attack
        telephoneFlipHack.attack(attacker);


        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
