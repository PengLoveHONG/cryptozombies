//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ZombieHelper.sol";

contract ZombieAttack is ZombieHelper {
    uint256 randNonce = 0;
    uint256 attackVictoryProbability = 70;

    // This function generate a semi-random number but it's not a secure way to do it at all!!
    // It's only for learning purposes but we should prefer using oracle instead of keccak256 to
    // generate random numbers. Why? This is subject to an attack by a dishonest node.
    function randMod(uint256 _modulus) internal returns (uint256) {
        randNonce++;
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, randNonce)
                )
            ) % _modulus;
    }

    // Create new function here
    function attack(uint256 _zombieId, uint256 _targetId)
        external
        isOwnedByTheCaller(_zombieId)
    {
        Zombie storage myZombie = zombies[_zombieId];
        Zombie storage enemyZombie = zombies[_targetId];
        uint rand = randMod(100);
        if (rand <= attackVictoryProbability) {
            myZombie.winCount++;
            myZombie.level++;
            enemyZombie.lossCount++;
            feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
        } else {
            myZombie.lossCount++;
            enemyZombie.winCount++;
            _triggerCooldown(myZombie);
        }
    }
}
