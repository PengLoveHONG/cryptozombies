// Define the license of the code
// SPDX-License-Identifier: UNLICENSED

// Define the version of the Solidity compiler to use
pragma solidity >=0.8.10;

contract ZombieFactory {
    // State variable that will be stored permanently in the Ethereum blockchain.
    // The uint type corresponds to an unsigned integer, meaning its value must be non-negative.
    // Its size is 256 bits but it's possible to declare uints with less bits (uint8, unit16...).
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    // Structs allow to create more complicated data types
    struct Zombie {
        string name;
        uint dna;
    }

    // There are two types of arrays in Solidity: fixed length (uint[2] fixedArray) and dynamic
    // length (uint[] dynamicArray) ones. The public keyword will declare the array as public, thus
    // Solidity will automatically create a getter method for it.
    Zombie[] public people;

    // Functions, as variables, also have a visibility.
    // Function parameters can either be passed as an argument by value or by reference.
    // - By values means that the Solidity compiler creates a new copy of the parameter's value and
    // passes it to your function. This allows your function to modify the value without worrying
    // that the value of the initial parameter gets changed.
    // - By reference means that the function is called with a reference (pointer) to the original
    // variable. Thus, if the function changes the value of the variable received, it also changes
    // the value of the original variable.
    function createZombie(string memory _name, uint _dna) public {

    }
}
