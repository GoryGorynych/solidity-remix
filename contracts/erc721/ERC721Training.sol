// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC721} from "contracts/erc721/IERC721.sol";
import {ERC165, IERC165} from "./ERC165.sol";
import {IERC721Metadata} from "contracts/erc721/IERC721Metadata.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract ERC721Training is IERC721, ERC165, IERC721Errors, IERC721Metadata {
    using Strings for uint256;

    string private _name;
    string private _symbol;

    mapping(address owner => uint256) private balances;
    mapping(uint256 tokenId => address) private owners;
    mapping(uint256 tokenId => address) private tokenApprovals;
    mapping(address owner => mapping(address operator => bool)) private operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /*//////////////////////////////////////////////////////////////
                         METADATA STORAGE/LOGIC
    //////////////////////////////////////////////////////////////*/

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        ownerOf(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenId.toString()) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /*//////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    function balanceOf(address owner) public view returns (uint256) {
        if (owner == address(0)) {
            revert ERC721InvalidOwner(address(0));
        }

        return balances[owner];
    }
    
    function ownerOf(uint256 tokenId) public view returns (address) {
        if (owners[tokenId] == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }

        return owners[tokenId];
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public payable {
        transferFrom(from, to, tokenId);
        
        _checkOnERC721Received(msg.sender, from, to, tokenId, data);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public payable {
        transferFrom(from, to, tokenId);

        _checkOnERC721Received(msg.sender, from, to, tokenId, "");
    }

    function transferFrom(address from, address to, uint256 tokenId) public payable {
        _validateTransfer(msg.sender, from, to, tokenId);

        unchecked {
            balances[from]--;
            balances[to]++;
        }

        owners[tokenId] = to;
        delete tokenApprovals[tokenId];

        emit Transfer(from, to, tokenId);
    }
    
    function approve(address approved, uint256 tokenId) public payable {
        address owner = ownerOf(tokenId);
        if (msg.sender != owner && !isApprovedForAll(owner, msg.sender)) {
            revert ERC721InvalidApprover(msg.sender);
        }

        tokenApprovals[tokenId] = approved;

        emit Approval(owner, approved, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public {
        operatorApprovals[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        return tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return operatorApprovals[owner][operator];
    }

    function _isAuthorized(address owner, address spender, uint256 tokenId) internal view virtual returns (bool) {
        return spender == owner || isApprovedForAll(owner, spender) || spender == getApproved(tokenId);
    }

    function _validateTransfer(address sender, address from, address to, uint256 tokenId) internal view virtual {
        address owner = ownerOf(tokenId);

        if (owner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
        if (from != owner) {
            revert ERC721IncorrectOwner(from, tokenId, owner);
        }
        if (to == address(0)) {
            revert ERC721InvalidReceiver(to);
        }
        if (!_isAuthorized(owner, sender, tokenId)) {
            revert ERC721InsufficientApproval(sender, tokenId);
        }
    }

    function _checkOnERC721Received(
        address operator,
        address from,
        address to,
        uint256 tokenId,
        bytes memory data)
        internal virtual {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(operator, from, tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    // Token rejected
                    revert IERC721Errors.ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    // non-IERC721Receiver implementer
                    revert IERC721Errors.ERC721InvalidReceiver(to);
                } else {
                    assembly ("memory-safe") {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceID) public view override(ERC165, IERC165) returns (bool) {
        return
            interfaceID == type(IERC721).interfaceId ||
            interfaceID == type(IERC721Metadata).interfaceId ||
             super.supportsInterface(interfaceID);
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 id) internal virtual {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(to);
        }
        require(owners[id] == address(0), "ALREADY_MINTED");

        // Counter overflow is incredibly unrealistic.
        unchecked {
            balances[to]++;
        }

        owners[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        address owner = ownerOf(id);
        if (owner == address(0)) {
            revert ERC721NonexistentToken(id);
        }

        // Ownership check above ensures no underflow.
        unchecked {
            balances[owner]--;
        }

        delete owners[id];
        delete tokenApprovals[id];

        emit Transfer(owner, address(0), id);
    }

    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);
        _checkOnERC721Received(msg.sender, address(0), to, id, "");
    }

    function _safeMint(address to, uint256 id, bytes memory data) internal virtual {
        _mint(to, id);
        _checkOnERC721Received(msg.sender, address(0), to, id, data);
    }

}
