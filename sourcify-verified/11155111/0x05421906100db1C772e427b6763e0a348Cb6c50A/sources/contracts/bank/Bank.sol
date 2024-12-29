// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { INativeBank } from "./INativeBank.sol";

contract Bank is INativeBank {

    mapping(address => uint256) private balances;
    address public owner;

    constructor() payable {
        owner = msg.sender;
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return balances[account];
    }

    function deposit() external payable override {
        _deposit(msg.sender, msg.value);
    }

    function _deposit(address sender, uint256 value) internal {
        require(value > 0, "Deposit value must be greater than zero");

        if (sender != owner) {
            increaseBalance(sender, value);
        }

        emit Deposit(sender, value);
    }

    function withdraw(uint256 amount) external override {
        if (msg.sender == owner) {
            return ownerWithdraw(amount);
        }

        if (balances[msg.sender] < amount) {
            revert WithdrawalAmountExceedsBalance(msg.sender, amount, balances[msg.sender]);
        }
        decreaseBalance(msg.sender, amount);
        _withdraw(msg.sender, amount);
        
    }

    function ownerWithdraw(uint256 amount) public onlyOwner {
        _withdraw(owner, amount);
    }

    function _withdraw(address recipient, uint256 amount) internal {
        if (amount == 0) {
            revert WithdrawalAmountZero(recipient);
        }

        uint256 contractBalance = address(this).balance; 
        if (contractBalance < amount) {
            revert WithdrawalAmountExceedsBalance(recipient, amount, contractBalance);
        }

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Failed to send funds");

        emit Withdrawal(recipient, amount);
    }

    function increaseBalance(address account, uint256 amount) internal {
        balances[account] += amount;
    }

    function decreaseBalance(address account, uint256 amount) internal {
        balances[account] -= amount; 
    }

    receive() external payable {
        _deposit(msg.sender, msg.value);
    }
}
