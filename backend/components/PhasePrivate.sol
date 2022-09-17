// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "../shared/helpers/validateFuncs.sol";

pragma experimental ABIEncoderV2;

contract PhasePrivate is validateFuncs {

    // COMMENT_FUNC: Функция подачи заявок пользователей.
    function application(string memory _name, string memory _contactForCommunication, address _userAdr) public onlyUser {
        bool _tempExist = false;
        require(structPhases_[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2].statusPhase == false && structPhases_[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2].statusPhase == false, "Application phase ended"); // !: проверка на то, что заявка подается во время SEED стадии
        require(msg.sender == _userAdr, "You can't send an application to someone else's address");
        for (uint i = 0; i < structApplicationsAmountAdr.length; i++) {
            if (structApplicationsAmountAdr[i] == msg.sender) {
                _tempExist = true;
            }
            require(_tempExist == false, "Application already sent"); // !: проверка на существование заявки
        }
        require(strucApplications_[msg.sender].status == false, "Your application has already been rejected");             // !: проверка на повторную заявку
        strucApplications_[msg.sender]  = structApplication(_name, _contactForCommunication, _userAdr, true, false, true); // ?: записать данных в структуру
        structApplicationsAmountAdr.push(msg.sender); // ?: запись адреса в массив адресов пользователей, которые подали заявку 
    }
    
    // COMMENT_FUNC: Функция получение адресов подаюших заявки.
    function getApplicationAmountAdr () public onlyPrivateProvider view returns (address[] memory) {
        return structApplicationsAmountAdr; // ?: вывод массив пользователей подававших заявление
    }

    // COMMENT_FUNC: Функция принятия заявки.
    function acceptApplication (address _userAdr) public onlyPrivateProvider {
        require(strucApplications_[msg.sender].reviewed == false, "Review the application first"); // !: проверка того, что заявка не была рассмотрена
        strucApplications_[_userAdr].status = false; // ?: изменение статуса заявки
        structApplicationsAmountAdr.push(_userAdr);  // ?: добавление пользователей в общий список адресов подавших заявку
        whiteList.push(_userAdr);  // ?: добавление пользователей в белый список
        structUsers_[_userAdr] = structUser(Role.USER, strucApplications_[_userAdr].name, get_keccak256("0"), 0, 0, 0, 0);
    }
    
    // COMMENT_FUNC: Функция отклонения заявки.
    function deviationApplication (address _userAdr) public onlyPrivateProvider {
        require(strucApplications_[msg.sender].reviewed == false, "Review the application first"); // !: проверка того, что заявка не была рассмотрена
        strucApplications_[_userAdr].status = false;
    }

    // COMMENT_FUNC: Функция включения приватной стадии.
    function startPrivatePhase () public onlyPrivateProvider {
        require(structPhases_[msg.sender].statusPhase == false && structPhases_[msg.sender].reviewed == false, "Phase already active");
        structPhases_[msg.sender] = structPhase(true, true);
    }

    // COMMENT_FUNC: функция отключения приватной фазы.
    function endPrivatePhase () public onlyPrivateProvider {
        require(structPhases_[msg.sender].statusPhase == true && structPhases_[msg.sender].reviewed == true, "Phase has not yet been activated");
        structPhases_[msg.sender] = structPhase(false, true);
        structPhases_[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] = structPhase(true, true);
        tokenPrice_ = 1000000000;
        tokenAmount_ = 5000;
    }
    
    // COMMENT_FUNC: Функция изменения стоимости токена.
    function changeTokenAmountPricePrivate (uint _price) public onlyPrivateProvider {
        tokenPrice_ = _price;
    }
}