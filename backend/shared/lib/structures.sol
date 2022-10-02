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
    mapping (address => structUser) public structUsers_; // обращение к структуре по АДРЕСАМ
    mapping(address => mapping (address => uint256)) allowed; // делегированные пользоатели

    // COMMENT: Цена за 1 токен.
    uint256 public tokenPrice_ = 750000000; // 1 токен за 0.00075 ETH => 750000000; 0.001ETH => 1000000000 WEI; 0.002 => 2000000000 WEI | ЗНАЧЕНИЕ УКАЗЫВАЕТСЯ В WEI
    
    // COMMENT: Ограничение цены токена.
    uint public tokenAmount_ = 100000; // кол-во, которое может купить токенов пользователь | private = 100 000 CMON; public = 5 000 CMON

    // COMMENT: Набор начальних пользователей. 
    address constant ownerAdr = 0x8E4c24e134908f2334aeF88556Fc1Daaa075A56c;           // ВЛАДЕЛЕЦ
    address constant privateProviderAdr = 0x4490cf36A8A491800B35140A07b4190b533fFcBf; // PRIVATE ПРОВАЙДЕР
    address constant publicProviderAdr = 0x9699f352bA7A92E7C0Ff6924ED99602cddBA38dB;  // PUBLIC ПРОВАЙДЕР

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
        bool exist;                     // заявка существует
    }
    mapping (address => structApplication) public strucApplications_; // обращение к структуре по АДРЕСАМ
    address[] structApplicationsAmountAdr;                     // массив пользователей, подавших заявление
    address[] whiteList;                                       // белый лист прользователей, которым одобрили заявки
    address[] blackList;                                       // черный лист полльзователей
}