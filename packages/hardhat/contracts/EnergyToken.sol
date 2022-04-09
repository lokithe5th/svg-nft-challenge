// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract EnergyToken is ERC20 {
    constructor(address recipient) ERC20("WorldEnergy", "ENRGY") {
        _mint(recipient, 1000000 * 10 ** decimals());
    }
}