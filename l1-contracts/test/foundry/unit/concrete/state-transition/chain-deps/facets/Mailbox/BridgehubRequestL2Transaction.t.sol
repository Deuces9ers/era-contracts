
// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {MailboxTest} from "./_Mailbox_Shared.t.sol";
import {ITransactionFilterer} from "solpp/state-transition/chain-interfaces/ITransactionFilterer.sol";
import {BridgehubL2TransactionRequest, L2CanonicalTransaction} from "solpp/common/Messaging.sol";
import {REQUIRED_L2_GAS_PRICE_PER_PUBDATA} from "solpp/common/Config.sol";
import {Utils} from "foundry-test/unit/concrete/Utils/Utils.sol";


contract TransactionFiltererTrue is ITransactionFilterer {
    function isTransactionAllowed(BridgehubL2TransactionRequest memory _request) external view returns (bool) {
        return true;
    }
}

contract TransactionFiltererFalse is ITransactionFilterer {
    function isTransactionAllowed(BridgehubL2TransactionRequest memory _request) external view returns (bool) {
        return false;
    }
}

contract BridgehubRequestL2TransactionTest is MailboxTest {
    function test_successWithoutFilterer() public {
        address bridgehub = makeAddr("bridgehub");

        utilsFacet.util_setBridgehub(bridgehub);
        utilsFacet.util_setBaseTokenGasPriceMultiplierDenominator(1);
        utilsFacet.util_setPriorityTxMaxGasLimit(100000000);

        BridgehubL2TransactionRequest memory req = getBridgehubRequestL2TransactionRequest();

        vm.deal(bridgehub, 100 ether);
        vm.prank(address(bridgehub));
        bytes32 canonicalTxHash = mailboxFacet.bridgehubRequestL2Transaction{value: 10 ether}(req);
        assertTrue(canonicalTxHash != bytes32(0), "canonicalTxHash should not be 0");
    }

    function test_successWithFilterer() public {
        address bridgehub = makeAddr("bridgehub");
        TransactionFiltererTrue tf = new TransactionFiltererTrue();

        utilsFacet.util_setBridgehub(bridgehub);
        utilsFacet.util_setTransactionFilterer(address(tf));
        utilsFacet.util_setBaseTokenGasPriceMultiplierDenominator(1);
        utilsFacet.util_setPriorityTxMaxGasLimit(100000000);

        BridgehubL2TransactionRequest memory req = getBridgehubRequestL2TransactionRequest();

        vm.deal(bridgehub, 100 ether);
        vm.prank(address(bridgehub));
        bytes32 canonicalTxHash = mailboxFacet.bridgehubRequestL2Transaction{value: 10 ether}(req);
        assertTrue(canonicalTxHash != bytes32(0), "canonicalTxHash should not be 0");
    }

    function test_revertWhen_FalseFilterer() public {
        address bridgehub = makeAddr("bridgehub");
        TransactionFiltererFalse tf = new TransactionFiltererFalse();

        utilsFacet.util_setBridgehub(bridgehub);
        utilsFacet.util_setTransactionFilterer(address(tf));
        utilsFacet.util_setBaseTokenGasPriceMultiplierDenominator(1);
        utilsFacet.util_setPriorityTxMaxGasLimit(100000000);

        BridgehubL2TransactionRequest memory req = getBridgehubRequestL2TransactionRequest();

        vm.deal(bridgehub, 100 ether);
        vm.prank(address(bridgehub));
        vm.expectRevert(bytes("tf"));
        mailboxFacet.bridgehubRequestL2Transaction{value: 10 ether}(req);
    }

    function getBridgehubRequestL2TransactionRequest() private returns (BridgehubL2TransactionRequest memory req) {
        bytes[] memory factoryDeps = new bytes[](1);
        factoryDeps[0] = "11111111111111111111111111111111";

        req = BridgehubL2TransactionRequest({
            sender: sender,
            contractL2: makeAddr("contractL2"),
            mintValue: 2 ether,
            l2Value: 10000,
            l2Calldata: "",
            l2GasLimit: 10000000,
            l2GasPerPubdataByteLimit: REQUIRED_L2_GAS_PRICE_PER_PUBDATA,
            factoryDeps: factoryDeps,
            refundRecipient: sender
        });
    }
}