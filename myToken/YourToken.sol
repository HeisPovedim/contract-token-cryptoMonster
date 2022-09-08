// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// on OpenZeppelin docs: https://docs.openzeppelin.com/contracts/4.x/erc20
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract YourToken is ERC20 {
    constructor() ERC20("Scaffold ETH Token", "SET") {
        _mint(msg.sender, 1000 * 10 ** 12);
    }
}