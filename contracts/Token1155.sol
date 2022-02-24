// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract MyCollectibles is ERC1155 {
    constructor() ERC1155("https://MIURL/{id}.json") {
        _mint(msg.sender, 1 /* Id Zanahoria */, 10 /* Cantidad */, "");
        _mint(msg.sender, 2 /* Id Papa      */, 20 /* Cantidad */, "");
    }
}