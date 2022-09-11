// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "../shared/helpers/validateFuncs.sol";

pragma experimental ABIEncoderV2;

contract PhasePrivate is validateFuncs {

    // COMMENT_FUNC: Функция подачи заявок пользователей.
    function application(string memory _name, string memory _contactForCommunication, address _userAdr) public {
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

    // COMMENT_FUNC: Функция получения адресов, чьи заявки ещё не были рассмотрены.
    function getApplicationNotReviewed () public onlyPrivateProvider view returns (address[] memory) {
        address[] memory _tempAdrAmount; 
        for (uint i = 0; i < structApplicationsAmountAdr.length; i++) {
            uint count = 0;                                       // ?: счетчик для массива адресов
            address _tempAdr = structApplicationsAmountAdr[i];    // ?: массив адресов, чьи заявки ещё не были рассмотрены
            if (strucApplications_[_tempAdr].reviewed == false) { // !: проверка того, что заявка ещё не была рассмотрена
                _tempAdrAmount[count] = _tempAdr;                 // ?: запись в массив адресов, чьи заявки ещё не были рассмотрены
                count++;                                          // ?: прибавление счетчика для массива адресов
            }
        }
        return _tempAdrAmount; // ?: возвращение массива адресов, чьи заявки ещё не были рассмотрены
    }

    // COMMENT_FUNC: Функция принятия заявки.
    function acceptApplication (address _userAdr) public onlyPrivateProvider {
        require(strucApplications_[msg.sender].reviewed == false, "Review the application first"); // !: проверка того, что заявка не была рассмотрена
        strucApplications_[_userAdr].status = false; // ?: изменение статуса заявки
        structApplicationsAmountAdr.push(_userAdr);  // ?: добавление пользователей в общий список адресов подавших заявку
        whiteList.push(_userAdr);  // ?: добавление пользователей в общий список адресов подавших заявку
    }
    
    // COMMENT_FUNC: Функция отклонения заявки.
    function deviationApplication (address _userAdr) public onlyPrivateProvider {
        require(strucApplications_[msg.sender].reviewed == false, "Review the application first"); // !: проверка того, что заявка не была рассмотрена
        strucApplications_[_userAdr].status = false;
    }
}