// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./helpresFunc.sol";

// COMMENT: Контракт хранит в себе функции проверка.
contract validateFuncs is helpresFunc {
    //COMMENT_FUNC: Функция проверки роли владельца.
    function validateOwner() internal view returns (bool) {
        if (structUsers_[msg.sender].role == Role.SYSTEM_OWNER)
            return true;  // ?: if условие удовлетворено
            return false; // ?: if условие не удовлетворяет
    }
}