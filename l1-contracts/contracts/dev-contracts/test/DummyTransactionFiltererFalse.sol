// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {ITransactionFilterer} from "../../state-transition/chain-interfaces/ITransactionFilterer.sol";
import {BridgehubL2TransactionRequest} from "../../common/Messaging.sol";

contract TransactionFiltererFalse is ITransactionFilterer {
    // add this to be excluded from coverage report
    function test() internal virtual {}

    function isTransactionAllowed(BridgehubL2TransactionRequest memory) external view returns (bool) {
        return false;
    }
}