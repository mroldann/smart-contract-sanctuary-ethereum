// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.17;

import {VM} from "enso-weiroll/VM.sol";
import {MinimalWallet} from "shortcuts-contracts/wallet/MinimalWallet.sol";
import {AccessController} from "shortcuts-contracts/access/AccessController.sol";

contract SolverEnsoShortcuts is VM, MinimalWallet, AccessController {
    address private constant settlement = 0x9008D19f58AAbD9eD0D60971565AA8510560ab41;

    constructor(address owner) {
        _setPermission(OWNER_ROLE, owner, true);
    }

    // @notice Execute a shortcut from a solver
    // @param commands An array of bytes32 values that encode calls
    // @param state An array of bytes that are used to generate call data for each command
    function executeShortcut(bytes32[] calldata commands, bytes[] calldata state)
        external
        payable
        returns (bytes[] memory)
    {
        // we could use the AccessController here to check if the msg.sender is the settlement address
        // but as it's a hot path we do a less gas intensive check
        if (msg.sender != settlement) revert NotPermitted();
        return _execute(commands, state);
    }
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.16;

import "./CommandBuilder.sol";

abstract contract VM {
    using CommandBuilder for bytes[];

    uint256 constant FLAG_CT_DELEGATECALL = 0x00; // Delegate call not currently supported
    uint256 constant FLAG_CT_CALL = 0x01;
    uint256 constant FLAG_CT_STATICCALL = 0x02;
    uint256 constant FLAG_CT_VALUECALL = 0x03;
    uint256 constant FLAG_CT_MASK = 0x03;
    uint256 constant FLAG_DATA = 0x20;
    uint256 constant FLAG_EXTENDED_COMMAND = 0x40;
    uint256 constant FLAG_TUPLE_RETURN = 0x80;

    uint256 constant SHORT_COMMAND_FILL =
        0x000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    error ExecutionFailed(
        uint256 command_index,
        address target,
        string message
    );

    function _execute(bytes32[] calldata commands, bytes[] memory state)
        internal
        returns (bytes[] memory)
    {
        bytes32 command;
        uint256 flags;
        bytes32 indices;

        bool success;
        bytes memory outData;

        uint256 commandsLength = commands.length;
        uint256 indicesLength;
        for (uint256 i; i < commandsLength; i = _uncheckedIncrement(i)) {
            command = commands[i];
            flags = uint256(uint8(bytes1(command << 32)));

            if (flags & FLAG_EXTENDED_COMMAND != 0) {
                i = _uncheckedIncrement(i);
                indices = commands[i];
                indicesLength = 32;
            } else {
                indices = bytes32(uint256(command << 40) | SHORT_COMMAND_FILL);
                indicesLength = 6;
            }

            if (flags & FLAG_CT_MASK == FLAG_CT_CALL) {
                (success, outData) = address(uint160(uint256(command))).call( // target
                    // inputs
                    flags & FLAG_DATA == 0
                        ? state.buildInputs(
                            bytes4(command), // selector
                            indices,
                            indicesLength
                        )
                        : state[
                            uint8(bytes1(indices)) &
                            CommandBuilder.IDX_VALUE_MASK
                        ]
                );
            } else if (flags & FLAG_CT_MASK == FLAG_CT_STATICCALL) {
                (success, outData) = address(uint160(uint256(command))) // target
                    .staticcall(
                        // inputs
                        flags & FLAG_DATA == 0
                            ? state.buildInputs(
                                bytes4(command), // selector
                                indices,
                                indicesLength
                            )
                            : state[
                                uint8(bytes1(indices)) &
                                CommandBuilder.IDX_VALUE_MASK
                            ]
                    );
            } else if (flags & FLAG_CT_MASK == FLAG_CT_VALUECALL) {
                bytes memory v = state[
                    uint8(bytes1(indices)) &
                    CommandBuilder.IDX_VALUE_MASK
                ];
                require(v.length == 32, "Value must be 32 bytes");
                uint256 callEth = uint256(bytes32(v));
                (success, outData) = address(uint160(uint256(command))).call{ // target
                    value: callEth
                }(
                    // inputs
                    flags & FLAG_DATA == 0
                        ? state.buildInputs(
                            bytes4(command), // selector
                            indices << 8, // skip value input
                            indicesLength - 1 // max indices length reduced by value input
                        )
                        : state[
                            uint8(bytes1(indices << 8)) & // first byte after value input
                            CommandBuilder.IDX_VALUE_MASK
                        ]
                );
            } else {
                revert("Invalid calltype");
            }

            if (!success) {
                string memory message = "Unknown";
                if (outData.length > 68) {
                    // This might be an error message, parse the outData
                    // Estimate the bytes length of the possible error message
                    uint256 estimatedLength = _estimateBytesLength(outData, 68);
                    // Remove selector. First 32 bytes should be a pointer that indicates the start of data in memory
                    assembly {
                        outData := add(outData, 4)
                    }
                    uint256 pointer = uint256(bytes32(outData));
                    if (pointer == 32) {
                        // Remove pointer. If it is a string, the next 32 bytes will hold the size
                        assembly {
                            outData := add(outData, 32)
                        }
                        uint256 size = uint256(bytes32(outData));
                        // If the size variable is the same as the estimated bytes length, we can be fairly certain
                        // this is a dynamic string, so convert the bytes to a string and emit the message. While an
                        // error function with 3 static parameters is capable of producing a similar output, there is
                        // low risk of a contract unintentionally emitting a message.
                        if (size == estimatedLength) {
                            // Remove size. The remaining data should be the string content
                            assembly {
                                outData := add(outData, 32)
                            }
                            message = string(outData);
                        }
                    }
                }
                revert ExecutionFailed({
                    command_index: flags & FLAG_EXTENDED_COMMAND == 0
                        ? i
                        : i - 1,
                    target: address(uint160(uint256(command))),
                    message: message
                });
            }

            if (flags & FLAG_TUPLE_RETURN != 0) {
                state.writeTuple(bytes1(command << 88), outData);
            } else {
                state = state.writeOutputs(bytes1(command << 88), outData);
            }
        }
        return state;
    }

    function _estimateBytesLength(bytes memory data, uint256 pos) internal pure returns (uint256 estimate) {
        uint256 length = data.length;
        estimate = length - pos; // Assume length equals alloted space
        for (uint256 i = pos; i < length; ) {
            if (data[i] == 0) {
                // Zero bytes found, adjust estimated length
                estimate = i - pos;
                break;
            }
            unchecked {
                ++i;
            }
        }
    }

    function _uncheckedIncrement(uint256 i) private pure returns (uint256) {
        unchecked {
            ++i;
        }
        return i;
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "../access/ACL.sol";
import "../access/Roles.sol";

contract MinimalWallet is ACL, Roles, ERC721Holder, ERC1155Holder {
    using SafeERC20 for IERC20;

    enum Protocol {
        ETH,
        ERC20,
        ERC721,
        ERC1155
    }

    struct TransferNote {
        Protocol protocol;
        address token;
        uint256[] ids;
        uint256[] amounts;
    }

    struct ApprovalNote {
        Protocol protocol;
        address token;
        address[] operators;
    }

    error WithdrawFailed();
    error InvalidArrayLength();

    ////////////////////////////////////////////////////
    // External functions //////////////////////////////
    ////////////////////////////////////////////////////

    // @notice Withdraw an array of assets
    // @dev Works for ETH, ERC20s, ERC721s, and ERC1155s
    // @param notes A tuple that contains the protocol id, token address, array of ids and amounts
    function withdraw(TransferNote[] calldata notes) external isPermitted(OWNER_ROLE) {
        TransferNote memory note;
        Protocol protocol;
        uint256[] memory ids;
        uint256[] memory amounts;

        uint256 length = notes.length;
        for (uint256 i; i < length; ) {
            note = notes[i];
            protocol = note.protocol;
            if (protocol == Protocol.ETH) {
                amounts = note.amounts;
                if (amounts.length != 1) revert InvalidArrayLength();
                _withdrawETH(amounts[0]);
            } else if (protocol == Protocol.ERC20) {
                amounts = note.amounts;
                if (amounts.length != 1) revert InvalidArrayLength();
                _withdrawERC20(IERC20(note.token), amounts[0]);
            } else if (protocol == Protocol.ERC721) {
                ids = note.ids;
                _withdrawERC721s(IERC721(note.token), ids);
            } else if (protocol == Protocol.ERC1155) {
                ids = note.ids;
                amounts = note.amounts;
                _withdrawERC1155s(IERC1155(note.token), ids, amounts);
            }
            unchecked {
                ++i;
            }
        }
    }

    // @notice Withdraw ETH from this contract to the msg.sender
    // @param amount The amount of ETH to be withdrawn
    function withdrawETH(uint256 amount) external isPermitted(OWNER_ROLE) {
        _withdrawETH(amount);
    }

    // @notice Withdraw ERC20s
    // @param erc20s An array of erc20 addresses
    // @param amounts An array of amounts for each erc20
    function withdrawERC20s(
        IERC20[] calldata erc20s,
        uint256[] calldata amounts
    ) external isPermitted(OWNER_ROLE) {
        uint256 length = erc20s.length;
        if (amounts.length != length) revert InvalidArrayLength();
        for (uint256 i; i < length; ) {
            _withdrawERC20(erc20s[i], amounts[i]);
            unchecked {
                ++i;
            }
        }
    }

    // @notice Withdraw multiple ERC721 ids for a single ERC721 contract
    // @param erc721 The address of the ERC721 contract
    // @param ids An array of ids that are to be withdrawn
    function withdrawERC721s(
        IERC721 erc721,
        uint256[] calldata ids
    ) external isPermitted(OWNER_ROLE) {
        _withdrawERC721s(erc721, ids);
    }

    // @notice Withdraw multiple ERC1155 ids for a single ERC1155 contract
    // @param erc1155 The address of the ERC155 contract
    // @param ids An array of ids that are to be withdrawn
    // @param amounts An array of amounts per id
    function withdrawERC1155s(
        IERC1155 erc1155,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external isPermitted(OWNER_ROLE) {
        _withdrawERC1155s(erc1155, ids, amounts);
    }

    // @notice Revoke approval on an array of assets and operators
    // @dev Works for ERC20s, ERC721s, and ERC1155s
    // @param notes A tuple that contains the protocol id, token address, and array of operators
    function revokeApprovals(ApprovalNote[] calldata notes) external isPermitted(OWNER_ROLE) {
        ApprovalNote memory note;
        Protocol protocol;

        uint256 length = notes.length;
        for (uint256 i; i < length; ) {
            note = notes[i];
            protocol = note.protocol;
            if (protocol == Protocol.ERC20) {
                _revokeERC20Approvals(IERC20(note.token), note.operators);
            } else if (protocol == Protocol.ERC721) {
                _revokeERC721Approvals(IERC721(note.token), note.operators);
            } else if (protocol == Protocol.ERC1155) {
                _revokeERC1155Approvals(IERC1155(note.token), note.operators);
            }
            unchecked {
                ++i;
            }
        }
    }

    // @notice Revoke approval of an ERC20 for an array of operators
    // @param erc20 The address of the ERC20 token
    // @param operators The array of operators to have approval revoked
    function revokeERC20Approvals(
        IERC20 erc20,
        address[] calldata operators
    ) external isPermitted(OWNER_ROLE) {
        _revokeERC20Approvals(erc20, operators);
    }

    // @notice Revoke approval of an ERC721 for an array of operators
    // @param erc721 The address of the ERC721 token
    // @param operators The array of operators to have approval revoked
    function revokeERC721Approvals(
        IERC721 erc721,
        address[] calldata operators
    ) external isPermitted(OWNER_ROLE) {
        _revokeERC721Approvals(erc721, operators);
    }

    // @notice Revoke approval of an ERC1155 for an array of operators
    // @param erc1155 The address of the ERC1155 token
    // @param operators The array of operators to have approval revoked
    function revokeERC1155Approvals(
        IERC1155 erc1155,
        address[] calldata operators
    ) external isPermitted(OWNER_ROLE) {
        _revokeERC1155Approvals(erc1155, operators);
    }

    ////////////////////////////////////////////////////
    // Internal functions //////////////////////////////
    ////////////////////////////////////////////////////

    function _withdrawETH(uint256 amount) internal {
        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) revert WithdrawFailed();
    }

    function _withdrawERC20(IERC20 erc20, uint256 amount) internal {
        erc20.safeTransfer(msg.sender, amount);
    }

    function _withdrawERC721s(IERC721 erc721, uint256[] memory ids) internal {
        uint256 length = ids.length;
        for (uint256 i; i < length; ) {
            erc721.safeTransferFrom(address(this), msg.sender, ids[i]);
            unchecked {
                ++i;
            }
        }
    }

    function _withdrawERC1155s(IERC1155 erc1155, uint256[] memory ids, uint256[] memory amounts) internal {
        // safeBatchTransferFrom will validate the array lengths
        erc1155.safeBatchTransferFrom(address(this), msg.sender, ids, amounts, "");
    }

    function _revokeERC20Approvals(IERC20 erc20, address[] memory operators) internal {
        uint256 length = operators.length;
        for (uint256 i; i < length; ) {
            erc20.safeApprove(operators[i], 0);
            unchecked {
                ++i;
            }
        }
    }

    function _revokeERC721Approvals(IERC721 erc721, address[] memory operators) internal {
        uint256 length = operators.length;
        for (uint256 i; i < length; ) {
            erc721.setApprovalForAll(operators[i], false);
            unchecked {
                ++i;
            }
        }
    }

    function _revokeERC1155Approvals(IERC1155 erc1155, address[] memory operators) internal {
        uint256 length = operators.length;
        for (uint256 i; i < length; ) {
            erc1155.setApprovalForAll(operators[i], false);
            unchecked {
                ++i;
            }
        }
    }

    ////////////////////////////////////////////////////
    // Fallback functions //////////////////////////////
    ////////////////////////////////////////////////////

    receive() external payable {}
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.16;

import "./ACL.sol";
import "./Roles.sol";

// @notice The OWNER_ROLE must be set in the importing contract's constructor or initialize function
abstract contract AccessController is ACL, Roles {
    using StorageAPI for bytes32;

    event PermissionSet(bytes32 role, address account, bool permission);

    error UnsafeSetting();
    error InvalidAccount();

    // @notice Sets user permission over a role
    // @param role The bytes32 value of the role
    // @param account The address of the account
    // @param permission The permission status
    function setPermission(
        bytes32 role,
        address account,
        bool permission
    ) external isPermitted(OWNER_ROLE) {
        if (account == address(0)) revert InvalidAccount();
        if (role == OWNER_ROLE && account == msg.sender && permission == false)
            revert UnsafeSetting();
        _setPermission(role, account, permission);
    }

    // @notice Internal function to set user permission over a role
    // @param role The bytes32 value of the role
    // @param account The address of the account
    // @param permission The permission status
    function _setPermission(bytes32 role, address account, bool permission) internal {
        bytes32 key = _getKey(role, account);
        key.setBool(permission);
        emit PermissionSet(role, account, permission);
    }
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.16;

library CommandBuilder {
    uint256 constant IDX_VARIABLE_LENGTH = 0x80;
    uint256 constant IDX_VALUE_MASK = 0x7f;
    uint256 constant IDX_END_OF_ARGS = 0xff;
    uint256 constant IDX_USE_STATE = 0xfe;
    uint256 constant IDX_ARRAY_START = 0xfd;
    uint256 constant IDX_TUPLE_START = 0xfc;
    uint256 constant IDX_DYNAMIC_END = 0xfb;

    function buildInputs(
        bytes[] memory state,
        bytes4 selector,
        bytes32 indices,
        uint256 indicesLength
    ) internal view returns (bytes memory ret) {
        uint256 idx; // The current command index
        uint256 offsetIdx; // The index of the current free offset

        uint256 count; // Number of bytes in whole ABI encoded message
        uint256 free; // Pointer to first free byte in tail part of message
        uint256[] memory dynamicLengths = new uint256[](10); // Optionally store the length of all dynamic types (a command cannot fit more than 10 dynamic types)

        bytes memory stateData; // Optionally encode the current state if the call requires it

        // Determine the length of the encoded data
        for (uint256 i; i < indicesLength; ) {
            idx = uint8(indices[i]);
            if (idx == IDX_END_OF_ARGS) {
                indicesLength = i;
                break;
            }
            if (idx & IDX_VARIABLE_LENGTH != 0) {
                if (idx == IDX_USE_STATE) {
                    if (stateData.length == 0) {
                        stateData = abi.encode(state);
                    }
                    unchecked {
                        count += stateData.length;
                    }
                } else {
                    (dynamicLengths, offsetIdx, count, i) = setupDynamicType(
                        state,
                        indices,
                        dynamicLengths,
                        idx,
                        offsetIdx,
                        count,
                        i
                    );
                }
            } else {
                count = setupStaticVariable(state, count, idx);
            }
            unchecked {
                free += 32;
                ++i;
            }
        }

        // Encode it
        ret = new bytes(count + 4);
        assembly {
            mstore(add(ret, 32), selector)
        }
        offsetIdx = 0;
        // Use count to track current memory slot
        assembly {
            count := add(ret, 36)
        }
        for (uint256 i; i < indicesLength; ) {
            idx = uint8(indices[i]);
            if (idx & IDX_VARIABLE_LENGTH != 0) {
                if (idx == IDX_USE_STATE) {
                    assembly {
                        mstore(count, free)
                    }
                    memcpy(stateData, 32, ret, free + 4, stateData.length - 32);
                    unchecked {
                        free += stateData.length - 32;
                    }
                } else if (idx == IDX_ARRAY_START) {
                    // Start of dynamic type, put pointer in current slot
                    assembly {
                        mstore(count, free)
                    }
                    (offsetIdx, free, i, ) = encodeDynamicArray(
                        ret,
                        state,
                        indices,
                        dynamicLengths,
                        offsetIdx,
                        free,
                        i
                    );
                } else if (idx == IDX_TUPLE_START) {
                    // Start of dynamic type, put pointer in current slot
                    assembly {
                        mstore(count, free)
                    }
                    (offsetIdx, free, i, ) = encodeDynamicTuple(
                        ret,
                        state,
                        indices,
                        dynamicLengths,
                        offsetIdx,
                        free,
                        i
                    );
                } else {
                    // Variable length data
                    uint256 argLen = state[idx & IDX_VALUE_MASK].length;
                    // Put a pointer in the current slot and write the data to first free slot
                    assembly {
                        mstore(count, free)
                    }
                    memcpy(
                        state[idx & IDX_VALUE_MASK],
                        0,
                        ret,
                        free + 4,
                        argLen
                    );
                    unchecked {
                        free += argLen;
                    }
                }
            } else {
                // Fixed length data (length previously checked to be 32 bytes)
                bytes memory stateVar = state[idx & IDX_VALUE_MASK];
                // Write the data to current slot
                assembly {
                    mstore(count, mload(add(stateVar, 32)))
                }
            }
            unchecked {
                count += 32;
                ++i;
            }
        }
    }

    function setupStaticVariable(
        bytes[] memory state,
        uint256 count,
        uint256 idx
    ) internal pure returns (uint256 newCount) {
        require(
            state[idx & IDX_VALUE_MASK].length == 32,
            "Static state variables must be 32 bytes"
        );
        unchecked {
            newCount = count + 32;
        }
    }

    function setupDynamicVariable(
        bytes[] memory state,
        uint256 count,
        uint256 idx
    ) internal pure returns (uint256 newCount) {
        bytes memory arg = state[idx & IDX_VALUE_MASK];
        // Validate the length of the data in state is a multiple of 32
        uint256 argLen = arg.length;
        require(
            argLen != 0 && argLen % 32 == 0,
            "Dynamic state variables must be a multiple of 32 bytes"
        );
        // Add the length of the value, rounded up to the next word boundary, plus space for pointer
        unchecked {
            newCount = count + argLen + 32;
        }
    }

    function setupDynamicType(
        bytes[] memory state,
        bytes32 indices,
        uint256[] memory dynamicLengths,
        uint256 idx,
        uint256 offsetIdx,
        uint256 count,
        uint256 index
    ) internal view returns (
        uint256[] memory newDynamicLengths,
        uint256 newOffsetIdx,
        uint256 newCount,
        uint256 newIndex
    ) {
        if (idx == IDX_ARRAY_START) {
            (newDynamicLengths, newOffsetIdx, newCount, newIndex) = setupDynamicArray(
                state,
                indices,
                dynamicLengths,
                offsetIdx,
                count,
                index
            );
        } else if (idx == IDX_TUPLE_START) {
            (newDynamicLengths, newOffsetIdx, newCount, newIndex) = setupDynamicTuple(
                state,
                indices,
                dynamicLengths,
                offsetIdx,
                count,
                index
            );
        } else {
            newDynamicLengths = dynamicLengths;
            newOffsetIdx = offsetIdx;
            newIndex = index;
            newCount = setupDynamicVariable(state, count, idx);
        }
    }

    function setupDynamicArray(
        bytes[] memory state,
        bytes32 indices,
        uint256[] memory dynamicLengths,
        uint256 offsetIdx,
        uint256 count,
        uint256 index
    ) internal view returns (
        uint256[] memory newDynamicLengths,
        uint256 newOffsetIdx,
        uint256 newCount,
        uint256 newIndex
    ) {
        // Current idx is IDX_ARRAY_START, next idx will contain the array length
        unchecked {
            newIndex = index + 1;
            newCount = count + 32;
        }
        uint256 idx = uint8(indices[newIndex]);
        require(
            state[idx & IDX_VALUE_MASK].length == 32,
            "Array length must be 32 bytes"
        );
        (newDynamicLengths, newOffsetIdx, newCount, newIndex) = setupDynamicTuple(
            state,
            indices,
            dynamicLengths,
            offsetIdx,
            newCount,
            newIndex
        );
    }

    function setupDynamicTuple(
        bytes[] memory state,
        bytes32 indices,
        uint256[] memory dynamicLengths,
        uint256 offsetIdx,
        uint256 count,
        uint256 index
    ) internal view returns (
        uint256[] memory newDynamicLengths,
        uint256 newOffsetIdx,
        uint256 newCount,
        uint256 newIndex
    ) {
        uint256 idx;
        uint256 offset;
        newDynamicLengths = dynamicLengths;
        // Progress to first index of the data and progress the next offset idx
        unchecked {
            newIndex = index + 1;
            newOffsetIdx = offsetIdx + 1;
            newCount = count + 32;
        }
        while (newIndex < 32) {
            idx = uint8(indices[newIndex]);
            if (idx & IDX_VARIABLE_LENGTH != 0) {
                if (idx == IDX_DYNAMIC_END) {
                    newDynamicLengths[offsetIdx] = offset;
                    // explicit return saves gas ¯\_(ツ)_/¯
                    return (newDynamicLengths, newOffsetIdx, newCount, newIndex);
                } else {
                    require(idx != IDX_USE_STATE, "Cannot use state from inside dynamic type");
                    (newDynamicLengths, newOffsetIdx, newCount, newIndex) = setupDynamicType(
                        state,
                        indices,
                        newDynamicLengths,
                        idx,
                        newOffsetIdx,
                        newCount,
                        newIndex
                    );
                }
            } else {
                newCount = setupStaticVariable(state, newCount, idx);
            }
            unchecked {
                offset += 32;
                ++newIndex;
            }
        }
        revert("Dynamic type was not properly closed");
    }

    function encodeDynamicArray(
        bytes memory ret,
        bytes[] memory state,
        bytes32 indices,
        uint256[] memory dynamicLengths,
        uint256 offsetIdx,
        uint256 currentSlot,
        uint256 index
    ) internal view returns (
        uint256 newOffsetIdx,
        uint256 newSlot,
        uint256 newIndex,
        uint256 length
    ) {
        // Progress to array length metadata
        unchecked {
            newIndex = index + 1;
            newSlot = currentSlot + 32;
        }
        // Encode array length
        uint256 idx = uint8(indices[newIndex]);
        // Array length value previously checked to be 32 bytes
        bytes memory stateVar = state[idx & IDX_VALUE_MASK];
        assembly {
            mstore(add(add(ret, 36), currentSlot), mload(add(stateVar, 32)))
        }
        (newOffsetIdx, newSlot, newIndex, length) = encodeDynamicTuple(
            ret,
            state,
            indices,
            dynamicLengths,
            offsetIdx,
            newSlot,
            newIndex
        );
        unchecked {
            length += 32; // Increase length to account for array length metadata
        }
    }

    function encodeDynamicTuple(
        bytes memory ret,
        bytes[] memory state,
        bytes32 indices,
        uint256[] memory dynamicLengths,
        uint256 offsetIdx,
        uint256 currentSlot,
        uint256 index
    ) internal view returns (
        uint256 newOffsetIdx,
        uint256 newSlot,
        uint256 newIndex,
        uint256 length
    ) {
        uint256 idx;
        uint256 argLen;
        uint256 freePointer = dynamicLengths[offsetIdx]; // The pointer to the next free slot
        unchecked {
            newSlot = currentSlot + freePointer; // Update the next slot
            newOffsetIdx = offsetIdx + 1; // Progress to next offsetIdx
            newIndex = index + 1; // Progress to first index of the data
        }
        // Shift currentSlot to correct location in memory
        assembly {
            currentSlot := add(add(ret, 36), currentSlot)
        }
        while (newIndex < 32) {
            idx = uint8(indices[newIndex]);
            if (idx & IDX_VARIABLE_LENGTH != 0) {
                if (idx == IDX_DYNAMIC_END) {
                    break;
                } else if (idx == IDX_ARRAY_START) {
                    // Start of dynamic type, put pointer in current slot
                    assembly {
                        mstore(currentSlot, freePointer)
                    }
                    (newOffsetIdx, newSlot, newIndex, argLen) = encodeDynamicArray(
                        ret,
                        state,
                        indices,
                        dynamicLengths,
                        newOffsetIdx,
                        newSlot,
                        newIndex
                    );
                    unchecked {
                        freePointer += argLen;
                        length += (argLen + 32); // data + pointer
                    }
                } else if (idx == IDX_TUPLE_START) {
                    // Start of dynamic type, put pointer in current slot
                    assembly {
                        mstore(currentSlot, freePointer)
                    }
                    (newOffsetIdx, newSlot, newIndex, argLen) = encodeDynamicTuple(
                        ret,
                        state,
                        indices,
                        dynamicLengths,
                        newOffsetIdx,
                        newSlot,
                        newIndex
                    );
                    unchecked {
                        freePointer += argLen;
                        length += (argLen + 32); // data + pointer
                    }
                } else  {
                    // Variable length data
                    argLen = state[idx & IDX_VALUE_MASK].length;
                    // Start of dynamic type, put pointer in current slot
                    assembly {
                        mstore(currentSlot, freePointer)
                    }
                    memcpy(
                        state[idx & IDX_VALUE_MASK],
                        0,
                        ret,
                        newSlot + 4,
                        argLen
                    );
                    unchecked {
                        newSlot += argLen;
                        freePointer += argLen;
                        length += (argLen + 32); // data + pointer
                    }
                }
            } else {
                // Fixed length data (length previously checked to be 32 bytes)
                bytes memory stateVar = state[idx & IDX_VALUE_MASK];
                // Write to first free slot
                assembly {
                    mstore(currentSlot, mload(add(stateVar, 32)))
                }
                unchecked {
                    length += 32;
                }
            }
            unchecked {
                currentSlot += 32;
                ++newIndex;
            }
        }
    }

    function writeOutputs(
        bytes[] memory state,
        bytes1 index,
        bytes memory output
    ) internal pure returns (bytes[] memory) {
        uint256 idx = uint8(index);
        if (idx == IDX_END_OF_ARGS) return state;

        if (idx & IDX_VARIABLE_LENGTH != 0) {
            if (idx == IDX_USE_STATE) {
                state = abi.decode(output, (bytes[]));
            } else {
                require(idx & IDX_VALUE_MASK < state.length, "Index out-of-bounds");
                // Check the first field is 0x20 (because we have only a single return value)
                uint256 argPtr;
                assembly {
                    argPtr := mload(add(output, 32))
                }
                require(
                    argPtr == 32,
                    "Only one return value permitted (variable)"
                );

                assembly {
                    // Overwrite the first word of the return data with the length - 32
                    mstore(add(output, 32), sub(mload(output), 32))
                    // Insert a pointer to the return data, starting at the second word, into state
                    mstore(
                        add(add(state, 32), mul(and(idx, IDX_VALUE_MASK), 32)),
                        add(output, 32)
                    )
                }
            }
        } else {
            require(idx & IDX_VALUE_MASK < state.length, "Index out-of-bounds");
            // Single word
            require(
                output.length == 32,
                "Only one return value permitted (static)"
            );

            state[idx & IDX_VALUE_MASK] = output;
        }

        return state;
    }

    function writeTuple(
        bytes[] memory state,
        bytes1 index,
        bytes memory output
    ) internal view {
        uint256 idx = uint8(index);
        if (idx == IDX_END_OF_ARGS) return;

        bytes memory entry = state[idx & IDX_VALUE_MASK] = new bytes(output.length + 32);
        memcpy(output, 0, entry, 32, output.length);
        assembly {
            let l := mload(output)
            mstore(add(entry, 32), l)
        }
    }

    function memcpy(
        bytes memory src,
        uint256 srcIdx,
        bytes memory dest,
        uint256 destIdx,
        uint256 len
    ) internal view {
        assembly {
            pop(
                staticcall(
                    gas(),
                    4,
                    add(add(src, 32), srcIdx),
                    len,
                    add(add(dest, 32), destIdx),
                    len
                )
            )
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155Receiver.sol";

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.16;

import "../libraries/StorageAPI.sol";

abstract contract ACL {
    using StorageAPI for bytes32;

    error NotPermitted();

    modifier isPermitted(bytes32 role) {
        bool permitted = _getPermission(role, msg.sender); // TODO: support GSN/Account abstraction
        if (!permitted) revert NotPermitted();
        _;
    }

    // @notice Gets user permission for a role
    // @param role The bytes32 value of the role
    // @param account The address of the account
    // @return The permission status
    function getPermission(bytes32 role, address account) external view returns (bool) {
        return _getPermission(role, account);
    }

    // @notice Internal function to get user permission for a role
    // @param role The bytes32 value of the role
    // @param account The address of the account
    // @return The permission status
    function _getPermission(bytes32 role, address account) internal view returns (bool) {
        bytes32 key = _getKey(role, account);
        return key.getBool();
    }

    // @notice Internal function to get the key for the storage slot
    // @param role The bytes32 value of the role
    // @param account The address of the account
    // @return The bytes32 storage slot
    function _getKey(bytes32 role, address account) internal pure returns (bytes32) {
        return keccak256(abi.encode(role, account));
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.16;

abstract contract Roles {
    // Using same slot generation technique as eip-1967 -- https://eips.ethereum.org/EIPS/eip-1967
    bytes32 public constant OWNER_ROLE = bytes32(uint256(keccak256("enso.access.roles.owner")) - 1);
    bytes32 public constant EXECUTOR_ROLE = bytes32(uint256(keccak256("enso.access.roles.executor")) - 1);
    bytes32 public constant MODULE_ROLE = bytes32(uint256(keccak256("enso.access.roles.module")) - 1);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155Receiver.sol";
import "../../../utils/introspection/ERC165.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.16;

library StorageAPI {
    function setBytes(bytes32 key, bytes memory data) internal {
        bytes32 slot = keccak256(abi.encodePacked(key));
        assembly {
            let length := mload(data)
            switch gt(length, 0x1F)
            case 0x00 {
                sstore(key, or(mload(add(data, 0x20)), mul(length, 2)))
            }
            case 0x01 {
                sstore(key, add(mul(length, 2), 1))
                for {
                    let i := 0
                } lt(mul(i, 0x20), length) {
                    i := add(i, 0x01)
                } {
                    sstore(add(slot, i), mload(add(data, mul(add(i, 1), 0x20))))
                }
            }
        }
    }

    function setBytes32(bytes32 key, bytes32 val) internal {
        assembly {
            sstore(key, val)
        }
    }

    function setAddress(bytes32 key, address a) internal {
        assembly {
            sstore(key, a)
        }
    }

    function setUint256(bytes32 key, uint256 val) internal {
        assembly {
            sstore(key, val)
        }
    }

    function setInt256(bytes32 key, int256 val) internal {
        assembly {
            sstore(key, val)
        }
    }

    function setBool(bytes32 key, bool val) internal {
        assembly {
            sstore(key, val)
        }
    }

    function getBytes(bytes32 key) internal view returns (bytes memory data) {
        bytes32 slot = keccak256(abi.encodePacked(key));
        assembly {
            let length := sload(key)
            switch and(length, 0x01)
            case 0x00 {
                let decodedLength := div(and(length, 0xFF), 2)
                mstore(data, decodedLength)
                mstore(add(data, 0x20), and(length, not(0xFF)))
                mstore(0x40, add(data, 0x40))
            }
            case 0x01 {
                let decodedLength := div(length, 2)
                let i := 0
                mstore(data, decodedLength)
                for {

                } lt(mul(i, 0x20), decodedLength) {
                    i := add(i, 0x01)
                } {
                    mstore(add(add(data, 0x20), mul(i, 0x20)), sload(add(slot, i)))
                }
                mstore(0x40, add(data, add(0x20, mul(i, 0x20))))
            }
        }
    }

    function getBytes32(bytes32 key) internal view returns (bytes32 val) {
        assembly {
            val := sload(key)
        }
    }

    function getAddress(bytes32 key) internal view returns (address a) {
        assembly {
            a := sload(key)
        }
    }

    function getUint256(bytes32 key) internal view returns (uint256 val) {
        assembly {
            val := sload(key)
        }
    }

    function getInt256(bytes32 key) internal view returns (int256 val) {
        assembly {
            val := sload(key)
        }
    }

    function getBool(bytes32 key) internal view returns (bool val) {
        assembly {
            val := sload(key)
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}