//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ZombieFeeding.sol";

contract ZombieHelper is ZombieFeeding {
    // Modifiers can also take arguments
    modifier isOwnedByTheCaller(uint256 _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        _;
    }

    modifier aboveLevel(uint256 _level, uint256 _zombieId) {
        require(zombies[_zombieId].level >= _level);
        _;
    }

    function changeName(uint256 _zombieId, string calldata _newName)
        external
        isOwnedByTheCaller(_zombieId)
        aboveLevel(2, _zombieId)
    {
        zombies[_zombieId].name = _newName;
    }

    function changeDna(uint256 _zombieId, uint256 _newDna)
        external
        isOwnedByTheCaller(_zombieId)
        aboveLevel(20, _zombieId)
    {
        zombies[_zombieId].dna = _newDna;
    }
}
