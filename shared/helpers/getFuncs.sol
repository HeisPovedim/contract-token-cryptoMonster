// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract getFuncs {
    // Получения хэш-пароля
    function get_hash(string memory _password) public pure returns(bytes32) {
            return(keccak256(abi.encodePacked(_password)));
    }
}