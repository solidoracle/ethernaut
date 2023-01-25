pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../src/levels/22_Dex/DexFactory.sol";
import "../src/levels/22_Dex/DexHack.sol";
import "../src/core/Ethernaut.sol";
import "./utils/vm.sol";
import "forge-std/console.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";



contract DexTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address attacker = address(100);

    function setUp() public {
        // Setup instance of the Ethernaut contracts
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(attacker, 5 ether);
    }

    function testDexHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        DexFactory dexFactory = new DexFactory();
        ethernaut.registerLevel(dexFactory);

        address levelAddress = ethernaut.createLevelInstance(dexFactory);
        Dex ethernautDex = Dex(payable(levelAddress));


        //////////////////
        // LEVEL ATTACK //
        //////////////////

        // Create DexHack Contract
        DexHack dexHack = new DexHack(ethernautDex);
        
        // give the attack contract the balance
        IERC20(ethernautDex.token1()).transfer(address(dexHack), IERC20(ethernautDex.token1()).balanceOf(address(this)));
        IERC20(ethernautDex.token2()).transfer(address(dexHack), IERC20(ethernautDex.token2()).balanceOf(address(this)));

        // Call the attack function
        dexHack.attack();

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////


        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));

        assert(levelSuccessfullyPassed);
    }
}