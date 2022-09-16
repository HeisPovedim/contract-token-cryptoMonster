// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "../shared/helpers/validateFuncs.sol";

contract PhasePublic is validateFuncs {

    // COMMENT_FUNC: Функция изменения стоимости токена.
    function changeTokenAmountPricePublic (uint _price) public onlyPublicProvider {
        tokenAmount_ = _price;
    }

}