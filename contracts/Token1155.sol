// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Token1155 is ERC1155 {

    constructor() ERC1155("QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT/{id}.json") {
        _mint(msg.sender, 1, 10, "");
        _mint(msg.sender, 2, 10, "");
    }

    function uri(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {

        return string(abi.encodePacked("https://QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT", "/", Strings.toString(tokenId), ".json"));
    }    
  } 
