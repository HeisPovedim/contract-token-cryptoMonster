// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "../shared/helpers/validateFuncs.sol";

// @: Конструкция SEED раунда.
contract PhaseSeed is validateFuncs {
    address investorFirstAdr = 0x0Ad0367e407C9B59051e7468c939bA3B53B6A3EF;  // Investor1
    address investorSecondAdr = 0x7590D9cC314c9271c7223312ce4c2F987a226c7E; // Investor2
    address bestFriendAdr = 0xCcBf167B833c1AC416B6014ff56b4506f47BF82e;     // Best friend
    // COMMENT: Набор начальных пользователей.
    constructor() {
        structUsers_[investorFirstAdr] = structUser(Role.INVESTOR , "Investor1", get_keccak256("3412"), 0, 0, 0, 0); // Investor1
        whiteList.push(investorFirstAdr); // добавление 1-го инвестора в белый список
        structUsers_[investorSecondAdr] = structUser(Role.INVESTOR, "Investor1", get_keccak256("1423"), 0, 0, 0, 0); // Investor2
        whiteList.push(investorSecondAdr); // добавление 2-го инвестора в белый список
        structUsers_[bestFriendAdr] = structUser(Role.INVESTOR, "Best friend", get_keccak256("2314"), 0, 0, 0, 0);   // Best friend
        whiteList.push(bestFriendAdr); // добавление лучшего друга в белый список
    }
}