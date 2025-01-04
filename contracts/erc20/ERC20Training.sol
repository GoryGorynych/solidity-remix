// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

contract ERC20Training is IERC20, IERC20Errors {

    string private _name;
    string private _symbol;
    uint256 private _totalSupply;

    mapping(address owner => uint256) private balances;
    mapping(address owner => mapping(address spender => uint256)) private _allowance;

    constructor(string memory name_, string memory symbol_, uint256 totalSupply_) {
        _name = name_;
        _symbol = symbol_;
        _mint(msg.sender, totalSupply_);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }
    
    function totalSupply() public view virtual  returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address owner) public view virtual returns (uint256 balance) {
        return balances[owner];
    }

    function transfer(address to, uint256 value) public virtual returns (bool success) {
        _checkAccounts(msg.sender, to);
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public virtual returns (bool success) {
        address spender = msg.sender;
        _checkAccounts(spender, to);

        uint256 allowed = allowance(from, spender);
        if (allowed < type(uint256).max) {
            if (allowed < value) {
                revert ERC20InsufficientAllowance(spender, allowed, value);
            }
            _setAllowance(from, spender, allowed - value);
            _transfer(from, to, value);
        } else {
            return false;
        }
        return true;
    }

    function approve(address spender, uint256 value) public virtual returns (bool success) {
        _setAllowance(msg.sender, spender, value);
        emit Approval(msg.sender, spender, value);

        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256 remaining) {
        return _allowance[owner][spender];
    }

    function _transfer(address from, address to, uint256 amount) internal {

        uint256 fromBalance = balances[from];
        if (fromBalance < amount) {
            revert ERC20InsufficientBalance(from, fromBalance, amount);
        }

        // Overflow not possible
        unchecked {
            balances[from] = fromBalance - amount;
        }
        // Overflow not possible
        unchecked {
            balances[to] += amount;
        }

        emit Transfer(from, to, amount);
    }

    function _checkAccounts(address from, address to) internal pure {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
    }

    function _setAllowance(address owner, address spender, uint256 value) internal {
        _allowance[owner][spender] = value;
    }

    function _mint(address to, uint256 amount) internal virtual {
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _totalSupply += amount;

        // Overflow not possible
        unchecked {
            balances[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        balances[from] -= amount;

        // Overflow not possible
        unchecked {
            _totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }

}