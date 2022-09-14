// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "../lib/structures.sol";

contract modifireFunc is structures {
    
    // COMMENT_MOD: Модификатор проверка роли ВЛАДЕЛЬЦА.
    modifier onlyOwner () {
        require(structUsers_[msg.sender].role == Role.SYSTEM_OWNER, "Your not admin");
        _;
    }

    // COMMENT_MOD: Модификатор проверка роли PRIVAT ПРОВАЙДЕРА.
    modifier onlyPrivateProvider () {
        require(structUsers_[msg.sender].role == Role.SYSTEM_PRIVATE, "Your not Private provider");
        _;
    }

    // COMMENT_MOD: Модификатор проверки роли ВЛАДЕЛЬЦ или PRIVAT ПРОВАЙДЕРА.
    modifier onlyOwnerAndPrivateProvider () {
        require(structUsers_[msg.sender].role == Role.SYSTEM_OWNER || structUsers_[msg.sender].role == Role.SYSTEM_PRIVATE, "You are not the owner or private provider");
        _;
    }

    // COMMENT_MOD: Модификатор проверка того, что пользователь обычный user.
    modifier onlyUser () {
        require(
            structUsers_[msg.sender].role != Role.SYSTEM_OWNER ||
            structUsers_[msg.sender].role != Role.SYSTEM_PUBLIC ||
            structUsers_[msg.sender].role != Role.SYSTEM_PRIVATE ||
            structUsers_[msg.sender].role != Role.INVESTOR, "Application can only be submitted by regular users"
        );
        _;
    }
}