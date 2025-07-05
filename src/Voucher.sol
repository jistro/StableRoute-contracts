// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Voucher {
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


    uint256 private voucherIdCounter;
    address private usdc;
    address private tokenMessenger;
    AddressTypeProposal private sudoAccount;
    mapping(address => bool) private hasAdmin;
    mapping(uint256 => VoucherMetaData) private vouchers;
    
    modifier onlyAdmin() {
        if (!hasAdmin[msg.sender]) {
            revert("Not an admin");
        }
        _;
    }

    modifier onlySudo() {
        if (msg.sender != sudoAccount.actual) {
            revert("Not the sudo account");
        }
        _;
    }

    constructor(
        address _usdc,
        address _tokenMessenger,
        address _sudoAccount
    ) {
        usdc = _usdc;
        tokenMessenger = _tokenMessenger;
        sudoAccount = AddressTypeProposal({
            actual: _sudoAccount,
            proposal: address(0),
            timeToAccept: 0
        });
        hasAdmin[_sudoAccount] = true; // Initial sudo account is also an admin
    }

    function prepareVoucher(
        string memory name,
        string memory nationality,
        address recipient,
        uint256 amount
    ) external onlyAdmin returns (uint256) {
        voucherIdCounter++;

        vouchers[voucherIdCounter] = VoucherMetaData({
            name: name,
            nationality: nationality,
            recipient: recipient,
            amount: amount,
            isRedeemed: false
        });

        return voucherIdCounter;
    }


    function redeemVoucher(
        uint256 voucherId,
        uint32 destinationDomain
    ) external onlyAdmin returns (uint256) {
        VoucherMetaData memory voucher = vouchers[voucherId];
        if (voucher.recipient == address(0)) {
            revert("Voucher does not exist");
        }
        
        if (destinationDomain == 3) {
            /// @dev because CCTP's destinationDomain is 3 for ARB we send it directly to the recipient
            IERC20(usdc).transfer(voucher.recipient, voucher.amount);
            
        } else {
            /// @dev for other domains, use the token messenger to burn and mint
            
            /// @dev approve usdc for the token messenger
            IERC20(usdc).approve(tokenMessenger, voucher.amount);

            /// @dev burn the USDC and mint on the destination domain
            ITokenMessengerV2(tokenMessenger).depositForBurn(
                voucher.amount,
                destinationDomain,
                bytes32(uint256(uint160(voucher.recipient))), // Convert address to bytes32
                usdc,
                bytes32(uint256(uint160(address(0)))),
                1_000000, // maxFee
                1000 // minFinalityThreshold (1000 or less for Fast Transfer)
            );
        }

        voucher.isRedeemed = true;

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
        if (block.timestamp < sudoAccount.timeToAccept)
            revert("Not yet time to accept proposal");
        sudoAccount = AddressTypeProposal({
            actual: sudoAccount.proposal,
            proposal: address(0),
            timeToAccept: 0
        });
    }

    function addAdmin(address newAdmin) external onlySudo {
        hasAdmin[newAdmin] = true;
    }

    function removeAdmin(address admin) external onlySudo {
        hasAdmin[admin] = false;
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
