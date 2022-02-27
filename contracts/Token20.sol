// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title A ERC20 Token 
/// @author Jhonaiker A. Blanco
contract Token20 is ERC20 {
    constructor(uint256 initialSupply) ERC20("Warrior Token", "WT") {
        _mint(msg.sender, initialSupply);
    }
}