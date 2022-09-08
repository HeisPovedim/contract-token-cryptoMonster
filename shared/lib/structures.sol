// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract structures {
    // COMMENT_SCTRUCT: Структура пользователей.
    struct structUser {
        string login;       // логин
        bytes32 password;   // пароль
        uint256 balances;   // баланс
    }
    mapping (address => structUser) structUser_;                // обращение к структуре по АДРЕСАМ
}