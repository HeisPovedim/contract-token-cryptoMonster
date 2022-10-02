// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

// HELLPERS && LIB
import "../shared/lib/SafeMath.sol"; // библиотека безопасного перевод средств
import "../shared/lib/IERC20.sol";   // стандарт IERC20

// COMPONENT
import "../shared/helpers/validateFuncs.sol";
import "./PhaseSeed.sol";
import "./PhasePrivate.sol";
import "./PhasePublic.sol";

contract CryptoMonster is IERC20, validateFuncs, PhaseSeed, PhasePrivate, PhasePublic {
    using SafeMath for uint256; // библиотека безопасных вычислений

    // COMMENT: Общие сведения по токену.
    string public constant name = "CryptoMonster"; // название токена
    string public constant symbol = "CMON";        // тикер токена
    uint8 public constant decimals = 12;           // 1 000 000 000 000 == 1 CMON ; конвертация eth в wei: https://eth-converter.com/

    uint256 totalSupply_; // общее кол-во токенов при старте системы

    constructor(uint256 total) {
        totalSupply_ = total; // кол-во токенов при старте

        structUsers_[ownerAdr] = structUser(Role.SYSTEM_OWNER ,"owner", get_keccak256("3412"), totalSupply_, 0, 0, 0);
        whiteList.push(ownerAdr);

        structUsers_[privateProviderAdr] = structUser(Role.SYSTEM_PRIVATE, "Private provider", get_keccak256("1423"), 0, 0, 0, 0);
        whiteList.push(privateProviderAdr);
        allowed[ownerAdr][privateProviderAdr] = totalSupply_;
        structPhases_[privateProviderAdr] = structPhase(false, false);

        structUsers_[publicProviderAdr] = structUser(Role.SYSTEM_PUBLIC, "Public provider", get_keccak256("2314"), 0, 0, 0, 0);
        whiteList.push(publicProviderAdr);
        allowed[ownerAdr][publicProviderAdr] = totalSupply_;
        structPhases_[publicProviderAdr] = structPhase(false, false);

        // COMMENT: Перечесление средств инвесторам.
        transfer(investorFirstAdr, 600000);  // Investor1
        transfer(investorSecondAdr, 800000); // Investor2
        transfer(bestFriendAdr, 400000);     // Best friend
    }

    //COMMENT_FUNC: Функция создания пользователя.
    function createUser(address _userAdr, string memory _login, bytes32 _password) public {
        structUsers_[_userAdr] = structUser(Role.USER, _login, _password, 0, 0, 0, 0);
    }

    // COMMENT_FUNC: Функция покупки токена | например: покупатель хочет 1 токенов, для этого он должен отправить 5 вэй
    function buy(uint256 _amount) external payable returns(bool, string memory) {
        require(_amount <= tokenAmount_, "Too many tokens");
        require(msg.value == _amount * tokenPrice_, "Need to send exact amount of wei");
        if (validateOwner() == true) { // !: if пользователь админ
            structUsers_[msg.sender].balance_overall = structUsers_[msg.sender].balance_overall.add(_amount);
            return (true, "You bought a token");
        // !: PRIVATE
        } else if (structPhases_[privateProviderAdr].statusPhase == true) {
            address _tempAdr;
            for (uint i = 0; i < whiteList.length; i++) { // ?: перебор пользователей в белом листе
                _tempAdr = whiteList[i];
                if (_tempAdr == msg.sender) { // !: if пользователй находится в белом листе
                    structUsers_[msg.sender].balance_private = structUsers_[msg.sender].balance_private.add(_amount);
                    return (true, "You bought a token");
                }
            }
            return (false, "User not found in whitelist");
        // !: PUBLIC
        } else if (structPhases_[publicProviderAdr].statusPhase == true) {
            structUsers_[msg.sender].balance_public = structUsers_[msg.sender].balance_public.add(_amount);
            return (true, "You bought a token");
        // !: SEED
        } else {
            return (true, "During the seed phase, only the owner can buy tokens");
        }
    }

    // COMMENT_FUNC: Функция вернет количество всех токенов, выделенных этим контрактом, независимо от владельца.
    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    // COMMENT_FUNC: Функция вернет текущий баланс токена учетной записи, идентифицированный по адресу его владельца.
    function balanceOf(address _tokenOwner) public override view returns(uint256) {
        if (validateOwner() == true) { // !: if пользователь админ
            return structUsers_[_tokenOwner].balance_overall;
        // !: PRIVATE
        } else if (structPhases_[privateProviderAdr].statusPhase == true) {
            return structUsers_[_tokenOwner].balance_private;
        // !: PUBLIC
        } else if (structPhases_[publicProviderAdr].statusPhase == true) {
            return structUsers_[_tokenOwner].balance_public;
        // !: SEED
        } else {
            return structUsers_[_tokenOwner].balance_seed;
        }
    }

    //COMMENT_FUNC: Функция вернет текущий баланс.
    function currentBalance(address _userAdr) public view returns(uint256) {
        if (validateOwner() == true) { // !: if пользователь админ
            return structUsers_[_userAdr].balance_overall;
        // !: PRIVATE
        } else if (structPhases_[privateProviderAdr].statusPhase == true) {
            return structUsers_[_userAdr].balance_private;
        // !: PUBLIC
        } else if (structPhases_[publicProviderAdr].statusPhase == true) {
            return structUsers_[_userAdr].balance_public;
        // !: SEED
        } else {
            return structUsers_[_userAdr].balance_seed;
        }
    }

    // COMMENT_FUNC: Функция перевода используется для перемещения количества токенов _numTokens с баланса владельца
    // на баланс другого пользователя или получателя. Передающий владелец — msg.sender, 
    // то есть тот, кто выполняет функцию.
    function transfer(address _receiver, uint256 _numTokens) public override returns (bool) {
        if (validateOwner() == true) { // !: if пользователь владелец
            require(_numTokens <= structUsers_[msg.sender].balance_overall);                                       // !: проверка баланса

            structUsers_[msg.sender].balance_overall = structUsers_[msg.sender].balance_overall.sub(_numTokens);   // ?: снятие токенов с баланса
            // !: PRIVATE
            if (structPhases_[privateProviderAdr].statusPhase == true) {
                structUsers_[_receiver].balance_private = structUsers_[_receiver].balance_private.add(_numTokens); // ?: начисление токенов на баланс
            // !: PRIVATE
            } else if (structPhases_[publicProviderAdr].statusPhase == true) {
                structUsers_[_receiver].balance_public = structUsers_[_receiver].balance_public.add(_numTokens);   // ?: начисление токенов на баланс
            // !: SEED
            } else {
                structUsers_[_receiver].balance_seed = structUsers_[_receiver].balance_seed.add(_numTokens);       // ?: начисление токенов на баланс
            }
            emit Transfer(msg.sender, _receiver, _numTokens);
            return true;
        } else { // !: if пользователь не владелец
            if (structPhases_[privateProviderAdr].statusPhase == true) { // PRIVATE
                require(_numTokens <= structUsers_[msg.sender].balance_private);                                    // !: проверка баланса

                structUsers_[msg.sender].balance_private = structUsers_[msg.sender].balance_private.sub(_numTokens); // ?: снятие токенов с баланса
                structUsers_[_receiver].balance_private = structUsers_[_receiver].balance_private.add(_numTokens);   // ?: начисление токенов на баланс
            } else if (structPhases_[publicProviderAdr].statusPhase == true) { // PUBLIC
                require(_numTokens <= structUsers_[msg.sender].balance_public);// !: проверка баланса

                structUsers_[msg.sender].balance_public = structUsers_[msg.sender].balance_public.sub(_numTokens); // ?: снятие токенов с баланса
                structUsers_[_receiver].balance_public = structUsers_[_receiver].balance_public.add(_numTokens);   // ?: начисление токенов на баланс
            } else { // SEED
                require(_numTokens <= structUsers_[msg.sender].balance_seed);// !: проверка баланса
                require (structUsers_[msg.sender].role == Role.INVESTOR, "Your not investor");
                require (structUsers_[_receiver].role == Role.INVESTOR, "Your not investor");

                structUsers_[msg.sender].balance_seed = structUsers_[msg.sender].balance_seed.sub(_numTokens); // ?: снятие токенов с баланса
                structUsers_[_receiver].balance_seed = structUsers_[_receiver].balance_seed.add(_numTokens);   // ?: начисление токенов на баланс
            }
            emit Transfer(msg.sender, _receiver, _numTokens);
            return true;
        }
    }

    // COMMENT_FUNC: Функция TransferFrom является аналогом функции утверждения. Это позволяет делегату,
    // одобренному для снятия средств, переводить средства владельца на сторонний счет.
    function transferFrom(address _owner, address _buyer, uint256 _numTokens) public override returns (bool) {
        if (structUsers_[_owner].role == Role.SYSTEM_OWNER) { // !: if пользователь, с которого снимают деньги владелец
            require(_numTokens <= structUsers_[_owner].balance_overall);         // ?: проверка баланса
		    require(_numTokens <= allowed[_owner][msg.sender]);                  // ?: проверка баланса

            structUsers_[_owner].balance_overall = structUsers_[_owner].balance_overall.sub(_numTokens); // ?: снятие токенов с баланса
		    allowed[_owner][msg.sender] = allowed[_owner][msg.sender].sub(_numTokens);                   // ?: снятие токенов с баланса
            // PRIVATE
            if (structPhases_[privateProviderAdr].statusPhase == true) {
                structUsers_[_buyer].balance_private = structUsers_[_buyer].balance_private.add(_numTokens); // ?: начисление токенов на баланс
            // PUBLIC
            } else if (structPhases_[publicProviderAdr].statusPhase == true) {
                structUsers_[_buyer].balance_public = structUsers_[_buyer].balance_public.add(_numTokens);   // ?: начисление токенов на баланс
            // SEED
            } else {
                structUsers_[_buyer].balance_seed = structUsers_[_buyer].balance_seed.add(_numTokens);       // ?: начисление токенов на баланс
            }
            emit Transfer(_owner, _buyer, _numTokens);
            return true;
        } else { // !: if это обычны пользователь
            // PRIVATE
            if (structPhases_[privateProviderAdr].statusPhase == true) {
                require(_numTokens <= structUsers_[_owner].balance_private); // ?: проверка баланса
                require(_numTokens <= allowed[_owner][msg.sender]);          // ?: проверка баланса

                structUsers_[_owner].balance_private = structUsers_[_owner].balance_private.sub(_numTokens); // ?: снятие токенов с баланса
                allowed[_owner][msg.sender] = allowed[_owner][msg.sender].sub(_numTokens);                   // ?: снятие токенов с баланса
                structUsers_[_buyer].balance_private = structUsers_[_buyer].balance_private.add(_numTokens); // ?: начисление токенов на баланс
            // PUBLIC
            } else if (structPhases_[publicProviderAdr].statusPhase == true) {
                require(_numTokens <= structUsers_[_owner].balance_public); // ?: проверка баланса
                require(_numTokens <= allowed[_owner][msg.sender]);         // ?: проверка баланса

                structUsers_[_owner].balance_public = structUsers_[_owner].balance_public.sub(_numTokens); // ?: снятие токенов с баланса
                allowed[_owner][msg.sender] = allowed[_owner][msg.sender].sub(_numTokens);                 // ?: снятие токенов с баланса
                structUsers_[_buyer].balance_public = structUsers_[_buyer].balance_public.add(_numTokens); // ?: начисление токенов на баланс
            // SEED
            } else {
                require(_numTokens <= structUsers_[_owner].balance_seed); // ?: проверка баланса
                require(_numTokens <= allowed[_owner][msg.sender]);       // ?: проверка баланса

                structUsers_[_owner].balance_seed = structUsers_[_owner].balance_seed.sub(_numTokens); // ?: снятие токенов с баланса
                allowed[_owner][msg.sender] = allowed[_owner][msg.sender].sub(_numTokens);             // ?: снятие токенов с баланса
                structUsers_[_buyer].balance_seed = structUsers_[_buyer].balance_seed.add(_numTokens); // ?: начисление токенов на баланс
            }
            emit Transfer(_owner, _buyer, _numTokens);
            return true;
        }
    }

    // COMMENT_FUNC: Функция позволяет владельцу, т. е. msg.sender одобрить делегированную учетную запись
    // для снятия токенов со своей учетной записи и передачи их на другие учетные записи.
    function approve(address _delegate, uint256 _numTokens) public override returns (bool) {
        allowed[msg.sender][_delegate] = _numTokens;      // установка разрешенной суммы для снятие токенов с определенного АДРЕСА
        emit Approval(msg.sender, _delegate, _numTokens);
        return true;
    }

    // COMMENT_FUNC: Функци возвращает текущее утвержденное количество токенов владельцем
    // конкретному делегату, как установлено в функции утверждения.
    function allowance(address _owner, address _delegate) public override view returns (uint) {
        return allowed[_owner][_delegate];
    }

    // COMMENT_FUNC: Функция добавления адреса в черный лист
    function addBlackList(address _userAdr) public onlyOwner {
        blackList.push(_userAdr); // ?: Добавление пользователя в черный список
    }

    //COMMENT_FUNC: Функция удаления адреса из черного списка
    function removeBlackList(address _userAdr) public onlyOwner {
        address tempAdr;
        uint index;
        for(uint i = 0; i < blackList.length; i++) {
            tempAdr = blackList[i];
            if(tempAdr == _userAdr) {
                index = i;
            }
        }
        delete blackList[index];
    }
}