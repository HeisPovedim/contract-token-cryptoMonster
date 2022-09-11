// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./modifireFunc.sol";

contract helpresFunc is modifireFunc {

    // COMMENT_FUNC: Получения хэш-пароля.
    function get_keccak256(string memory _hash) public pure returns(bytes32) {
            return(keccak256(abi.encodePacked(_hash)));
    }

    // COMMENT_FUNC: Получение списка 

    // COMMENT_FUNC: Получение белого списка.
    function get_whiteList() public onlyOwnerAndPrivateProvider view returns (address[] memory) {
        return(whiteList);
    }

    // COMMENT_FUNC: Получение черного списка.
    function get_blackList() public onlyOwner view returns (address[] memory) {
        return(blackList);
    }
}