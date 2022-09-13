// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "../shared/helpers/validateFuncs.sol";

// @: Конструкция SEED раунда.
contract PhaseSeed is validateFuncs {
    address investorFirstAdr = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;  // Investor1
    address investorSecondAdr = 0x617F2E2fD72FD9D5503197092aC168c91465E7f2; // Investor2
    address bestFriendAdr = 0x17F6AD8Ef982297579C203069C1DbfFE4348c372;     // Best friend
    // COMMENT: Набор начальных пользователей.
    constructor() {
        structUsers_[investorFirstAdr] = structUser(Role.INVESTOR , "Investor1", get_keccak256("3412"), 0, 0, 0, 0); // Investor1
        structUsers_[investorSecondAdr] = structUser(Role.INVESTOR, "Investor1", get_keccak256("1423"), 0, 0, 0, 0); // Investor2
        structUsers_[bestFriendAdr] = structUser(Role.INVESTOR, "Best friend", get_keccak256("2314"), 0, 0, 0, 0);   // Best friend
    }
}