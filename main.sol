pragma solidity >=0.7.0 <0.9.0;

contract CryptoMonster {
    address owner;
    string name;
    string symbol;
    uint256 totalCryptoMonster;

    // создание привязки адресов к их балансу
    mapping (address => uint256) public balance;

    constructor(string memory _name, string memory _symbol, uint256 _totalCryptoMonster) public {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        totalCryptoMonster = _totalCryptoMonster;

        balance[owner] = totalCryptoMonster;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    function totalSupply() view public returns(uint256) {
        return totalCryptoMonster;
    }   

    function balanceOf(address _owner) view public returns(uint256) {
        return balance[_owner];
    }

    function transfer(address _to, uint256 _value) public returns(bool) {
        require (balance[msg.sender] > _value);

        address _from = msg.sender;
        owner = _to;
        emit Transfer(_from, _to, _value);
        balance[_from] = balance[_from] - _value;
        balance[_to] = balance[_to] + _value;
        return true;




    }



}
