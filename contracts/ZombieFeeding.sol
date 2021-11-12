//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ZombieFactory.sol";

contract ZombieFeeding is ZombieFactory {
    // In Solidity, there are two locations to store variables — in storage and in memory.
    // Storage refers to variables stored permanently on the blockchain while memory variables are
    // temporary, and are erased between external function calls to the contract. It can be seen
    // as computer's hard disk vs RAM.
    // Most of the time we don't need to use these keywords because Solidity handles them by default.
    // State variables (variables declared outside of functions) are by default storage and written
    // permanently to the blockchain, while variables declared inside functions are memory and will
    // disappear when the function call ends. However, there are times when we do need to use these
    // keywords, namely when dealing with structs and arrays within functions.
    function feedAndMultiply(uint256 _zombieId, uint256 _targetDna) public {
        require(msg.sender == zombieToOwner[_zombieId]);
        Zombie storage myZombie = zombies[_zombieId];
        _targetDna = _targetDna % dnaModulus;
        uint newDna = (myZombie.dna + _targetDna) / 2;
        _createZombie("NoName", newDna);
    }
}
