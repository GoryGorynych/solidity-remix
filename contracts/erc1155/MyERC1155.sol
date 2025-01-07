// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Burnable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract MyERC1155Training is ERC1155, ERC1155Burnable, Ownable {
    using Strings for uint256;

    uint256 public constant GOLD = 0;
    uint256 public constant WINNER_CUP = 7;

    constructor()
        ERC1155("https://ipfs.io/ipfs/bafybeig7kle5u2ry4wd4c5f3tfeslmqh5s5ymmcypzb42ecock3xlhq2le/{id}.json")
        Ownable(msg.sender)
    {
        _mint(msg.sender, GOLD, 999_999, "");
        _mint(msg.sender, WINNER_CUP, 1, "");
    }

    function uri(uint256 id ) public view override  returns (string memory) {
        return string.concat(
            "https://ipfs.io/ipfs/bafybeig7kle5u2ry4wd4c5f3tfeslmqh5s5ymmcypzb42ecock3xlhq2le/",
            id.toString(),
            ".json"
        );
    }
}