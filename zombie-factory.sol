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
}
