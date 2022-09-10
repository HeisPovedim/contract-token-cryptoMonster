// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./validateFuncs.sol";

contract modifireFunc is validateFuncs {
    
    // COMMENT_MOD: Модификатор проверка роли ВЛАДЕЛЬЦА.
    modifier onlyOwner() {
        require(structUsers_[msg.sender].role == Role.SYSTEM_OWNER, "Your not admin");
        _;
    }

    // COMMENT_MOD: Модификатор проверка роли PRIVAT ПРОВАЙДЕРА.
    modifier onlyPrivateProvider() {
        require(structUsers_[msg.sender].role == Role.SYSTEM_PRIVATE, "Your not Private provider");
        _;
    }
}