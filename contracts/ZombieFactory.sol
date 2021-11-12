// Define the license of the code
//SPDX-License-Identifier: Unlicense

// Define the version of the Solidity compiler to use
pragma solidity ^0.8.0;

// To use openzeppelin smart contracts, install them using npm:
// $ npm install @openzeppelin/contracts
// The Ownable smart contract is a standard in Solidity and Ethereum Dapps development. When a
// contract is created, its constructor sets the owner to msg.sender (the person who deployed it).
// It also adds an onlyOwner modifier, which restricts access to certain functions to only the owner
// of the smart contract. On top of that, it allows the owner to transfer the ownership to someone
// else.
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ZombieFactory is Ownable {
    // Use a library in Solidity
    // Note: this is just for learning purpose since the SafeMath library is not needed anymore.
    // Since Solidity 0.8, the compiler has built in overflow checking.
    // Here is an example on how to use it will the add() method: uint x = 0; x = x.add(1);
    // it does the same as uint x = 0; x++;
    using SafeMath for uint256;

    // Events are a way for the contract to communicate that something happened on the blockchain
    // to the front-end app, which can be 'listening' for certain events and take action when they
    // happen.
    // They must be declared like this:
    // event IntegersAdded(uint a, uint b, uint result);
    // They can be fired in any function like this:
    // function add(uint _x, uint _y) public pure returns (uint) {
    //   uint result = _x + _y;
    //   emit IntegersAdded(_x, _y, result);
    //   return result;
    // }
    // Then the front-end app can listen to the event like this:
    // MyContract.IntegersAdded((error, result) => {...});
    event NewZombie(uint256 zombieId, string name, uint256 dna);

    // State variable that will be stored permanently in the Ethereum blockchain.
    // The uint type corresponds to an unsigned integer, meaning its value must be non-negative.
    // Its size is 256 bits but it's possible to declare uints with less bits (uint8, unit16...).
    uint256 dnaDigits = 16;
    uint256 dnaModulus = 10**dnaDigits;
    uint256 cooldownTime = 1 days;

    // Structs allow to create more complicated data types
    // Inside a struct, it's possible to pack uint variables together to take up less storage. This
    // would save some gas when the contract is deployed and also when a function using this struct
    // is executed. How to use struct packing? Here is an example, instead of writing a struct using
    // the first form, prefer the second form:
    // 1) struct X { uint a; string b; uint c; }
    // 2) struct X { uint32 a; uint32 c; string b; }
    // Normally there's no benefit to using these sub-types because Solidity reserves 256 bits of
    // storage regardless of the uint size. For example, using uint8 instead of uint (uint256) won't
    // save you any gas. So why does it save some gas? If you have multiple uints inside a struct,
    // using a smaller-sized uint when possible will allow Solidity to pack these variables together
    // to take up less storage.
    struct Zombie {
        string name;
        uint256 dna;
        uint32 level;
        // Cooldown period during which the zombie cannot feed or attack again
        uint64 readyTime;
        uint16 winCount;
        uint16 lossCount;
    }

    // There are two types of arrays in Solidity: fixed length (uint[2] fixedArray) and dynamic
    // length (uint[] dynamicArray) ones. The public keyword will declare the array as public, thus
    // Solidity will automatically create a getter method for it.
    Zombie[] public zombies;

    // Mappings are another way of storing organized data, it's a key-value store for storing and
    // looking up data
    mapping(uint256 => address) public zombieToOwner;
    mapping(address => uint256) ownerZombieCount;

    // 1) Functions, as variables, also have a visibility.
    // By default, functions are public meaning that anyone (or any other contract) can call the
    // functions of this contract and execute its code. It can make the contract vulnerable to
    // attacks so it's best practice to mark the functions as private by default, and then only
    // make public some specific functions public. Private functions can only be called by other
    // functions inside the smart contract.
    // A convention is to start private function names
    // with an underscore.
    // On top of that, there are two other keywords: internal and external.
    // - internal is the same as private, except that the function will also be accessible to
    // contracts that inherit from this contract.
    // - external is similar to public, except that the function can only be called outside the
    // contract - the function can't be called by other functions inside the contract.
    // 2) Function parameters can either be passed as an argument by value or by reference.
    // - By values means that the Solidity compiler creates a new copy of the parameter's value and
    // passes it to your function. This allows your function to modify the value without worrying
    // that the value of the initial parameter gets changed. The keyword to use is memory.
    // - By reference means that the function is called with a reference (pointer) to the original
    // variable. Thus, if the function changes the value of the variable received, it also changes
    // the value of the original variable. This is required for all reference types such as arrays,
    // structs, mappings, and strings. The keyword to use, in this case, is storage.
    // Another convention is to name functions parameters with an underscore to differentiate them
    // from state variables.
    // 3) Functions also have what we call modifiers based on what the function is doing, ie.
    // viewing or modifying the data of the application. It is possible to declare a:
    // - view function if the function is only viewing the data and not modifying it.
    // - pure function if the function is not even viewing the data of the application (nor modying
    // it). ie. function _add(uint a, uint b) private pure returns (uint) { return a + b; }
    function _createZombie(string memory _name, uint256 _dna) internal {
        // array.push() adds something at the end of the array.
        // block.timestamp + cooldownTime will equal the current unix timestamp (in seconds) plus
        // the number of seconds in 1 day - which will equal the unix timestamp 1 day from now.
        // By default, block.timestamp returns a uint256 so we must cast it. It's possible to either
        // cast it to uint32 or uint64. The first option cost less gas but this will lead to the
        // "Year 2038" problem, when 32-bit unix timestamps will overflow and break a lot of legacy
        // systems. The second option cost more gas but will last longer over time.
        zombies.push(
            Zombie(_name, _dna, 1, uint64(block.timestamp + cooldownTime), 0, 0)
        );
        uint256 id = zombies.length - 1;
        // msg.sender is a global variable available to all functions and it refers to the address
        // of the person (or smart contract) who called the current function. Since every contract
        // sits on the blockchain, waiting until someone calls one of its functions, there will
        // always be a msg.sender.
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;
        emit NewZombie(id, _name, _dna);
    }

    // Returns a semi-random unsigned integer.
    // This function is not secured at all because it uses keccak256 to produce a semi-random
    // integer which is very insecure. Indeed, an attacker could predict the result of the function.
    // What is keccak256? Ethereum has the hash function keccak256 built in, which is a version of
    // SHA3. A hash function basically maps an input into a random 256-bit hexadecimal number. A
    // slight change in the input will cause a large change in the hash. It also expects a single
    // parameter of type bytes, that's why we have to "pack" any parameters with abi.encodePacked()
    // before calling the keccak256 function.
    function _generateRandomDna(string memory _str)
        private
        view
        returns (uint256)
    {
        // To cast a value into another data type, simply used type(value)
        uint256 rand = uint256(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string memory _name) public {
        // require will throw an error and stop executing if some condition is not true
        require(ownerZombieCount[msg.sender] == 0);
        uint256 randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }
}
