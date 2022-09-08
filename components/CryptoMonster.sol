// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "../shared/lib/SafeMath.sol";
import "../shared/lib/IERC20.sol";

contract CryptoMonster is IERC20  {
    using SafeMath for uint256; // библиотека безопасных вычислений

    // COMMENT: Общие сведения по токену.
    string public constant name = "CryptoMonster";  // имя токена
    string public constant symbol = "CMON";         // тикер токена
    uint8 public constant decimals = 12;            // 1 000 000 000 000 == 1 CMON ; конвертация eth в wei: https://eth-converter.com/

    // COMMENT: Структура пользователей.
    struct structUser {
        string login;       // логин
        bytes32 password;   // пароль
        uint256 balances;   // баланс
    }
    mapping (address => structUser) structUser_;

    mapping(address => string) logins;                          // логины пользователей
    mapping(address => uint256) balances;                       // баланс по адресу
    mapping(address => mapping (address => uint256)) allowed;   // делегированные пользоатели

    uint256 totalSupply_;
    uint256 public constant tokenPrice_ = 1000000000; // 1 токен за 0.00075 ETH => 750000000; 0.001ETH => 1000000000 WEI | ЗНАЧЕНИЕ УКАЗЫВАЕТСЯ В WEI

    constructor(uint256 total) {
        totalSupply_ = total;
        balances[msg.sender] = totalSupply_;
    }

    // COMMENT_FUNC: Функция покупки токена
    function buy(uint256 _amount) external payable {
        // например: покупатель хочет 1 токенов, для этого он должен отправить 5 вэй
        require(msg.value == _amount * tokenPrice_, 'Need to send exact amount of wei');
        
        balances[msg.sender] = balances[msg.sender].add(_amount);
    }

    // COMMENT_FUNC: Функция вернет количество всех токенов, выделенных этим контрактом, независимо от владельца.
    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    // COMMENT_FUNC: Функция вернет текущий баланс токена учетной записи, идентифицированный по адресу его владельца.
    function balanceOf(address _tokenOwner) public override view returns (uint256) {
        return balances[_tokenOwner];
    }

    // COMMENT_FUNC: Функция перевода используется для перемещения количества токенов _numTokens с баланса владельца
    // на баланс другого пользователя или получателя. Передающий владелец — msg.sender, 
    // то есть тот, кто выполняет функцию.
    function transfer(address _receiver, uint256 _numTokens) public override returns (bool) {
        require(_numTokens <= balances[msg.sender]);                    // проверка баланса
        balances[msg.sender] = balances[msg.sender].sub(_numTokens);    // снятие токенов с баланса
        balances[_receiver] = balances[_receiver].add(_numTokens);      // начисление токенов на баланс
        emit Transfer(msg.sender, _receiver, _numTokens);               // оповещение об успешной операции перевода
        return true;
    }

    // COMMENT_FUNC: Функция TransferFrom является аналогом функции утверждения. Это позволяет делегату,
    // одобренному для снятия средств, переводить средства владельца на сторонний счет.
    function transferFrom(address _owner, address _buyer, uint256 _numTokens) public override returns (bool) {
        require(_numTokens <= balances[_owner]);              // проверка баланса
        require(_numTokens <= allowed[_owner][msg.sender]);   // проверка баланса

        balances[_owner] = balances[_owner].sub(_numTokens);                        // снятие токенов с баланса
        allowed[_owner][msg.sender] = allowed[_owner][msg.sender].sub(_numTokens);  // снятие токенов с баланса
        balances[_buyer] = balances[_buyer].add(_numTokens);                        // начисление токенов на баланс
        emit Transfer(_owner, _buyer, _numTokens);
        return true;
    }

    // COMMENT_FUNC: Функция позволяет владельцу, т. е. msg.sender одобрить делегированную учетную запись
    // для снятия токенов со своей учетной записи и передачи их на другие учетные записи.
    function approve(address _delegate, uint256 _numTokens) public override returns (bool) {
        allowed[msg.sender][_delegate] = _numTokens;        // установка разрешенной суммы для снятие токенов с определенного АДРЕСА
        emit Approval(msg.sender, _delegate, _numTokens);   
        return true;
    }

    // COMMENT_FUNC: Функци возвращает текущее утвержденное количество токенов владельцем
    // конкретному делегату, как установлено в функции утверждения.
    function allowance(address _owner, address _delegate) public override view returns (uint) {
        return allowed[_owner][_delegate];
    }
}