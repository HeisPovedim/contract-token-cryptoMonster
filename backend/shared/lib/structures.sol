// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract structures {
    // COMMENT: Роли для структуры пользователей.
    enum Role {
        SYSTEM_OWNER,
        SYSTEM_PUBLIC,
        SYSTEM_PRIVATE,
        INVESTOR,
        USER
    }

    // COMMENT_SCTRUCT: Структура пользователей.
    struct structUser {
        Role role;               // роль  
        string login;            // логин
        bytes32 password;        // пароль
        uint256 balance_overall; // общий баланс
        uint256 balance_seed;    // баланс SEED токенов
        uint256 balance_private; // баланс PRIVATE токенов
        uint256 balance_public;  // баланс PUBLIC токенов
    }
    mapping (address => structUser) structUsers_; // обращение к структуре по АДРЕСАМ

    // COMMENT_SCTRUC: Структура фазы.
    struct structPhase {
        bool statusPhase; // статус фазы
        bool reviewed;    // была ли активирована фаза
    }
    mapping (address => structPhase) structPhases_; // обращение к структуре по АДРЕСАМ

    // COMMENT_STRUCT: Структура заявок пользователей.
    struct structApplication {
        string name;                    // имя
        string contactForCommunication; // контакты для связи
        address userAdr;                // адрес пользователя
        bool status;                    // статус заявки
        bool reviewed;                  // была ли просмотрена заявка
        bool exist;                     // заявка существует
    }
    mapping (address => structApplication) strucApplications_; // обращение к структуре по АДРЕСАМ
    address[] structApplicationsAmountAdr;                     // массив пользователей, подавших заявление
    address[] whiteList;                                       // белый лист прользователей, которым одобрили заявки
    address[] blackList;                                       // черный лист полльзователей
}