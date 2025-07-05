// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vault {
    struct AddressTypeProposal {
        address actual;
        address proposal;
        uint256 timeToAccept;
    }

    struct VoucherMetaData {
        string name;
        string nationality;
        address recipient;
        uint256 amount;
        bool isRedeemed;
    }

    error InsufficientUSDCBalance();
    error NotAnAdmin();
    error NotTheSudoAccount();
    error NotYetTimeToAcceptProposal();

    address private usdc;
    address private tokenMessenger;
    AddressTypeProposal private sudoAccount;
    address private voucherAddress;

    modifier onlySudo() {
        if (msg.sender != sudoAccount.actual) {
            revert NotTheSudoAccount();
        }
        _;
    }

    constructor(
        address _usdc,
        address _tokenMessenger,
        address _sudoAccount,
        address _voucherAddress
    ) {
        usdc = _usdc;
        tokenMessenger = _tokenMessenger;
        sudoAccount = AddressTypeProposal({
            actual: _sudoAccount,
            proposal: address(0),
            timeToAccept: 0
        });
        voucherAddress = _voucherAddress;
    }

    function sendToVoucher(uint256 amount) external {

        /// @dev approve usdc for the token messenge
        IERC20(usdc).approve(tokenMessenger, amount);

        /// @dev burn the USDC and mint on the destination domain
        ITokenMessengerV2(tokenMessenger).depositForBurn(
            amount,
            3,
            bytes32(uint256(uint160(voucherAddress))), // Convert address to bytes32
            usdc,
            bytes32(uint256(uint160(address(0)))),
            1_000000, // maxFee
            1000 // minFinalityThreshold (1000 or less for Fast Transfer)
        );
    }

    function makeSudoAccountProposal(address newSudoAccount) external onlySudo {
        sudoAccount.proposal = newSudoAccount;
        sudoAccount.timeToAccept = block.timestamp + 24 hours;
    }

    function rejectSudoAccountProposal() external onlySudo {
        sudoAccount.proposal = address(0);
        sudoAccount.timeToAccept = 0;
    }

    function acceptSudoAccountProposal() external onlySudo {
        if (block.timestamp < sudoAccount.timeToAccept) {
            revert NotYetTimeToAcceptProposal();
        }
        sudoAccount = AddressTypeProposal({
            actual: sudoAccount.proposal,
            proposal: address(0),
            timeToAccept: 0
        });
    }

    function withdraw(address recipient, uint256 amount) external onlySudo {
        IERC20(usdc).transfer(recipient, amount);
    }

    function changeTokenMessenger(address newMessenger) external onlySudo {
        tokenMessenger = newMessenger;
    }

    function changeUsdcAddress(address newUsdc) external onlySudo {
        usdc = newUsdc;
    }

    function changeVoucherAddress(address newVoucherAddress) external onlySudo {
        voucherAddress = newVoucherAddress;
    }

    function getSudoInfo()
        external
        view
        returns (address actual, address proposal, uint256 timeToAccept)
    {
        return (
            sudoAccount.actual,
            sudoAccount.proposal,
            sudoAccount.timeToAccept
        );
    }

    function getUSDCAmount() external view returns (uint256) {
        return IERC20(usdc).balanceOf(msg.sender);
    }
}

interface ITokenMessengerV2 {
    function depositForBurn(
        uint256 amount,
        uint32 destinationDomain,
        bytes32 mintRecipient,
        address burnToken,
        bytes32 destinationCaller,
        uint256 maxFee,
        uint32 minFinalityThreshold
    ) external;
}
