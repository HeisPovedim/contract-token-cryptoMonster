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

    //COMMIT_FUNC: Функция проверка стадии SEED
    function validatePhase(string memory _type, address _providerPrivate, address _providerPublic) internal view returns (bool) {
        if (get_keccak256(_type) == get_keccak256("seed")) {
            if (structPhases_[_providerPrivate].statusPhase == false && structPhases_[_providerPublic].statusPhase == false) 
            return true;  // ?: if условие удовлетворено
            return false; // ?: if условие не удовлетворяет
        } else if (get_keccak256(_type) == get_keccak256("private")) {
            if (structPhases_[_providerPrivate].statusPhase == true) 
            return true;  // ?: if условие удовлетворено
            return false; // ?: if условие не удовлетворяет
        } else if (get_keccak256(_type) == get_keccak256("public")) {
            if (structPhases_[_providerPublic].statusPhase == true)
            return true;  // ?: if условие удовлетворено
            return false; // ?: if условие не удовлетворяет
        } else {
            return false; // ?: if условие не удовлетворяет
        }
    }


}