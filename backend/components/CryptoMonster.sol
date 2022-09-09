// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

// HELLPERS && LIB
import "../shared/lib/SafeMath.sol";     // библиотека безопасного перевод средств
import "../shared/lib/IERC20.sol";       // стандарт IERC20

// COMPONENT
import "./main.sol";
import "./PhaseSeed.sol";
import "./PhasePrivate.sol";

contract CryptoMonster is IERC20, Main, PhaseSeed, PhasePrivate {
    using SafeMath for uint256; // библиотека безопасных вычислений

    // COMMENT: Общие сведения по токену.
    string public constant name = "CryptoMonster"; // название токена
    string public constant symbol = "CMON";        // тикер токена
    uint8 public constant decimals = 12;           // 1 000 000 000 000 == 1 CMON ; конвертация eth в wei: https://eth-converter.com/

    mapping(address => mapping (address => uint256)) allowed; // делегированные пользоатели

    uint256 totalSupply_;                    // общее кол-во токенов при старте системы
    uint256 public tokenPrice_ = 1000000000; // 1 токен за 0.00075 ETH => 750000000; 0.001ETH => 1000000000 WEI | ЗНАЧЕНИЕ УКАЗЫВАЕТСЯ В WEI

    // COMMENT: Набор начальных системных пользователей.
    address constant ownerAdr = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;           // ВЛАДЕЛЕЦ
    address constant privateProviderAdr = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2; // PRIVATE ПРОВАЙДЕР
    address constant publicProviderAdr = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;  // PUBLIC ПРОВАЙДЕР

    constructor(uint256 total) {
        totalSupply_ = total; // кол-во токенов при старте

        structUsers_[ownerAdr] = structUser(Role.SYSTEM_OWNER ,"owner", get_keccak256("3412"), totalSupply_, 0, 0, 0);             // владелец 
        structUsers_[privateProviderAdr] = structUser(Role.SYSTEM_PRIVATE, "Private provider", get_keccak256("1423"), 0, 0, 0, 0); // private провайдер
        allowed[ownerAdr][privateProviderAdr] = totalSupply_;                                                                      // делегирование PRIVATE ПРОВАЙДЕРА
        structPhases_[privateProviderAdr].statusPhase = false;                                                                     // присвоение статуса фазы
        structUsers_[publicProviderAdr] = structUser(Role.SYSTEM_PUBLIC, "Public provider", get_keccak256("2314"), 0, 0, 0, 0);    // public провайдер
        allowed[ownerAdr][publicProviderAdr] = totalSupply_;                                                                       // делегирование PUBLIC ПРОВАЙДЕРА
        structPhases_[publicProviderAdr].statusPhase = false;                                                                      // присвоение статуса фазы

        // COMMENT: Перечесление средств инвесторам.
        // transfer(investorFirstAdr, 600000);  // Investor1
        // transfer(investorSecondAdr, 800000); // Investor2
        // transfer(bestFriendAdr, 400000);     // Best friend
    }

    // COMMENT_FUNC: Функция покупки токена
    function buy(uint256 _amount) external payable {
        // например: покупатель хочет 1 токенов, для этого он должен отправить 5 вэй
        require(msg.value == _amount * tokenPrice_, "Need to send exact amount of wei");
        require(structPhases_[privateProviderAdr].statusPhase == false && structPhases_[publicProviderAdr].statusPhase == false, "During the seed phase, the transfer of tokens is prohibited");
        if (structPhases_[privateProviderAdr].statusPhase == true) {
            structUsers_[msg.sender].balance_private = structUsers_[msg.sender].balance_private.add(_amount);
        } else if (structPhases_[publicProviderAdr].statusPhase == true) {
            structUsers_[msg.sender].balance_public = structUsers_[msg.sender].balance_public.add(_amount);
        }
    }

    // COMMENT_FUNC: Функция вернет количество всех токенов, выделенных этим контрактом, независимо от владельца.
    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    // COMMENT_FUNC: Функция вернет текущий баланс токена учетной записи, идентифицированный по адресу его владельца.
    function balanceOf(address _tokenOwner) public override view returns (uint256) {
        if(structPhases_[privateProviderAdr].statusPhase == false && structPhases_[publicProviderAdr].statusPhase == false) { // !: if фаза SEED
            return structUsers_[_tokenOwner].balance_seed;
        } else if (structPhases_[privateProviderAdr].statusPhase == true) {                                                   // !: if фаза PRIVATE
            return structUsers_[_tokenOwner].balance_private;
        } else if (structPhases_[publicProviderAdr].statusPhase == true) {                                                    // !: if фаза PUBLIC
            return structUsers_[_tokenOwner].balance_public;
        } else return 0;
    }

    // COMMENT_FUNC: Функция перевода используется для перемещения количества токенов _numTokens с баланса владельца
    // на баланс другого пользователя или получателя. Передающий владелец — msg.sender, 
    // то есть тот, кто выполняет функцию.
    function transfer(address _receiver, uint256 _numTokens) public override returns (bool) {
        if (validatePhase("seed", privateProviderAdr, publicProviderAdr) == true)  {                             // !: if фаза SEED
            if (validateOwner() == true) {                                                                         // !: if пользователь админ
                require(_numTokens <= structUsers_[msg.sender].balance_overall);                                     // !: проверка на переполнение баланса владельца
                require (structUsers_[msg.sender].role == Role.INVESTOR, "Your not investor");                       // !: проверка того, что msg.sender является инвестором
                require (structUsers_[_receiver].role == Role.INVESTOR, "Your not investor");                        // !: проверка того, что msg.sender является инвестором

                structUsers_[msg.sender].balance_overall = structUsers_[msg.sender].balance_overall.sub(_numTokens); // ?: снятие токенов с баланса владельца
                structUsers_[_receiver].balance_seed = structUsers_[_receiver].balance_seed.add(_numTokens);         // ?: начисление токенов на баланс SEED
                emit Transfer(msg.sender, _receiver, _numTokens);                                                    // ?: оповещение об успешной операции перевода
                return true;
            } else {                                                                                               // !: if пользователь не админ
                require(_numTokens <= structUsers_[msg.sender].balance_seed);                                        // !: проверка на переполнение баланса владельца
                require (structUsers_[msg.sender].role == Role.INVESTOR, "Your not investor");                       // !: проверка того, что msg.sender является инвестором
                require (structUsers_[_receiver].role == Role.INVESTOR, "Your not investor");                        // !: проверка того, что msg.sender является инвестором

                structUsers_[msg.sender].balance_seed = structUsers_[msg.sender].balance_seed.sub(_numTokens);       // ?: снятие токенов с баланса владельца
                structUsers_[_receiver].balance_seed = structUsers_[_receiver].balance_seed.add(_numTokens);         // ?: начисление токенов на баланс SEED
                emit Transfer(msg.sender, _receiver, _numTokens);                                                    // ?: оповещение об успешной операции перевода
                return true;
            }
        } else if (validatePhase("private", privateProviderAdr, publicProviderAdr) == true) {                    // !: if фаза PRIVATE
            if (validateOwner() == true) {                                                                         // !: if пользователь админ
                require(_numTokens <= structUsers_[msg.sender].balance_overall);                                     // !: проверка на переполнение баланса владельца

                structUsers_[msg.sender].balance_overall = structUsers_[msg.sender].balance_overall.sub(_numTokens); // ?: снятие токенов с баланса владельца
                structUsers_[_receiver].balance_private = structUsers_[_receiver].balance_private.add(_numTokens);   // ?: начисление токенов на баланс PRIVATE
                emit Transfer(msg.sender, _receiver, _numTokens);                                                    // ?: оповещение об успешной операции перевода
                return true;
            } else {                                                                                               // !: if пользователь не админ
                require(_numTokens <= structUsers_[msg.sender].balance_private);                                     // !: проверка на переполнение баланса владельца

                structUsers_[msg.sender].balance_private = structUsers_[msg.sender].balance_private.sub(_numTokens); // ?: снятие токенов с баланса владельца
                structUsers_[_receiver].balance_private = structUsers_[_receiver].balance_private.add(_numTokens);   // ?: начисление токенов на баланс PRIVATE
                emit Transfer(msg.sender, _receiver, _numTokens);                                                    // ?: оповещение об успешной операции перевода
                return true;
            }
        } else if (validatePhase("public", privateProviderAdr, publicProviderAdr) == true) {                     // !: if фаза PUBLIC
            if (validateOwner() == true) {                                                                         // !: if пользователь админ
                require(_numTokens <= structUsers_[msg.sender].balance_overall);                                     // !: проверка на переполнение баланса владельца

                structUsers_[msg.sender].balance_overall = structUsers_[msg.sender].balance_overall.sub(_numTokens); // ?: снятие токенов с баланса владельца
                structUsers_[_receiver].balance_public = structUsers_[_receiver].balance_public.add(_numTokens);     // ?: начисление токенов на баланс PUBLIC
                emit Transfer(msg.sender, _receiver, _numTokens);                                                    // ?: оповещение об успешной операции перевода
                return true;
            } else {                                                                                               // !: if пользователь не админ
                require(_numTokens <= structUsers_[msg.sender].balance_public);                                      // !: проверка на переполнение баланса владельца

                structUsers_[msg.sender].balance_public = structUsers_[msg.sender].balance_public.sub(_numTokens);   // ?: снятие токенов с баланса владельца
                structUsers_[_receiver].balance_public = structUsers_[_receiver].balance_public.add(_numTokens);     // ?: начисление токенов на баланс PUBLIC
                emit Transfer(msg.sender, _receiver, _numTokens);                                                    // ?: оповещение об успешной операции перевода
                return true;
            }
        } else return false;
    }

    // COMMENT_FUNC: Функция TransferFrom является аналогом функции утверждения. Это позволяет делегату,
    // одобренному для снятия средств, переводить средства владельца на сторонний счет.
    function transferFrom(address _owner, address _buyer, uint256 _numTokens) public override returns (bool) {
        if (validatePhase("seed", privateProviderAdr, publicProviderAdr) == true)  {                   // !: if фаза SEED
            if (validateOwner() == true) {                                                             // !: if пользователь является ownder'ом
                require(_numTokens <= structUsers_[_owner].balance_overall);                           // ?: проверка баланса
                require(_numTokens <= allowed[_owner][msg.sender]);                                    // ?: проверка баланса

                structUsers_[_owner].balance_seed = structUsers_[_owner].balance_seed.sub(_numTokens); // ?: снятие токенов с баланса
                allowed[_owner][msg.sender] = allowed[_owner][msg.sender].sub(_numTokens);             // ?: снятие токенов с баланса
                structUsers_[_buyer].balance_seed = structUsers_[_buyer].balance_seed.add(_numTokens); // ?: начисление токенов на баланс
                emit Transfer(_owner, _buyer, _numTokens);
                return true;
            } else {
                require(_numTokens <= structUsers_[_owner].balance_seed);                              // ?: проверка баланса
                require(_numTokens <= allowed[_owner][msg.sender]);                                    // ?: проверка баланса

                structUsers_[_owner].balance_seed = structUsers_[_owner].balance_seed.sub(_numTokens); // ?: снятие токенов с баланса
                allowed[_owner][msg.sender] = allowed[_owner][msg.sender].sub(_numTokens);             // ?: снятие токенов с баланса
                structUsers_[_buyer].balance_seed = structUsers_[_buyer].balance_seed.add(_numTokens); // ?: начисление токенов на баланс
                emit Transfer(_owner, _buyer, _numTokens);
                return true;
            }
        } else if (validatePhase("private", privateProviderAdr, publicProviderAdr) == true) {     
            if (validateOwner() == true) {                                                             // !: if пользователь является ownder'ом
                require(_numTokens <= structUsers_[_owner].balance_overall);                           // ?: проверка баланса
                require(_numTokens <= allowed[_owner][msg.sender]);                                    // ?: проверка баланса

                structUsers_[_owner].balance_seed = structUsers_[_owner].balance_seed.sub(_numTokens); // ?: снятие токенов с баланса
                allowed[_owner][msg.sender] = allowed[_owner][msg.sender].sub(_numTokens);             // ?: снятие токенов с баланса
                structUsers_[_buyer].balance_seed = structUsers_[_buyer].balance_seed.add(_numTokens); // ?: начисление токенов на баланс
                emit Transfer(_owner, _buyer, _numTokens);
                return true;
            } else {
                require(_numTokens <= structUsers_[_owner].balance_private);                              // ?: проверка баланса
                require(_numTokens <= allowed[_owner][msg.sender]);                                    // ?: проверка баланса

                structUsers_[_owner].balance_private = structUsers_[_owner].balance_private.sub(_numTokens); // ?: снятие токенов с баланса
                allowed[_owner][msg.sender] = allowed[_owner][msg.sender].sub(_numTokens);             // ?: снятие токенов с баланса
                structUsers_[_buyer].balance_private = structUsers_[_buyer].balance_private.add(_numTokens); // ?: начисление токенов на баланс
                emit Transfer(_owner, _buyer, _numTokens);
                return true;
            }
        } else if (validatePhase("public", privateProviderAdr, publicProviderAdr) == true) { 
            if (validateOwner() == true) {                                                             // !: if пользователь является ownder'ом
                require(_numTokens <= structUsers_[_owner].balance_overall);                           // ?: проверка баланса
                require(_numTokens <= allowed[_owner][msg.sender]);                                    // ?: проверка баланса

                structUsers_[_owner].balance_seed = structUsers_[_owner].balance_seed.sub(_numTokens); // ?: снятие токенов с баланса
                allowed[_owner][msg.sender] = allowed[_owner][msg.sender].sub(_numTokens);             // ?: снятие токенов с баланса
                structUsers_[_buyer].balance_seed = structUsers_[_buyer].balance_seed.add(_numTokens); // ?: начисление токенов на баланс
                emit Transfer(_owner, _buyer, _numTokens);
                return true;
            } else {
                require(_numTokens <= structUsers_[_owner].balance_public);                              // ?: проверка баланса
                require(_numTokens <= allowed[_owner][msg.sender]);                                    // ?: проверка баланса

                structUsers_[_owner].balance_public = structUsers_[_owner].balance_public.sub(_numTokens); // ?: снятие токенов с баланса
                allowed[_owner][msg.sender] = allowed[_owner][msg.sender].sub(_numTokens);             // ?: снятие токенов с баланса
                structUsers_[_buyer].balance_public = structUsers_[_buyer].balance_public.add(_numTokens); // ?: начисление токенов на баланс
                emit Transfer(_owner, _buyer, _numTokens);
                return true;
            }
        } else return false;
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
}