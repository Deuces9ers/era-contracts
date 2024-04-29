// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

contract ConstructorForwarder OxCD84597aD4eb60FF346b54395bde47B878e76F13 {
    constructor(addressOxCD84597aD4eb60FF346b54395bde47B878e76F13 to, bytes memory data) payable {
        (bool success, ) = payable(to).call{value: msg.value}(data);
        require(success);
    }
}
