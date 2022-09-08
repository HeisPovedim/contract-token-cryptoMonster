// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "../shared/lib/SafeMath.sol";     // библиотека безопасного перевод средств
import "../shared/lib/IERC20.sol";       // стандарт IERC20
import "../shared/helpers/getFuncs.sol"; // функции получения
import "../shared/lib/structures.sol";   // шаблон структур

contract CryptoMonster is IERC20, getFuncs, structures {
    using SafeMath for uint256; // библиотека безопасных вычислений

    // COMMENT: Общие сведения по токену.
    string public constant name = "CryptoMonster"; // название токена
    string public constant symbol = "CMON";        // тикер токена
    uint8 public constant decimals = 12;           // 1 000 000 000 000 == 1 CMON ; конвертация eth в wei: https://eth-converter.com/

    mapping(address => mapping (address => uint256)) allowed; // делегированные пользоатели

    uint256 totalSupply_;                             // общее кол-во токенов при старте системы
    uint256 public constant tokenPrice_ = 1000000000; // 1 токен за 0.00075 ETH => 750000000; 0.001ETH => 1000000000 WEI | ЗНАЧЕНИЕ УКАЗЫВАЕТСЯ В WEI

    constructor(uint256 total) {
        totalSupply_ = total; // кол-во токенов при старте

        // COMMENT: Набор начальных системных пользователей.
        address ownerAdr = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;           // ВЛАДЕЛЕЦ
        address privateProviderAdr = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2; // PRIVATE ПРОВАЙДЕР
        address publicProviderAdr = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;  // PUBLIC ПРОВАЙДЕР

        structUser_[ownerAdr] = structUser("owner", get_hash("3412"), totalSupply_);           // владелец 
        structUser_[privateProviderAdr] = structUser("Private provider", get_hash("1423"), 0); // private провайдер
        allowed[ownerAdr][privateProviderAdr] = totalSupply_;                                  // делегирование PRIVATE ПРОВАЙДЕРА
        structUser_[publicProviderAdr] = structUser("Public provider", get_hash("2314"), 0);   // public провайдер
        allowed[ownerAdr][publicProviderAdr] = totalSupply_;                                   // делегирование PUBLIC ПРОВАЙДЕРА

        // @: Конструкция SEED раунда.
        // COMMENT: Набор начальных пользователей.
        address investorFirstAdr = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;  // Investor1
        address investorSecondAdr = 0x617F2E2fD72FD9D5503197092aC168c91465E7f2; // Investor2
        address bestFriendAdr = 0x17F6AD8Ef982297579C203069C1DbfFE4348c372;     // Best friend

        structUser_[investorFirstAdr] = structUser("owner", get_hash("3412"), 600000);             // инвестор 1 
        structUser_[investorSecondAdr] = structUser("Private provider", get_hash("1423"), 800000); // инвестор 2
        structUser_[bestFriendAdr] = structUser("Public provider", get_hash("2314"), 400000);      // лучший друг
    }

    // COMMENT_FUNC: Функция покупки токена
    function buy(uint256 _amount) external payable {
        // например: покупатель хочет 1 токенов, для этого он должен отправить 5 вэй
        require(msg.value == _amount * tokenPrice_, 'Need to send exact amount of wei');
        
        structUser_[msg.sender].balances = structUser_[msg.sender].balances.add(_amount);
    }

    // COMMENT_FUNC: Функция вернет количество всех токенов, выделенных этим контрактом, независимо от владельца.
    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    // COMMENT_FUNC: Функция вернет текущий баланс токена учетной записи, идентифицированный по адресу его владельца.
    function balanceOf(address _tokenOwner) public override view returns (uint256) {
        return structUser_[_tokenOwner].balances;
    }

    // COMMENT_FUNC: Функция перевода используется для перемещения количества токенов _numTokens с баланса владельца
    // на баланс другого пользователя или получателя. Передающий владелец — msg.sender, 
    // то есть тот, кто выполняет функцию.
    function transfer(address _receiver, uint256 _numTokens) public override returns (bool) {
        require(_numTokens <= structUser_[msg.sender].balances);                             // проверка баланса
        structUser_[msg.sender].balances = structUser_[msg.sender].balances.sub(_numTokens); // снятие токенов с баланса
        structUser_[_receiver].balances = structUser_[_receiver].balances.add(_numTokens);   // начисление токенов на баланс
        emit Transfer(msg.sender, _receiver, _numTokens);                                    // оповещение об успешной операции перевода
        return true;
    }

    // COMMENT_FUNC: Функция TransferFrom является аналогом функции утверждения. Это позволяет делегату,
    // одобренному для снятия средств, переводить средства владельца на сторонний счет.
    function transferFrom(address _owner, address _buyer, uint256 _numTokens) public override returns (bool) {
        require(_numTokens <= structUser_[_owner].balances); // проверка баланса
        require(_numTokens <= allowed[_owner][msg.sender]);  // проверка баланса

        structUser_[_owner].balances = structUser_[_owner].balances.sub(_numTokens); // снятие токенов с баланса
        allowed[_owner][msg.sender] = allowed[_owner][msg.sender].sub(_numTokens);   // снятие токенов с баланса
        structUser_[_buyer].balances = structUser_[_buyer].balances.add(_numTokens); // начисление токенов на баланс
        emit Transfer(_owner, _buyer, _numTokens);
        return true;
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