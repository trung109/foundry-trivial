// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OurToken is ERC20 {
    constructor(uint256 initalSupply) ERC20("OurToken", "OT") {
        _mint(msg.sender, initalSupply);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
