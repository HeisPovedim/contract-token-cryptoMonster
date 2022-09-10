// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract helpresFunc {
    // Получения хэш-пароля
    function get_keccak256(string memory _hash) public pure returns(bytes32) {
            return(keccak256(abi.encodePacked(_hash)));
    }
}