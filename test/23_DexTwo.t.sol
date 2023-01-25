pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../src/levels/23_DexTwo/DexTwoFactory.sol";
import "../src/levels/23_DexTwo/DexTwoHack.sol";
import "../src/core/Ethernaut.sol";
import "./utils/vm.sol";
import "forge-std/console.sol";



contract DexTwoTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address attacker = address(100);

    function setUp() public {
        // Setup instance of the Ethernaut contracts
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(attacker, 5 ether);
    }

    function testDexTwoHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        DexTwoFactory dexTwoFactory = new DexTwoFactory();
        ethernaut.registerLevel(dexTwoFactory);

        address levelAddress = ethernaut.createLevelInstance(dexTwoFactory);
        DexTwo ethernautDexTwo = DexTwo(payable(levelAddress));


        //////////////////
        // LEVEL ATTACK //
        //////////////////

        // Create DexHack Contract
        DexTwoHack dexTwoHack = new DexTwoHack(ethernautDexTwo);
        
        // give the attack contract the balance
        IERC20(ethernautDexTwo.token1()).transfer(address(dexTwoHack), IERC20(ethernautDexTwo.token1()).balanceOf(address(this)));
        IERC20(ethernautDexTwo.token2()).transfer(address(dexTwoHack), IERC20(ethernautDexTwo.token2()).balanceOf(address(this)));

        // Call the attack function
        dexTwoHack.attack();

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////


        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));

        assert(levelSuccessfullyPassed);
    }
}