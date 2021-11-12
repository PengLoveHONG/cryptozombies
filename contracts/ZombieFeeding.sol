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
    // Since contract are "immutable" (even though it's possible to upgrade them with proxies but
    // it's out of the scope of this introduction to Solidity), it's better to be able to update
    // the address of the kittyContract in case the smart contract is not working properly. Indeed,
    // it would also make our smart contract not work properly.
    KittyInterface kittyContract;

    // Modifiers can also take arguments
    modifier isOwnedByTheCaller(uint256 _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        _;
    }

    // This function uses the onlyOwner modifier defined in the Ownable smart contract of
    // @openzeppelin. What is a modifier? modifier onlyOwner(). It's a kind of half-function that
    // is used to modify other functions, usually to check some requirements prior to execution.
    // In this case, onlyOwner can be used to limit access so only the owner of the contract can run
    // this function.
    // Here is the onlyOwner modifier's implementation:
    // modifier onlyOwner() {
    //   require(isOwner());
    //   _;
    // }
    // When the setKittyContractAddress() function is executed, the code of the onlyOwner() modifier
    // is first executed. Once it reaches the "_;" instruction, it goes back to execute the code of
    // the setKittyContractAddress() function.
    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    // It's possible to pass a storage pointer to a struct as an argument to a private or internal
    // function
    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint64(block.timestamp + cooldownTime);
    }

    function _isReady(Zombie storage _zombie) internal view returns (bool) {
        return _zombie.readyTime <= block.timestamp;
    }

    // In Solidity, there are two locations to store variables — in storage and in memory.
    // Storage refers to variables stored permanently on the blockchain while memory variables are
    // temporary, and are erased between external function calls to the contract. It can be seen
    // as computer's hard disk vs RAM.
    // Most of the time we don't need to use these keywords because Solidity handles them by default.
    // State variables (variables declared outside of functions) are by default storage and written
    // permanently to the blockchain, while variables declared inside functions are memory and will
    // disappear when the function call ends. However, there are times when we do need to use these
    // keywords, namely when dealing with structs and arrays within functions.
    function feedAndMultiply(
        uint256 _zombieId,
        uint256 _targetDna,
        string memory _species
    ) internal isOwnedByTheCaller(_zombieId) {
        // Check that the person executing the function owns the zombie
        Zombie storage myZombie = zombies[_zombieId];

        // Check that the zombie is ready to feed
        require(_isReady(myZombie));

        // Compute the dna of the new zombie
        _targetDna = _targetDna % dnaModulus;
        uint256 newDna = (myZombie.dna + _targetDna) / 2;
        // If the species used to feed the zombie is a kitty, transform the zombie into a cat
        // zombie. It is done by replacing the last two digits of the dna by 99.
        // ie. newDna is 334455, newDna % 100 is 55 so newDna - newDna % 100 is 334400
        // then, if we add 99, the new Dna value is 334499
        if (
            keccak256(abi.encodePacked(_species)) ==
            keccak256(abi.encodePacked("kitty"))
        ) {
            newDna = newDna - (newDna % 100) + 99;
        }

        // Create the zombie
        _createZombie("NoName", newDna);
        _triggerCooldown(myZombie);
    }

    function feedOnKitty(uint256 _zombieId, uint256 _kittyId) public {
        uint256 kittyDna;
        // Since the getKitty function returns 10 variables, we can either use all or some of them.
        // Writing a comma with no variable name means that we don't want to use the returned value.
        (, , , , , , , , , kittyDna) = kittyContract.getKitty(_kittyId);
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}
