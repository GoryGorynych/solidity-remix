// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/**
 * @title INativeBank
 * @dev Интерфейс для контракта-банка нативной валюты, предоставляющий основные банковские функции.
 */
interface INativeBank {
    /**
     * @dev Генерируется, когда сумма снятия превышает баланс счёта.
     * @param account Адрес аккаунта, который пытался снять средства.
     * @param amount Сумма, которую пытались снять.
     * @param balance Текущий баланс аккаунта.
     */
    error WithdrawalAmountExceedsBalance(address account, uint256 amount, uint256 balance);
    
    /**
     * @dev Генерируется, когда пытаются снять нулевую сумму.
     * @param account Адрес аккаунта, который пытался снять средства.
     */
    error WithdrawalAmountZero(address account);

    /**
     * @dev Генерируется, когда на счёт аккаунта поступает депозит.
     * @param account Адрес аккаунта, на который был сделан депозит.
     * @param amount Сумма, которая была внесена.
     */
    event Deposit(address indexed account, uint256 amount);
    
    /**
     * @dev Генерируется, когда со счёта снимаются средства.
     * @param account Адрес счёта, с которого произошло снятие.
     * @param amount Сумма, которая была снята.
     */
    event Withdrawal(address indexed account, uint256 amount);

    /**
     * @dev Возвращает баланс счёта.
     * @param account Адрес счёта.
     * @return Баланс счёта.
     */
    function balanceOf(address account) external view returns(uint256);

    /**
     * @dev Вносит средства на счёт.
     */
    function deposit() external payable;
    
    /**
     * @dev Снимает средства со счёта.
     * @param amount Сумма, которую нужно снять.
     */
    function withdraw(uint256 amount) external;
}
