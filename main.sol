// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract SampleToken is IERC20 {
    using SafeMath for uint256;

    // COMMENT: Общие сведения по токену.
    string public constant name = "CryptoMonster";
    string public constant symbol = "CMON";
    uint8 public constant decimals = 12;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;

    uint256 totalSupply_;

    constructor(uint256 total) {
        totalSupply_ = total;
        balances[msg.sender] = totalSupply_;
    }

    // COMMENT_FUNC: Функция вернет количество всех токенов, выделенных этим контрактом, независимо от владельца.
    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    // COMMENT_FUNC: Функция вернет текущий баланс токена учетной записи, идентифицированный по адресу его владельца.
    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    // COMMENT_FUNC: Функция перевода используется для перемещения количества токенов numTokens с баланса владельца
    // на баланс другого пользователя или получателя. Передающий владелец — msg.sender, 
    // то есть тот, кто выполняет функцию.
    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    // COMMENT_FUNC: Функция позволяет владельцу, т. е. msg.sender, одобрить делегированную учетную запись
    // для снятия токенов со своей учетной записи и передачи их на другие учетные записи.
    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    // COMMENT_FUNC: Функци возвращает текущее утвержденное количество токенов владельцем
    // конкретному делегату, как установлено в функции утверждения.
    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    // COMMENT_FUNC: Функция TransferFrom является аналогом функции утверждения. Это позволяет делегату,
    // одобренному для снятия средств, переводить средства владельца на сторонний счет.
    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}