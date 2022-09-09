// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./main.sol";

contract PhasePrivate is Main {
    // COMMENT_FUNC: Функция подачи заявок пользователей.
    function application(string memory _name, string memory _contactForCommunication, address _userAdr) public {
        require(strucApplications_[msg.sender].exist == true, "Application already sent!");                               // проверка на существование заявки
        strucApplications_[msg.sender]  = structApplication(_name, _contactForCommunication, _userAdr, true, false, true);
    }

    // COMMENT_FUNC: Функция принятия заявки.
    function acceptApplication (bool _changeStatus) public {
        require(structUsers_[msg.sender].role == Role.SYSTEM_PRIVATE, "You are not a private provider!");

    }
}