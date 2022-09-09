// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);                                 // общее количество токенов в системе
    function balanceOf(address _account) external view returns (uint256);                   // позволяет посмотреть баланс любого пользователя
    function allowance(address _owner, address _spender) external view returns (uint256);   // посмотреть сколько АДРЕС owner разрешил использовать свое  количество токенов АДРЕСУ spender 

    function transfer(address _to, uint256 _amount) external returns (bool);                    // переслает  деньги с msg.sender другому пользователю
    function approve(address _spender, uint256 _amount) external returns (bool);                // разрешает какому-то АДРЕСУ распоряжаться определенным кол-вом токенов
    function transferFrom(address _to, address _from, uint256 _amount) external returns (bool); // от когого-то АДРЕСА пересылает на определенный АДРЕС кол-во токенов

    event Transfer(address indexed _from, address indexed _to, uint256 _value);        // евент о том, что произошел transfer c 1-го аккаунта на 2-ой, вызывает когда мы переводим токены
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);  // вызывает когда мы с помощью функции: "approve", разрешаем использовать токены
}