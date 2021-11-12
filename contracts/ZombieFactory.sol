// Define the license of the code
//SPDX-License-Identifier: Unlicense

// Define the version of the Solidity compiler to use
pragma solidity ^0.8.0;

contract ZombieFactory {
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

    // Structs allow to create more complicated data types
    struct Zombie {
        string name;
        uint256 dna;
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
    // make public some specific functions public. A convention is to start private function names
    // with an underscore.
    // On top of that, there are two other keywords: internal and external.
    // - internal is the same as private, except that the function will also be accessible to
    // contracts that inherit from this contract.
    // - external is similar to public, except that the function can only be called outside the
    // contract - the function can't be called by other functions inside the contract.
    // 2) Function parameters can either be passed as an argument by value or by reference.
    // - By values means that the Solidity compiler creates a new copy of the parameter's value and
    // passes it to your function. This allows your function to modify the value without worrying
    // that the value of the initial parameter gets changed.
    // - By reference means that the function is called with a reference (pointer) to the original
    // variable. Thus, if the function changes the value of the variable received, it also changes
    // the value of the original variable. This is required for all reference types such as arrays,
    // structs, mappings, and strings.
    // Another convention is to name functions parameters with an underscore to differentiate them
    // from state variables.
    // 3) Functions also have what we call modifiers based on what the function is doing, ie.
    // viewing or modifying the data of the application. It is possible to declare a:
    // - view function if the function is only viewing the data and not modifying it.
    // - pure function if the function is not even viewing the data of the application.
    //   ie. function _add(uint a, uint b) private pure returns (uint) { return a + b; }
    function _createZombie(string memory _name, uint256 _dna) internal {
        // array.push() adds something at the end of the array
        zombies.push(Zombie(_name, _dna));
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
