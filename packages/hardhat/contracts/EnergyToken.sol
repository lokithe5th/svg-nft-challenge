// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @title EnergyToken
/// @author lourenslinde || LokiThe5th
/// @notice The energy extracted from Worlds become tokenized for the universal bazaar

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract EnergyToken is ERC20 {

    constructor(address recipient) ERC20("WorldEnergy", "ENRGY") {
        _mint(recipient, 100000 * 10 ** decimals());
    }

}