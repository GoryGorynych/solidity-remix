// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "contracts/erc721/ERC721Training.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MyERC721Token is ERC721Training, Ownable {

    mapping(uint256 => string) private _tokenURIs;
    uint256 public nextTokenId;
    string private baseURI;

    constructor() ERC721Training("DonkeyToken", "DONKEY")
    Ownable(msg.sender)
    {
        setBaseURI("ipfs://");
    }

    function safeMint(address to, string memory _tokenURI) public onlyOwner {
        uint256 tokenId = nextTokenId + 1;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        nextTokenId++;
    }

    function burn(uint256 tokenId) public onlyOwner() {
        _burn(tokenId);
        delete _tokenURIs[tokenId];
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        ownerOf(tokenId);

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        else {
            return string.concat(base, _tokenURI);
        }
    }

    function setBaseURI(string memory baseURI_) public onlyOwner {
        baseURI = baseURI_;
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _baseURI() internal view override  returns (string memory) {
        if (bytes(baseURI).length == 0) {
            return super._baseURI();
        }
        return baseURI;
    }

}