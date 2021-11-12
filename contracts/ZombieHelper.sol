//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ZombieFeeding.sol";

contract ZombieHelper is ZombieFeeding {
    uint256 levelUpFee = 0.001 ether;

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

    // Payable is a modifier function that can receive Ether.
    function levelUp(uint256 _zombieId) external payable {
        require(msg.value == levelUpFee);
        zombies[_zombieId].level++;
    }

    function withdraw() external onlyOwner {
        address payable _owner = payable(address(uint160(owner())));
        _owner.transfer(address(this).balance);
    }

    function setLevelUpFee(uint256 _newLevelUpFee) external onlyOwner {
        levelUpFee = _newLevelUpFee;
    }

    // View functions don't cost any as when they're called externally by an user.
    // This is because view functions don't change anything on the blockchain, they only read data.
    // It does not need to create a transaction on the blockchain.
    // Note: if a view function is called internally from another function in the same contract that is
    // not a view function, it will still cost gas. This is because the other function creates a transaction
    // on Ethereum and will still need to be verified from every node.
    function getZombiesByOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        // We declare an array in memory so it does not cost any gas.
        // We also recreate the array by looping over the zombies array instead of storing the
        // army of zombies owned by each owner on the blockchain. This cost way less in gas!
        uint256[] memory result = new uint256[](ownerZombieCount[_owner]);
        uint256 counter = 0;
        for (uint256 i = 0; i < zombies.length; i++) {
            if (zombieToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }
}
