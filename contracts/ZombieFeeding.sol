//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ZombieFactory.sol";

// Interface that enables this contract to interact with another contract, here the CryptoKitties
// contract living on the Ethereum blockchain.
interface KittyInterface {
    function getKitty(uint256 _id)
        external
        view
        returns (
            bool isGestating,
            bool isReady,
            uint256 cooldownIndex,
            uint256 nextActionAt,
            uint256 siringWithId,
            uint256 birthTime,
            uint256 matronId,
            uint256 sireId,
            uint256 generation,
            uint256 genes
        );
}

contract ZombieFeeding is ZombieFactory {
    // Read from the CryptoKitties smart contract
    address cryptoKittiesAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    KittyInterface kittyContract = KittyInterface(cryptoKittiesAddress);

    // In Solidity, there are two locations to store variables — in storage and in memory.
    // Storage refers to variables stored permanently on the blockchain while memory variables are
    // temporary, and are erased between external function calls to the contract. It can be seen
    // as computer's hard disk vs RAM.
    // Most of the time we don't need to use these keywords because Solidity handles them by default.
    // State variables (variables declared outside of functions) are by default storage and written
    // permanently to the blockchain, while variables declared inside functions are memory and will
    // disappear when the function call ends. However, there are times when we do need to use these
    // keywords, namely when dealing with structs and arrays within functions.
    function feedAndMultiply(uint256 _zombieId, uint256 _targetDna, string memory _species) public {
        require(msg.sender == zombieToOwner[_zombieId]);
        Zombie storage myZombie = zombies[_zombieId];
        _targetDna = _targetDna % dnaModulus;
        uint256 newDna = (myZombie.dna + _targetDna) / 2;
        // If the species used to feed the zombie is a kitty, transform the zombie into a cat
        // zombie. It is done by replacing the last two digits of the dna by 99.
        // ie. newDna is 334455, newDna % 100 is 55 so newDna - newDna % 100 is 334400
        // then, if we add 99, the new Dna value is 334499
        if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
            newDna = newDna - newDna % 100 + 99;
        }
        _createZombie("NoName", newDna);
    }

    function feedOnKitty(uint256 _zombieId, uint256 _kittyId) public {
        uint256 kittyDna;
        // Since the getKitty function returns 10 variables, we can either use all or some of them.
        // Writing a comma with no variable name means that we don't want to use the returned value.
        (, , , , , , , , , kittyDna) = kittyContract.getKitty(_kittyId);
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}
