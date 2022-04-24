// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @title EnergyToken
/// @author lourenslinde || LokiThe5th
/// @notice The energy extracted from Worlds become tokenized for the universal bazaar

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract EnergyToken is ERC20 {
    mapping (address => uint256) private lastSpent;

    constructor(address recipient) ERC20("WorldEnergy", "ENRGY") {
        _mint(recipient, 1000000 * 10 ** decimals());
    }

    function _resetCharge(address target) internal {
        lastSpent[target] = block.timestamp;
    }

    //  Additional logic for Energy token transfers. 
    function transfer(address to, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        _resetCharge(msg.sender);
        return true;
    }

    //  Additional logic for Energy transferForm functions.
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        ERC20.transferFrom(from, to, amount);
        if (to != msg.sender) {
            _resetCharge(from);
        }
        return true;
    }
}