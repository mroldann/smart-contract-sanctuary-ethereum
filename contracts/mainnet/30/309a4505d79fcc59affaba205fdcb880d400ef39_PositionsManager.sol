// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

/// @title Delegate Call Library.
/// @author Morpho Labs.
/// @custom:contact [email protected]
/// @dev Low-level YUL delegate call library.
library DelegateCall {
    /// ERRORS ///

    /// @notice Thrown when a low delegate call has failed without error message.
    error LowLevelDelegateCallFailed();
    bytes4 constant LowLevelDelegateCallFailedError = 0x06f7035e; // bytes4(keccak256("LowLevelDelegateCallFailed()"))

    /// INTERNAL ///

    /// @dev Performs a low-level delegate call to the `_target` contract.
    /// @dev Note: Unlike the OZ's library this function does not check if the `_target` is a contract. It is the responsibility of the caller to ensure that the `_target` is a contract.
    /// @param _target The address of the target contract.
    /// @param _data The data to pass to the function called on the target contract.
    /// @return returnData The return data from the function called on the target contract.
    function functionDelegateCall(address _target, bytes memory _data) internal returns (bytes memory returnData) {
        assembly {
            returnData := mload(0x40)

            // The bytes size is found at the bytes pointer memory address - the bytes data is found a slot further.
            if iszero(delegatecall(gas(), _target, add(_data, 0x20), mload(_data), 0, 0)) {
                // No error is returned, return the custom error.
                if iszero(returndatasize()) {
                    mstore(returnData, LowLevelDelegateCallFailedError)
                    revert(returnData, 4)
                }

                // An error is returned and can be logged.
                returndatacopy(returnData, 0, returndatasize())
                revert(returnData, returndatasize())
            }

            // Copy data size and then the returned data to memory.
            mstore(returnData, returndatasize())
            let actualDataPtr := add(returnData, 0x20)
            returndatacopy(actualDataPtr, 0, returndatasize())

            // Update the free memory pointer.
            mstore(0x40, add(actualDataPtr, returndatasize()))
        }
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../tokens/ERC20.sol";

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), from) // Append the "from" argument.
            mstore(add(freeMemoryPointer, 36), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.13;

import "./MorphoUtils.sol";

/// @title MatchingEngine.
/// @author Morpho Labs.
/// @custom:contact [email protected]
/// @notice Smart contract managing the matching engine.
abstract contract MatchingEngine is MorphoUtils {
    using DoubleLinkedList for DoubleLinkedList.List;
    using CompoundMath for uint256;

    /// STRUCTS ///

    // Struct to avoid stack too deep.
    struct UnmatchVars {
        uint256 p2pIndex;
        uint256 toUnmatch;
        uint256 poolIndex;
        uint256 inUnderlying;
        uint256 gasLeftAtTheBeginning;
    }

    // Struct to avoid stack too deep.
    struct MatchVars {
        uint256 p2pIndex;
        uint256 toMatch;
        uint256 poolIndex;
        uint256 inUnderlying;
        uint256 gasLeftAtTheBeginning;
    }

    /// @notice Emitted when the position of a supplier is updated.
    /// @param _user The address of the supplier.
    /// @param _poolToken The address of the market.
    /// @param _balanceOnPool The supply balance on pool after update.
    /// @param _balanceInP2P The supply balance in peer-to-peer after update.
    event SupplierPositionUpdated(
        address indexed _user,
        address indexed _poolToken,
        uint256 _balanceOnPool,
        uint256 _balanceInP2P
    );

    /// @notice Emitted when the position of a borrower is updated.
    /// @param _user The address of the borrower.
    /// @param _poolToken The address of the market.
    /// @param _balanceOnPool The borrow balance on pool after update.
    /// @param _balanceInP2P The borrow balance in peer-to-peer after update.
    event BorrowerPositionUpdated(
        address indexed _user,
        address indexed _poolToken,
        uint256 _balanceOnPool,
        uint256 _balanceInP2P
    );

    /// INTERNAL ///

    /// @notice Matches suppliers' liquidity waiting on Compound up to the given `_amount` and moves it to peer-to-peer.
    /// @dev Note: This function expects Compound's exchange rate and peer-to-peer indexes to have been updated.
    /// @param _poolToken The address of the market from which to match suppliers.
    /// @param _amount The token amount to search for (in underlying).
    /// @param _maxGasForMatching The maximum amount of gas to consume within a matching engine loop.
    /// @return matched The amount of liquidity matched (in underlying).
    /// @return gasConsumedInMatching The amount of gas consumed within the matching loop.
    function _matchSuppliers(
        address _poolToken,
        uint256 _amount,
        uint256 _maxGasForMatching
    ) internal returns (uint256 matched, uint256 gasConsumedInMatching) {
        if (_maxGasForMatching == 0) return (0, 0);

        MatchVars memory vars;
        vars.poolIndex = ICToken(_poolToken).exchangeRateStored(); // Exchange rate has already been updated.
        vars.p2pIndex = p2pSupplyIndex[_poolToken];
        address firstPoolSupplier;
        vars.gasLeftAtTheBeginning = gasleft();

        while (
            matched < _amount &&
            (firstPoolSupplier = suppliersOnPool[_poolToken].getHead()) != address(0) &&
            vars.gasLeftAtTheBeginning - gasleft() < _maxGasForMatching
        ) {
            Types.SupplyBalance storage firstPoolSupplierBalance = supplyBalanceInOf[_poolToken][
                firstPoolSupplier
            ];
            vars.inUnderlying = firstPoolSupplierBalance.onPool.mul(vars.poolIndex);

            uint256 poolSupplyBalance;
            uint256 p2pSupplyBalance;
            uint256 maxToMatch = _amount - matched;

            if (vars.inUnderlying <= maxToMatch) {
                // poolSupplyBalance is 0.
                p2pSupplyBalance =
                    firstPoolSupplierBalance.inP2P +
                    vars.inUnderlying.div(vars.p2pIndex);
                matched += vars.inUnderlying;
            } else {
                poolSupplyBalance =
                    firstPoolSupplierBalance.onPool -
                    maxToMatch.div(vars.poolIndex);
                p2pSupplyBalance = firstPoolSupplierBalance.inP2P + maxToMatch.div(vars.p2pIndex);
                matched = _amount;
            }

            firstPoolSupplierBalance.onPool = poolSupplyBalance;
            firstPoolSupplierBalance.inP2P = p2pSupplyBalance;
            _updateSupplierInDS(_poolToken, firstPoolSupplier);

            emit SupplierPositionUpdated(
                firstPoolSupplier,
                _poolToken,
                poolSupplyBalance,
                p2pSupplyBalance
            );
        }

        gasConsumedInMatching = vars.gasLeftAtTheBeginning - gasleft();
    }

    /// @notice Unmatches suppliers' liquidity in peer-to-peer up to the given `_amount` and moves it to Compound.
    /// @dev Note: This function expects Compound's exchange rate and peer-to-peer indexes to have been updated.
    /// @param _poolToken The address of the market from which to unmatch suppliers.
    /// @param _amount The amount to search for (in underlying).
    /// @param _maxGasForMatching The maximum amount of gas to consume within a matching engine loop.
    /// @return The amount unmatched (in underlying).
    function _unmatchSuppliers(
        address _poolToken,
        uint256 _amount,
        uint256 _maxGasForMatching
    ) internal returns (uint256) {
        if (_maxGasForMatching == 0) return 0;

        UnmatchVars memory vars;
        vars.poolIndex = ICToken(_poolToken).exchangeRateStored(); // Exchange rate has already been updated.
        vars.p2pIndex = p2pSupplyIndex[_poolToken];
        address firstP2PSupplier;
        uint256 remainingToUnmatch = _amount;
        vars.gasLeftAtTheBeginning = gasleft();

        while (
            remainingToUnmatch > 0 &&
            (firstP2PSupplier = suppliersInP2P[_poolToken].getHead()) != address(0) &&
            vars.gasLeftAtTheBeginning - gasleft() < _maxGasForMatching
        ) {
            Types.SupplyBalance storage firstP2PSupplierBalance = supplyBalanceInOf[_poolToken][
                firstP2PSupplier
            ];
            vars.inUnderlying = firstP2PSupplierBalance.inP2P.mul(vars.p2pIndex);

            uint256 poolSupplyBalance;
            uint256 p2pSupplyBalance;

            if (vars.inUnderlying <= remainingToUnmatch) {
                // p2pSupplyBalance is 0.
                poolSupplyBalance =
                    firstP2PSupplierBalance.onPool +
                    vars.inUnderlying.div(vars.poolIndex);
                remainingToUnmatch -= vars.inUnderlying;
            } else {
                poolSupplyBalance =
                    firstP2PSupplierBalance.onPool +
                    remainingToUnmatch.div(vars.poolIndex);
                p2pSupplyBalance =
                    firstP2PSupplierBalance.inP2P -
                    remainingToUnmatch.div(vars.p2pIndex);
                remainingToUnmatch = 0;
            }

            firstP2PSupplierBalance.onPool = poolSupplyBalance;
            firstP2PSupplierBalance.inP2P = p2pSupplyBalance;
            _updateSupplierInDS(_poolToken, firstP2PSupplier);

            emit SupplierPositionUpdated(
                firstP2PSupplier,
                _poolToken,
                poolSupplyBalance,
                p2pSupplyBalance
            );
        }

        return _amount - remainingToUnmatch;
    }

    /// @notice Matches borrowers' liquidity waiting on Compound up to the given `_amount` and moves it to peer-to-peer.
    /// @dev Note: This function expects stored indexes to have been updated
    /// @param _poolToken The address of the market from which to match borrowers.
    /// @param _amount The amount to search for (in underlying).
    /// @param _maxGasForMatching The maximum amount of gas to consume within a matching engine loop.
    /// @return matched The amount of liquidity matched (in underlying).
    /// @return gasConsumedInMatching The amount of gas consumed within the matching loop.
    function _matchBorrowers(
        address _poolToken,
        uint256 _amount,
        uint256 _maxGasForMatching
    ) internal returns (uint256 matched, uint256 gasConsumedInMatching) {
        if (_maxGasForMatching == 0) return (0, 0);

        MatchVars memory vars;
        vars.poolIndex = lastPoolIndexes[_poolToken].lastBorrowPoolIndex;
        vars.p2pIndex = p2pBorrowIndex[_poolToken];
        address firstPoolBorrower;
        vars.gasLeftAtTheBeginning = gasleft();

        while (
            matched < _amount &&
            (firstPoolBorrower = borrowersOnPool[_poolToken].getHead()) != address(0) &&
            vars.gasLeftAtTheBeginning - gasleft() < _maxGasForMatching
        ) {
            Types.BorrowBalance storage firstPoolBorrowerBalance = borrowBalanceInOf[_poolToken][
                firstPoolBorrower
            ];
            vars.inUnderlying = firstPoolBorrowerBalance.onPool.mul(vars.poolIndex);

            uint256 poolBorrowBalance;
            uint256 p2pBorrowBalance;
            uint256 maxToMatch = _amount - matched;

            if (vars.inUnderlying <= maxToMatch) {
                // poolBorrowBalance is 0.
                p2pBorrowBalance =
                    firstPoolBorrowerBalance.inP2P +
                    vars.inUnderlying.div(vars.p2pIndex);
                matched += vars.inUnderlying;
            } else {
                poolBorrowBalance =
                    firstPoolBorrowerBalance.onPool -
                    maxToMatch.div(vars.poolIndex);
                p2pBorrowBalance = firstPoolBorrowerBalance.inP2P + maxToMatch.div(vars.p2pIndex);
                matched = _amount;
            }

            firstPoolBorrowerBalance.onPool = poolBorrowBalance;
            firstPoolBorrowerBalance.inP2P = p2pBorrowBalance;
            _updateBorrowerInDS(_poolToken, firstPoolBorrower);

            emit BorrowerPositionUpdated(
                firstPoolBorrower,
                _poolToken,
                poolBorrowBalance,
                p2pBorrowBalance
            );
        }

        gasConsumedInMatching = vars.gasLeftAtTheBeginning - gasleft();
    }

    /// @notice Unmatches borrowers' liquidity in peer-to-peer for the given `_amount` and moves it to Compound.
    /// @dev Note: This function expects and peer-to-peer indexes to have been updated.
    /// @param _poolToken The address of the market from which to unmatch borrowers.
    /// @param _amount The amount to unmatch (in underlying).
    /// @param _maxGasForMatching The maximum amount of gas to consume within a matching engine loop.
    /// @return The amount unmatched (in underlying).
    function _unmatchBorrowers(
        address _poolToken,
        uint256 _amount,
        uint256 _maxGasForMatching
    ) internal returns (uint256) {
        if (_maxGasForMatching == 0) return 0;

        UnmatchVars memory vars;
        vars.poolIndex = lastPoolIndexes[_poolToken].lastBorrowPoolIndex;
        vars.p2pIndex = p2pBorrowIndex[_poolToken];
        address firstP2PBorrower;
        uint256 remainingToUnmatch = _amount;
        vars.gasLeftAtTheBeginning = gasleft();

        while (
            remainingToUnmatch > 0 &&
            (firstP2PBorrower = borrowersInP2P[_poolToken].getHead()) != address(0) &&
            vars.gasLeftAtTheBeginning - gasleft() < _maxGasForMatching
        ) {
            Types.BorrowBalance storage firstP2PBorrowerBalance = borrowBalanceInOf[_poolToken][
                firstP2PBorrower
            ];
            vars.inUnderlying = firstP2PBorrowerBalance.inP2P.mul(vars.p2pIndex);

            uint256 poolBorrowBalance;
            uint256 p2pBorrowBalance;

            if (vars.inUnderlying <= remainingToUnmatch) {
                // p2pBorrowBalance is 0.
                poolBorrowBalance =
                    firstP2PBorrowerBalance.onPool +
                    vars.inUnderlying.div(vars.poolIndex);
                remainingToUnmatch -= vars.inUnderlying;
            } else {
                poolBorrowBalance =
                    firstP2PBorrowerBalance.onPool +
                    remainingToUnmatch.div(vars.poolIndex);
                p2pBorrowBalance =
                    firstP2PBorrowerBalance.inP2P -
                    remainingToUnmatch.div(vars.p2pIndex);
                remainingToUnmatch = 0;
            }

            firstP2PBorrowerBalance.onPool = poolBorrowBalance;
            firstP2PBorrowerBalance.inP2P = p2pBorrowBalance;
            _updateBorrowerInDS(_poolToken, firstP2PBorrower);

            emit BorrowerPositionUpdated(
                firstP2PBorrower,
                _poolToken,
                poolBorrowBalance,
                p2pBorrowBalance
            );
        }

        return _amount - remainingToUnmatch;
    }

    /// @notice Updates the given `_user`'s position in the supplier data structures.
    /// @param _poolToken The address of the market on which to update the suppliers data structure.
    /// @param _user The address of the user.
    function _updateSupplierInDS(address _poolToken, address _user) internal {
        Types.SupplyBalance storage supplierSupplyBalance = supplyBalanceInOf[_poolToken][_user];
        uint256 onPool = supplierSupplyBalance.onPool;
        uint256 inP2P = supplierSupplyBalance.inP2P;
        DoubleLinkedList.List storage marketSuppliersOnPool = suppliersOnPool[_poolToken];
        DoubleLinkedList.List storage marketSuppliersInP2P = suppliersInP2P[_poolToken];
        uint256 formerValueOnPool = marketSuppliersOnPool.getValueOf(_user);
        uint256 formerValueInP2P = marketSuppliersInP2P.getValueOf(_user);

        // Round pool balance to 0 if below threshold.
        if (onPool <= dustThreshold) {
            supplierSupplyBalance.onPool = 0;
            onPool = 0;
        }
        if (formerValueOnPool != onPool) {
            if (formerValueOnPool > 0) marketSuppliersOnPool.remove(_user);
            if (onPool > 0) marketSuppliersOnPool.insertSorted(_user, onPool, maxSortedUsers);
        }

        // Round peer-to-peer balance to 0 if below threshold.
        if (inP2P <= dustThreshold) {
            supplierSupplyBalance.inP2P = 0;
            inP2P = 0;
        }
        if (formerValueInP2P != inP2P) {
            if (formerValueInP2P > 0) marketSuppliersInP2P.remove(_user);
            if (inP2P > 0) marketSuppliersInP2P.insertSorted(_user, inP2P, maxSortedUsers);
        }

        if (address(rewardsManager) != address(0))
            rewardsManager.accrueUserSupplyUnclaimedRewards(_user, _poolToken, formerValueOnPool);
    }

    /// @notice Updates the given `_user`'s position in the borrower data structures.
    /// @param _poolToken The address of the market on which to update the borrowers data structure.
    /// @param _user The address of the user.
    function _updateBorrowerInDS(address _poolToken, address _user) internal {
        Types.BorrowBalance storage borrowerBorrowBalance = borrowBalanceInOf[_poolToken][_user];
        uint256 onPool = borrowerBorrowBalance.onPool;
        uint256 inP2P = borrowerBorrowBalance.inP2P;
        DoubleLinkedList.List storage marketBorrowersOnPool = borrowersOnPool[_poolToken];
        DoubleLinkedList.List storage marketBorrowersInP2P = borrowersInP2P[_poolToken];
        uint256 formerValueOnPool = marketBorrowersOnPool.getValueOf(_user);
        uint256 formerValueInP2P = marketBorrowersInP2P.getValueOf(_user);

        // Round pool balance to 0 if below threshold.
        if (onPool <= dustThreshold) {
            borrowerBorrowBalance.onPool = 0;
            onPool = 0;
        }
        if (formerValueOnPool != onPool) {
            if (formerValueOnPool > 0) marketBorrowersOnPool.remove(_user);
            if (onPool > 0) marketBorrowersOnPool.insertSorted(_user, onPool, maxSortedUsers);
        }

        // Round peer-to-peer balance to 0 if below threshold.
        if (inP2P <= dustThreshold) {
            borrowerBorrowBalance.inP2P = 0;
            inP2P = 0;
        }
        if (formerValueInP2P != inP2P) {
            if (formerValueInP2P > 0) marketBorrowersInP2P.remove(_user);
            if (inP2P > 0) marketBorrowersInP2P.insertSorted(_user, inP2P, maxSortedUsers);
        }

        if (address(rewardsManager) != address(0))
            rewardsManager.accrueUserBorrowUnclaimedRewards(_user, _poolToken, formerValueOnPool);
    }
}

// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.13;

import "./interfaces/compound/ICompound.sol";
import "./interfaces/IPositionsManager.sol";
import "./interfaces/IIncentivesVault.sol";
import "./interfaces/IRewardsManager.sol";
import "./interfaces/IInterestRatesManager.sol";

import "./libraries/DoubleLinkedList.sol";
import "./libraries/Types.sol";

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/// @title MorphoStorage.
/// @author Morpho Labs.
/// @custom:contact [email protected]
/// @notice All storage variables used in Morpho contracts.
abstract contract MorphoStorage is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    /// GLOBAL STORAGE ///

    uint8 public constant CTOKEN_DECIMALS = 8; // The number of decimals for cToken.
    uint16 public constant MAX_BASIS_POINTS = 10_000; // 100% in basis points.
    uint256 public constant WAD = 1e18;

    uint256 public maxSortedUsers; // The max number of users to sort in the data structure.
    uint256 public dustThreshold; // The minimum amount to keep in the data structure.
    Types.MaxGasForMatching public defaultMaxGasForMatching; // The default max gas to consume within loops in matching engine functions.

    /// POSITIONS STORAGE ///

    mapping(address => DoubleLinkedList.List) internal suppliersInP2P; // For a given market, the suppliers in peer-to-peer.
    mapping(address => DoubleLinkedList.List) internal suppliersOnPool; // For a given market, the suppliers on Compound.
    mapping(address => DoubleLinkedList.List) internal borrowersInP2P; // For a given market, the borrowers in peer-to-peer.
    mapping(address => DoubleLinkedList.List) internal borrowersOnPool; // For a given market, the borrowers on Compound.
    mapping(address => mapping(address => Types.SupplyBalance)) public supplyBalanceInOf; // For a given market, the supply balance of a user. cToken -> user -> balances.
    mapping(address => mapping(address => Types.BorrowBalance)) public borrowBalanceInOf; // For a given market, the borrow balance of a user. cToken -> user -> balances.
    mapping(address => mapping(address => bool)) public userMembership; // Whether the user is in the market or not. cToken -> user -> bool.
    mapping(address => address[]) public enteredMarkets; // The markets entered by a user. user -> cTokens.

    /// MARKETS STORAGE ///

    address[] internal marketsCreated; // Keeps track of the created markets.
    mapping(address => bool) public p2pDisabled; // Whether the peer-to-peer market is open or not.
    mapping(address => uint256) public p2pSupplyIndex; // Current index from supply peer-to-peer unit to underlying (in wad).
    mapping(address => uint256) public p2pBorrowIndex; // Current index from borrow peer-to-peer unit to underlying (in wad).
    mapping(address => Types.LastPoolIndexes) public lastPoolIndexes; // Last pool index stored.
    mapping(address => Types.MarketParameters) public marketParameters; // Market parameters.
    mapping(address => Types.MarketStatus) public marketStatus; // Market status.
    mapping(address => Types.Delta) public deltas; // Delta parameters for each market.

    /// CONTRACTS AND ADDRESSES ///

    IPositionsManager public positionsManager;
    IIncentivesVault public incentivesVault;
    IRewardsManager public rewardsManager;
    IInterestRatesManager public interestRatesManager;
    IComptroller public comptroller;
    address public treasuryVault;
    address public cEth;
    address public wEth;

    /// APPENDIX STORAGE ///

    mapping(address => uint256) public lastBorrowBlock; // Block number of the last borrow of the user.
    bool public isClaimRewardsPaused; // Whether it's possible to claim rewards or not.
    mapping(address => Types.MarketPauseStatus) public marketPauseStatus; // The pause and deprecated statuses for the given market.

    /// CONSTRUCTOR ///

    /// @notice Constructs the contract.
    /// @dev The contract is automatically marked as initialized when deployed so that nobody can highjack the implementation contract.
    constructor() initializer {}
}

// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.13;

import "@rari-capital/solmate/src/utils/SafeTransferLib.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./libraries/CompoundMath.sol";
import "@morpho-dao/morpho-utils/DelegateCall.sol";

import "./MorphoStorage.sol";

/// @title MorphoUtils.
/// @author Morpho Labs.
/// @custom:contact [email protected]
/// @notice Modifiers, getters and other util functions for Morpho.
abstract contract MorphoUtils is MorphoStorage {
    using DoubleLinkedList for DoubleLinkedList.List;
    using CompoundMath for uint256;
    using DelegateCall for address;

    /// ERRORS ///

    /// @notice Thrown when the Compound's oracle failed.
    error CompoundOracleFailed();

    /// @notice Thrown when the market is not created yet.
    error MarketNotCreated();

    /// MODIFIERS ///

    /// @notice Prevents to update a market not created yet.
    /// @param _poolToken The address of the market to check.
    modifier isMarketCreated(address _poolToken) {
        if (!marketStatus[_poolToken].isCreated) revert MarketNotCreated();
        _;
    }

    /// EXTERNAL ///

    /// @notice Returns all markets entered by a given user.
    /// @param _user The address of the user.
    /// @return enteredMarkets_ The list of markets entered by this user.
    function getEnteredMarkets(address _user)
        external
        view
        returns (address[] memory enteredMarkets_)
    {
        return enteredMarkets[_user];
    }

    /// @notice Returns all created markets.
    /// @return marketsCreated_ The list of market addresses.
    function getAllMarkets() external view returns (address[] memory marketsCreated_) {
        return marketsCreated;
    }

    /// @notice Gets the head of the data structure on a specific market (for UI).
    /// @param _poolToken The address of the market from which to get the head.
    /// @param _positionType The type of user from which to get the head.
    /// @return head The head in the data structure.
    function getHead(address _poolToken, Types.PositionType _positionType)
        external
        view
        returns (address head)
    {
        if (_positionType == Types.PositionType.SUPPLIERS_IN_P2P)
            head = suppliersInP2P[_poolToken].getHead();
        else if (_positionType == Types.PositionType.SUPPLIERS_ON_POOL)
            head = suppliersOnPool[_poolToken].getHead();
        else if (_positionType == Types.PositionType.BORROWERS_IN_P2P)
            head = borrowersInP2P[_poolToken].getHead();
        else if (_positionType == Types.PositionType.BORROWERS_ON_POOL)
            head = borrowersOnPool[_poolToken].getHead();
    }

    /// @notice Gets the next user after `_user` in the data structure on a specific market (for UI).
    /// @dev Beware that this function does not give the account with the highest liquidity.
    /// @param _poolToken The address of the market from which to get the user.
    /// @param _positionType The type of user from which to get the next user.
    /// @param _user The address of the user from which to get the next user.
    /// @return next The next user in the data structure.
    function getNext(
        address _poolToken,
        Types.PositionType _positionType,
        address _user
    ) external view returns (address next) {
        if (_positionType == Types.PositionType.SUPPLIERS_IN_P2P)
            next = suppliersInP2P[_poolToken].getNext(_user);
        else if (_positionType == Types.PositionType.SUPPLIERS_ON_POOL)
            next = suppliersOnPool[_poolToken].getNext(_user);
        else if (_positionType == Types.PositionType.BORROWERS_IN_P2P)
            next = borrowersInP2P[_poolToken].getNext(_user);
        else if (_positionType == Types.PositionType.BORROWERS_ON_POOL)
            next = borrowersOnPool[_poolToken].getNext(_user);
    }

    /// @notice Updates the peer-to-peer indexes.
    /// @dev Note: This function updates the exchange rate on Compound. As a consequence only a call to exchangeRatesStored() is necessary to get the most up to date exchange rate.
    /// @param _poolToken The address of the market to update.
    function updateP2PIndexes(address _poolToken) external isMarketCreated(_poolToken) {
        _updateP2PIndexes(_poolToken);
    }

    /// INTERNAL ///

    /// @dev Updates the peer-to-peer indexes.
    /// @dev Note: This function updates the exchange rate on Compound. As a consequence only a call to exchangeRatesStored() is necessary to get the most up to date exchange rate.
    /// @param _poolToken The address of the market to update.
    function _updateP2PIndexes(address _poolToken) internal {
        address(interestRatesManager).functionDelegateCall(
            abi.encodeWithSelector(interestRatesManager.updateP2PIndexes.selector, _poolToken)
        );
    }

    /// @dev Checks whether the user has enough collateral to maintain such a borrow position.
    /// @param _user The user to check.
    /// @param _poolToken The market to hypothetically withdraw/borrow in.
    /// @param _withdrawnAmount The amount of tokens to hypothetically withdraw (in underlying).
    /// @param _borrowedAmount The amount of tokens to hypothetically borrow (in underlying).
    function _isLiquidatable(
        address _user,
        address _poolToken,
        uint256 _withdrawnAmount,
        uint256 _borrowedAmount
    ) internal view returns (bool) {
        ICompoundOracle oracle = ICompoundOracle(comptroller.oracle());
        uint256 numberOfEnteredMarkets = enteredMarkets[_user].length;

        Types.AssetLiquidityData memory assetData;
        uint256 maxDebtValue;
        uint256 debtValue;
        uint256 i;

        while (i < numberOfEnteredMarkets) {
            address poolTokenEntered = enteredMarkets[_user][i];

            assetData = _getUserLiquidityDataForAsset(_user, poolTokenEntered, oracle);
            maxDebtValue += assetData.maxDebtValue;
            debtValue += assetData.debtValue;

            if (_poolToken == poolTokenEntered) {
                if (_borrowedAmount > 0)
                    debtValue += _borrowedAmount.mul(assetData.underlyingPrice);

                if (_withdrawnAmount > 0)
                    maxDebtValue -= _withdrawnAmount.mul(assetData.underlyingPrice).mul(
                        assetData.collateralFactor
                    );
            }

            unchecked {
                ++i;
            }
        }

        return debtValue > maxDebtValue;
    }

    /// @notice Returns the data related to `_poolToken` for the `_user`.
    /// @dev Note: Must be called after calling `_updateP2PIndexes()` to have the most up-to-date indexes.
    /// @param _user The user to determine data for.
    /// @param _poolToken The address of the market.
    /// @param _oracle The oracle used.
    /// @return assetData The data related to this asset.
    function _getUserLiquidityDataForAsset(
        address _user,
        address _poolToken,
        ICompoundOracle _oracle
    ) internal view returns (Types.AssetLiquidityData memory assetData) {
        assetData.underlyingPrice = _oracle.getUnderlyingPrice(_poolToken);
        if (assetData.underlyingPrice == 0) revert CompoundOracleFailed();
        (, assetData.collateralFactor, ) = comptroller.markets(_poolToken);

        assetData.collateralValue = _getUserSupplyBalanceInOf(_poolToken, _user).mul(
            assetData.underlyingPrice
        );
        assetData.debtValue = _getUserBorrowBalanceInOf(_poolToken, _user).mul(
            assetData.underlyingPrice
        );
        assetData.maxDebtValue = assetData.collateralValue.mul(assetData.collateralFactor);
    }

    /// @dev Returns the supply balance of `_user` in the `_poolToken` market.
    /// @dev Note: Computes the result with the stored indexes, which are not always the most up to date ones.
    /// @param _user The address of the user.
    /// @param _poolToken The market where to get the supply amount.
    /// @return The supply balance of the user (in underlying).
    function _getUserSupplyBalanceInOf(address _poolToken, address _user)
        internal
        view
        returns (uint256)
    {
        Types.SupplyBalance memory userSupplyBalance = supplyBalanceInOf[_poolToken][_user];
        return
            userSupplyBalance.inP2P.mul(p2pSupplyIndex[_poolToken]) +
            userSupplyBalance.onPool.mul(ICToken(_poolToken).exchangeRateStored());
    }

    /// @dev Returns the borrow balance of `_user` in the `_poolToken` market.
    /// @dev Note: Computes the result with the stored indexes, which are not always the most up to date ones.
    /// @param _user The address of the user.
    /// @param _poolToken The market where to get the borrow amount.
    /// @return The borrow balance of the user (in underlying).
    function _getUserBorrowBalanceInOf(address _poolToken, address _user)
        internal
        view
        returns (uint256)
    {
        Types.BorrowBalance memory userBorrowBalance = borrowBalanceInOf[_poolToken][_user];
        return
            userBorrowBalance.inP2P.mul(p2pBorrowIndex[_poolToken]) +
            userBorrowBalance.onPool.mul(ICToken(_poolToken).borrowIndex());
    }

    /// @dev Returns the underlying ERC20 token related to the pool token.
    /// @param _poolToken The address of the pool token.
    /// @return The underlying ERC20 token.
    function _getUnderlying(address _poolToken) internal view returns (ERC20) {
        if (_poolToken == cEth)
            // cETH has no underlying() function.
            return ERC20(wEth);
        else return ERC20(ICToken(_poolToken).underlying());
    }
}

// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.13;

import "./interfaces/IPositionsManager.sol";
import "./interfaces/IWETH.sol";

import "./MatchingEngine.sol";

/// @title PositionsManager.
/// @author Morpho Labs.
/// @custom:contact [email protected]
/// @notice Main Logic of Morpho Protocol, implementation of the 5 main functionalities: supply, borrow, withdraw, repay and liquidate.
contract PositionsManager is IPositionsManager, MatchingEngine {
    using DoubleLinkedList for DoubleLinkedList.List;
    using SafeTransferLib for ERC20;
    using CompoundMath for uint256;

    /// EVENTS ///

    /// @notice Emitted when a supply happens.
    /// @param _supplier The address of the account sending funds.
    /// @param _onBehalf The address of the account whose positions will be updated.
    /// @param _poolToken The address of the market where assets are supplied into.
    /// @param _amount The amount of assets supplied (in underlying).
    /// @param _balanceOnPool The supply balance on pool after update.
    /// @param _balanceInP2P The supply balance in peer-to-peer after update.
    event Supplied(
        address indexed _supplier,
        address indexed _onBehalf,
        address indexed _poolToken,
        uint256 _amount,
        uint256 _balanceOnPool,
        uint256 _balanceInP2P
    );

    /// @notice Emitted when a borrow happens.
    /// @param _borrower The address of the borrower.
    /// @param _poolToken The address of the market where assets are borrowed.
    /// @param _amount The amount of assets borrowed (in underlying).
    /// @param _balanceOnPool The borrow balance on pool after update.
    /// @param _balanceInP2P The borrow balance in peer-to-peer after update
    event Borrowed(
        address indexed _borrower,
        address indexed _poolToken,
        uint256 _amount,
        uint256 _balanceOnPool,
        uint256 _balanceInP2P
    );

    /// @notice Emitted when a withdrawal happens.
    /// @param _supplier The address of the supplier whose supply is withdrawn.
    /// @param _receiver The address receiving the tokens.
    /// @param _poolToken The address of the market from where assets are withdrawn.
    /// @param _amount The amount of assets withdrawn (in underlying).
    /// @param _balanceOnPool The supply balance on pool after update.
    /// @param _balanceInP2P The supply balance in peer-to-peer after update.
    event Withdrawn(
        address indexed _supplier,
        address indexed _receiver,
        address indexed _poolToken,
        uint256 _amount,
        uint256 _balanceOnPool,
        uint256 _balanceInP2P
    );

    /// @notice Emitted when a repayment happens.
    /// @param _repayer The address of the account repaying the debt.
    /// @param _onBehalf The address of the account whose debt is repaid.
    /// @param _poolToken The address of the market where assets are repaid.
    /// @param _amount The amount of assets repaid (in underlying).
    /// @param _balanceOnPool The borrow balance on pool after update.
    /// @param _balanceInP2P The borrow balance in peer-to-peer after update.
    event Repaid(
        address indexed _repayer,
        address indexed _onBehalf,
        address indexed _poolToken,
        uint256 _amount,
        uint256 _balanceOnPool,
        uint256 _balanceInP2P
    );

    /// @notice Emitted when a liquidation happens.
    /// @param _liquidator The address of the liquidator.
    /// @param _liquidated The address of the liquidated.
    /// @param _poolTokenBorrowed The address of the borrowed asset.
    /// @param _amountRepaid The amount of borrowed asset repaid (in underlying).
    /// @param _poolTokenCollateral The address of the collateral asset seized.
    /// @param _amountSeized The amount of collateral asset seized (in underlying).
    event Liquidated(
        address _liquidator,
        address indexed _liquidated,
        address indexed _poolTokenBorrowed,
        uint256 _amountRepaid,
        address indexed _poolTokenCollateral,
        uint256 _amountSeized
    );

    /// @notice Emitted when the peer-to-peer deltas are increased by the governance.
    /// @param _poolToken The address of the market on which the deltas were increased.
    /// @param _amount The amount that has been added to the deltas (in underlying).
    event P2PDeltasIncreased(address indexed _poolToken, uint256 _amount);

    /// @notice Emitted when the borrow peer-to-peer delta is updated.
    /// @param _poolToken The address of the market.
    /// @param _p2pBorrowDelta The borrow peer-to-peer delta after update.
    event P2PBorrowDeltaUpdated(address indexed _poolToken, uint256 _p2pBorrowDelta);

    /// @notice Emitted when the supply peer-to-peer delta is updated.
    /// @param _poolToken The address of the market.
    /// @param _p2pSupplyDelta The supply peer-to-peer delta after update.
    event P2PSupplyDeltaUpdated(address indexed _poolToken, uint256 _p2pSupplyDelta);

    /// @notice Emitted when the supply and borrow peer-to-peer amounts are updated.
    /// @param _poolToken The address of the market.
    /// @param _p2pSupplyAmount The supply peer-to-peer amount after update.
    /// @param _p2pBorrowAmount The borrow peer-to-peer amount after update.
    event P2PAmountsUpdated(
        address indexed _poolToken,
        uint256 _p2pSupplyAmount,
        uint256 _p2pBorrowAmount
    );

    /// ERRORS ///

    /// @notice Thrown when the amount repaid during the liquidation is above what is allowed to be repaid.
    error AmountAboveWhatAllowedToRepay();

    /// @notice Thrown when the borrow on Compound failed.
    error BorrowOnCompoundFailed();

    /// @notice Thrown when the redeem on Compound failed .
    error RedeemOnCompoundFailed();

    /// @notice Thrown when the repay on Compound failed.
    error RepayOnCompoundFailed();

    /// @notice Thrown when the mint on Compound failed.
    error MintOnCompoundFailed();

    /// @notice Thrown when user is not a member of the market.
    error UserNotMemberOfMarket();

    /// @notice Thrown when the user does not have enough remaining collateral to withdraw.
    error UnauthorisedWithdraw();

    /// @notice Thrown when the positions of the user is not liquidatable.
    error UnauthorisedLiquidate();

    /// @notice Thrown when the user does not have enough collateral for the borrow.
    error UnauthorisedBorrow();

    /// @notice Thrown when the amount desired for a withdrawal is too small.
    error WithdrawTooSmall();

    /// @notice Thrown when the address is zero.
    error AddressIsZero();

    /// @notice Thrown when the amount is equal to 0.
    error AmountIsZero();

    /// @notice Thrown when a user tries to repay its debt after borrowing in the same block.
    error SameBlockBorrowRepay();

    /// @notice Thrown when someone tries to supply but the supply is paused.
    error SupplyIsPaused();

    /// @notice Thrown when someone tries to borrow but the borrow is paused.
    error BorrowIsPaused();

    /// @notice Thrown when someone tries to withdraw but the withdraw is paused.
    error WithdrawIsPaused();

    /// @notice Thrown when someone tries to repay but the repay is paused.
    error RepayIsPaused();

    /// @notice Thrown when someone tries to liquidate but the liquidation with this asset as collateral is paused.
    error LiquidateCollateralIsPaused();

    /// @notice Thrown when someone tries to liquidate but the liquidation with this asset as debt is paused.
    error LiquidateBorrowIsPaused();

    /// STRUCTS ///

    // Struct to avoid stack too deep.
    struct SupplyVars {
        uint256 remainingToSupply;
        uint256 poolBorrowIndex;
        uint256 toRepay;
    }

    // Struct to avoid stack too deep.
    struct WithdrawVars {
        uint256 remainingGasForMatching;
        uint256 remainingToWithdraw;
        uint256 poolSupplyIndex;
        uint256 p2pSupplyIndex;
        uint256 toWithdraw;
        ERC20 underlyingToken;
    }

    // Struct to avoid stack too deep.
    struct RepayVars {
        uint256 remainingGasForMatching;
        uint256 remainingToRepay;
        uint256 maxToRepayOnPool;
        uint256 poolBorrowIndex;
        uint256 p2pSupplyIndex;
        uint256 p2pBorrowIndex;
        uint256 borrowedOnPool;
        uint256 feeToRepay;
        uint256 toRepay;
    }

    // Struct to avoid stack too deep.
    struct LiquidateVars {
        uint256 collateralPrice;
        uint256 borrowBalance;
        uint256 supplyBalance;
        uint256 borrowedPrice;
        uint256 amountToSeize;
        uint256 closeFactor;
        bool liquidationAllowed;
    }

    /// LOGIC ///

    /// @dev Implements supply logic.
    /// @param _poolToken The address of the pool token the user wants to interact with.
    /// @param _from The address of the account sending funds.
    /// @param _onBehalf The address of the account whose positions will be updated.
    /// @param _amount The amount of token (in underlying).
    /// @param _maxGasForMatching The maximum amount of gas to consume within a matching engine loop.
    function supplyLogic(
        address _poolToken,
        address _from,
        address _onBehalf,
        uint256 _amount,
        uint256 _maxGasForMatching
    ) external {
        if (_onBehalf == address(0)) revert AddressIsZero();
        if (_amount == 0) revert AmountIsZero();
        if (!marketStatus[_poolToken].isCreated) revert MarketNotCreated();
        if (marketPauseStatus[_poolToken].isSupplyPaused) revert SupplyIsPaused();

        _updateP2PIndexes(_poolToken);
        _enterMarketIfNeeded(_poolToken, _onBehalf);
        ERC20 underlyingToken = _getUnderlying(_poolToken);
        underlyingToken.safeTransferFrom(_from, address(this), _amount);

        Types.Delta storage delta = deltas[_poolToken];
        SupplyVars memory vars;
        vars.poolBorrowIndex = lastPoolIndexes[_poolToken].lastBorrowPoolIndex;
        vars.remainingToSupply = _amount;
        bool p2pDisabled = p2pDisabled[_poolToken];

        /// Peer-to-peer supply ///

        // Match the peer-to-peer borrow delta.
        if (delta.p2pBorrowDelta > 0 && !p2pDisabled) {
            uint256 deltaInUnderlying = delta.p2pBorrowDelta.mul(vars.poolBorrowIndex);
            if (deltaInUnderlying > vars.remainingToSupply) {
                vars.toRepay += vars.remainingToSupply;
                delta.p2pBorrowDelta -= vars.remainingToSupply.div(vars.poolBorrowIndex);
                vars.remainingToSupply = 0;
            } else {
                vars.toRepay += deltaInUnderlying;
                delta.p2pBorrowDelta = 0;
                vars.remainingToSupply -= deltaInUnderlying;
            }
            emit P2PBorrowDeltaUpdated(_poolToken, delta.p2pBorrowDelta);
        }

        // Promote pool borrowers.
        if (
            vars.remainingToSupply > 0 &&
            !p2pDisabled &&
            borrowersOnPool[_poolToken].getHead() != address(0)
        ) {
            (uint256 matched, ) = _matchBorrowers(
                _poolToken,
                vars.remainingToSupply,
                _maxGasForMatching
            ); // In underlying.

            if (matched > 0) {
                vars.toRepay += matched;
                vars.remainingToSupply -= matched;
                delta.p2pBorrowAmount += matched.div(p2pBorrowIndex[_poolToken]);
            }
        }

        Types.SupplyBalance storage supplierSupplyBalance = supplyBalanceInOf[_poolToken][
            _onBehalf
        ];

        if (vars.toRepay > 0) {
            uint256 toAddInP2P = vars.toRepay.div(p2pSupplyIndex[_poolToken]);

            delta.p2pSupplyAmount += toAddInP2P;
            supplierSupplyBalance.inP2P += toAddInP2P;
            _repayToPool(_poolToken, underlyingToken, vars.toRepay); // Reverts on error.

            emit P2PAmountsUpdated(_poolToken, delta.p2pSupplyAmount, delta.p2pBorrowAmount);
        }

        /// Pool supply ///

        // Supply on pool.
        if (vars.remainingToSupply > 0) {
            supplierSupplyBalance.onPool += vars.remainingToSupply.div(
                ICToken(_poolToken).exchangeRateStored() // Exchange rate has already been updated.
            ); // In scaled balance.
            _supplyToPool(_poolToken, underlyingToken, vars.remainingToSupply); // Reverts on error.
        }

        _updateSupplierInDS(_poolToken, _onBehalf);

        emit Supplied(
            _from,
            _onBehalf,
            _poolToken,
            _amount,
            supplierSupplyBalance.onPool,
            supplierSupplyBalance.inP2P
        );
    }

    /// @dev Implements borrow logic.
    /// @param _poolToken The address of the market the user wants to interact with.
    /// @param _amount The amount of token (in underlying).
    /// @param _maxGasForMatching The maximum amount of gas to consume within a matching engine loop.
    function borrowLogic(
        address _poolToken,
        uint256 _amount,
        uint256 _maxGasForMatching
    ) external {
        if (_amount == 0) revert AmountIsZero();
        if (!marketStatus[_poolToken].isCreated) revert MarketNotCreated();
        if (marketPauseStatus[_poolToken].isBorrowPaused) revert BorrowIsPaused();

        _updateP2PIndexes(_poolToken);
        _enterMarketIfNeeded(_poolToken, msg.sender);
        lastBorrowBlock[msg.sender] = block.number;

        if (_isLiquidatable(msg.sender, _poolToken, 0, _amount)) revert UnauthorisedBorrow();
        ERC20 underlyingToken = _getUnderlying(_poolToken);
        uint256 remainingToBorrow = _amount;
        uint256 toWithdraw;
        Types.Delta storage delta = deltas[_poolToken];
        uint256 poolSupplyIndex = ICToken(_poolToken).exchangeRateStored(); // Exchange rate has already been updated.
        bool p2pDisabled = p2pDisabled[_poolToken];

        /// Peer-to-peer borrow ///

        // Match the peer-to-peer supply delta.
        if (delta.p2pSupplyDelta > 0 && !p2pDisabled) {
            uint256 deltaInUnderlying = delta.p2pSupplyDelta.mul(poolSupplyIndex);
            if (deltaInUnderlying > remainingToBorrow) {
                toWithdraw += remainingToBorrow;
                delta.p2pSupplyDelta -= remainingToBorrow.div(poolSupplyIndex);
                remainingToBorrow = 0;
            } else {
                toWithdraw += deltaInUnderlying;
                delta.p2pSupplyDelta = 0;
                remainingToBorrow -= deltaInUnderlying;
            }

            emit P2PSupplyDeltaUpdated(_poolToken, delta.p2pSupplyDelta);
        }

        // Promote pool suppliers.
        if (
            remainingToBorrow > 0 &&
            !p2pDisabled &&
            suppliersOnPool[_poolToken].getHead() != address(0)
        ) {
            (uint256 matched, ) = _matchSuppliers(
                _poolToken,
                remainingToBorrow,
                _maxGasForMatching
            ); // In underlying.

            if (matched > 0) {
                toWithdraw += matched;
                remainingToBorrow -= matched;
                deltas[_poolToken].p2pSupplyAmount += matched.div(p2pSupplyIndex[_poolToken]);
            }
        }

        Types.BorrowBalance storage borrowerBorrowBalance = borrowBalanceInOf[_poolToken][
            msg.sender
        ];

        if (toWithdraw > 0) {
            uint256 toAddInP2P = toWithdraw.div(p2pBorrowIndex[_poolToken]); // In peer-to-peer unit.

            deltas[_poolToken].p2pBorrowAmount += toAddInP2P;
            borrowerBorrowBalance.inP2P += toAddInP2P;
            emit P2PAmountsUpdated(_poolToken, delta.p2pSupplyAmount, delta.p2pBorrowAmount);

            // If this value is equal to 0 the withdraw will revert on Compound.
            if (toWithdraw.div(poolSupplyIndex) > 0) _withdrawFromPool(_poolToken, toWithdraw); // Reverts on error.
        }

        /// Pool borrow ///

        // Borrow on pool.
        if (remainingToBorrow > 0) {
            borrowerBorrowBalance.onPool += remainingToBorrow.div(
                lastPoolIndexes[_poolToken].lastBorrowPoolIndex
            ); // In cdUnit.
            _borrowFromPool(_poolToken, remainingToBorrow);
        }

        _updateBorrowerInDS(_poolToken, msg.sender);
        underlyingToken.safeTransfer(msg.sender, _amount);

        emit Borrowed(
            msg.sender,
            _poolToken,
            _amount,
            borrowerBorrowBalance.onPool,
            borrowerBorrowBalance.inP2P
        );
    }

    /// @dev Implements withdraw logic with security checks.
    /// @param _poolToken The address of the market the user wants to interact with.
    /// @param _amount The amount of token (in underlying).
    /// @param _supplier The address of the supplier.
    /// @param _receiver The address of the user who will receive the tokens.
    /// @param _maxGasForMatching The maximum amount of gas to consume within a matching engine loop.
    function withdrawLogic(
        address _poolToken,
        uint256 _amount,
        address _supplier,
        address _receiver,
        uint256 _maxGasForMatching
    ) external {
        if (_amount == 0) revert AmountIsZero();
        if (_receiver == address(0)) revert AddressIsZero();
        if (!marketStatus[_poolToken].isCreated) revert MarketNotCreated();
        if (marketPauseStatus[_poolToken].isWithdrawPaused) revert WithdrawIsPaused();
        if (!userMembership[_poolToken][_supplier]) revert UserNotMemberOfMarket();

        _updateP2PIndexes(_poolToken);
        uint256 toWithdraw = Math.min(_getUserSupplyBalanceInOf(_poolToken, _supplier), _amount);

        if (_isLiquidatable(_supplier, _poolToken, toWithdraw, 0)) revert UnauthorisedWithdraw();

        _unsafeWithdrawLogic(_poolToken, toWithdraw, _supplier, _receiver, _maxGasForMatching);
    }

    /// @dev Implements repay logic with security checks.
    /// @param _poolToken The address of the market the user wants to interact with.
    /// @param _repayer The address of the account repaying the debt.
    /// @param _onBehalf The address of the account whose debt is repaid.
    /// @param _amount The amount of token (in underlying).
    /// @param _maxGasForMatching The maximum amount of gas to consume within a matching engine loop.
    function repayLogic(
        address _poolToken,
        address _repayer,
        address _onBehalf,
        uint256 _amount,
        uint256 _maxGasForMatching
    ) external {
        if (_amount == 0) revert AmountIsZero();
        if (!marketStatus[_poolToken].isCreated) revert MarketNotCreated();
        if (marketPauseStatus[_poolToken].isRepayPaused) revert RepayIsPaused();
        if (!userMembership[_poolToken][_onBehalf]) revert UserNotMemberOfMarket();

        _updateP2PIndexes(_poolToken);
        uint256 toRepay = Math.min(_getUserBorrowBalanceInOf(_poolToken, _onBehalf), _amount);

        _unsafeRepayLogic(_poolToken, _repayer, _onBehalf, toRepay, _maxGasForMatching);
    }

    /// @notice Liquidates a position.
    /// @param _poolTokenBorrowed The address of the pool token the liquidator wants to repay.
    /// @param _poolTokenCollateral The address of the collateral pool token the liquidator wants to seize.
    /// @param _borrower The address of the borrower to liquidate.
    /// @param _amount The amount of token (in underlying) to repay.
    function liquidateLogic(
        address _poolTokenBorrowed,
        address _poolTokenCollateral,
        address _borrower,
        uint256 _amount
    ) external {
        if (!marketStatus[_poolTokenCollateral].isCreated) revert MarketNotCreated();
        if (marketPauseStatus[_poolTokenCollateral].isLiquidateCollateralPaused)
            revert LiquidateCollateralIsPaused();
        if (!marketStatus[_poolTokenBorrowed].isCreated) revert MarketNotCreated();
        Types.MarketPauseStatus memory borrowPause = marketPauseStatus[_poolTokenBorrowed];
        if (borrowPause.isLiquidateBorrowPaused) revert LiquidateBorrowIsPaused();
        if (
            !userMembership[_poolTokenBorrowed][_borrower] ||
            !userMembership[_poolTokenCollateral][_borrower]
        ) revert UserNotMemberOfMarket();

        _updateP2PIndexes(_poolTokenBorrowed);
        _updateP2PIndexes(_poolTokenCollateral);

        LiquidateVars memory vars;
        (vars.liquidationAllowed, vars.closeFactor) = _liquidationAllowed(
            _borrower,
            borrowPause.isDeprecated
        );
        if (!vars.liquidationAllowed) revert UnauthorisedLiquidate();

        vars.borrowBalance = _getUserBorrowBalanceInOf(_poolTokenBorrowed, _borrower);

        if (_amount > vars.borrowBalance.mul(vars.closeFactor))
            revert AmountAboveWhatAllowedToRepay(); // Same mechanism as Compound. Liquidator cannot repay more than part of the debt (cf close factor on Compound).

        _unsafeRepayLogic(_poolTokenBorrowed, msg.sender, _borrower, _amount, 0);

        ICompoundOracle compoundOracle = ICompoundOracle(comptroller.oracle());
        vars.collateralPrice = compoundOracle.getUnderlyingPrice(_poolTokenCollateral);
        vars.borrowedPrice = compoundOracle.getUnderlyingPrice(_poolTokenBorrowed);
        if (vars.collateralPrice == 0 || vars.borrowedPrice == 0) revert CompoundOracleFailed();

        // Compute the amount of collateral tokens to seize. This is the minimum between the repaid value plus the liquidation incentive and the available supply.
        vars.amountToSeize = Math.min(
            _amount.mul(comptroller.liquidationIncentiveMantissa()).mul(vars.borrowedPrice).div(
                vars.collateralPrice
            ),
            _getUserSupplyBalanceInOf(_poolTokenCollateral, _borrower)
        );

        _unsafeWithdrawLogic(_poolTokenCollateral, vars.amountToSeize, _borrower, msg.sender, 0);

        emit Liquidated(
            msg.sender,
            _borrower,
            _poolTokenBorrowed,
            _amount,
            _poolTokenCollateral,
            vars.amountToSeize
        );
    }

    /// @notice Implements increaseP2PDeltas logic.
    /// @dev The current Morpho supply on the pool might not be enough to borrow `_amount` before resupplying it.
    /// In this case, consider calling this function multiple times.
    /// @param _poolToken The address of the market on which to increase deltas.
    /// @param _amount The maximum amount to add to the deltas (in underlying).
    function increaseP2PDeltasLogic(address _poolToken, uint256 _amount)
        external
        isMarketCreated(_poolToken)
    {
        _updateP2PIndexes(_poolToken);

        Types.Delta storage deltas = deltas[_poolToken];
        Types.LastPoolIndexes memory lastPoolIndexes = lastPoolIndexes[_poolToken];

        uint256 poolSupplyIndex = ICToken(_poolToken).exchangeRateStored();
        _amount = Math.min(
            _amount,
            Math.min(
                deltas.p2pSupplyAmount.mul(p2pSupplyIndex[_poolToken]).safeSub(
                    deltas.p2pSupplyDelta.mul(poolSupplyIndex)
                ),
                deltas.p2pBorrowAmount.mul(p2pBorrowIndex[_poolToken]).safeSub(
                    deltas.p2pBorrowDelta.mul(lastPoolIndexes.lastBorrowPoolIndex)
                )
            )
        );
        if (_amount == 0) revert AmountIsZero();

        deltas.p2pSupplyDelta += _amount.div(poolSupplyIndex);
        deltas.p2pBorrowDelta += _amount.div(lastPoolIndexes.lastBorrowPoolIndex);
        emit P2PSupplyDeltaUpdated(_poolToken, deltas.p2pSupplyDelta);
        emit P2PBorrowDeltaUpdated(_poolToken, deltas.p2pBorrowDelta);

        _borrowFromPool(_poolToken, _amount);
        _supplyToPool(_poolToken, _getUnderlying(_poolToken), _amount);

        emit P2PDeltasIncreased(_poolToken, _amount);
    }

    /// INTERNAL ///

    /// @dev Implements withdraw logic without security checks.
    /// @param _poolToken The address of the market the user wants to interact with.
    /// @param _amount The amount of token (in underlying).
    /// @param _supplier The address of the supplier.
    /// @param _receiver The address of the user who will receive the tokens.
    /// @param _maxGasForMatching The maximum amount of gas to consume within a matching engine loop.
    function _unsafeWithdrawLogic(
        address _poolToken,
        uint256 _amount,
        address _supplier,
        address _receiver,
        uint256 _maxGasForMatching
    ) internal {
        WithdrawVars memory vars;
        vars.underlyingToken = _getUnderlying(_poolToken);
        vars.remainingToWithdraw = _amount;
        vars.remainingGasForMatching = _maxGasForMatching;
        vars.poolSupplyIndex = ICToken(_poolToken).exchangeRateStored(); // Exchange rate has already been updated.

        if (_amount.div(vars.poolSupplyIndex) == 0) revert WithdrawTooSmall();

        Types.SupplyBalance storage supplierSupplyBalance = supplyBalanceInOf[_poolToken][
            _supplier
        ];

        /// Pool withdraw ///

        // Withdraw supply on pool.
        uint256 onPoolSupply = supplierSupplyBalance.onPool;
        if (onPoolSupply > 0) {
            uint256 maxToWithdrawOnPool = onPoolSupply.mul(vars.poolSupplyIndex);

            if (maxToWithdrawOnPool > vars.remainingToWithdraw) {
                vars.toWithdraw = vars.remainingToWithdraw;
                vars.remainingToWithdraw = 0;
                supplierSupplyBalance.onPool -= vars.toWithdraw.div(vars.poolSupplyIndex);
            } else {
                vars.toWithdraw = maxToWithdrawOnPool;
                vars.remainingToWithdraw -= maxToWithdrawOnPool;
                supplierSupplyBalance.onPool = 0;
            }

            if (vars.remainingToWithdraw == 0) {
                _updateSupplierInDS(_poolToken, _supplier);
                _leaveMarketIfNeeded(_poolToken, _supplier);

                // If this value is equal to 0 the withdraw will revert on Compound.
                if (vars.toWithdraw.div(vars.poolSupplyIndex) > 0)
                    _withdrawFromPool(_poolToken, vars.toWithdraw); // Reverts on error.
                vars.underlyingToken.safeTransfer(_receiver, _amount);

                emit Withdrawn(
                    _supplier,
                    _receiver,
                    _poolToken,
                    _amount,
                    supplierSupplyBalance.onPool,
                    supplierSupplyBalance.inP2P
                );

                return;
            }
        }

        Types.Delta storage delta = deltas[_poolToken];
        vars.p2pSupplyIndex = p2pSupplyIndex[_poolToken];

        supplierSupplyBalance.inP2P -= CompoundMath.min(
            supplierSupplyBalance.inP2P,
            vars.remainingToWithdraw.div(vars.p2pSupplyIndex)
        ); // In peer-to-peer supply unit.
        _updateSupplierInDS(_poolToken, _supplier);

        // Reduce the peer-to-peer supply delta.
        if (vars.remainingToWithdraw > 0 && delta.p2pSupplyDelta > 0) {
            uint256 deltaInUnderlying = delta.p2pSupplyDelta.mul(vars.poolSupplyIndex);

            if (deltaInUnderlying > vars.remainingToWithdraw) {
                delta.p2pSupplyDelta -= vars.remainingToWithdraw.div(vars.poolSupplyIndex);
                delta.p2pSupplyAmount -= vars.remainingToWithdraw.div(vars.p2pSupplyIndex);
                vars.toWithdraw += vars.remainingToWithdraw;
                vars.remainingToWithdraw = 0;
            } else {
                delta.p2pSupplyDelta = 0;
                delta.p2pSupplyAmount -= deltaInUnderlying.div(vars.p2pSupplyIndex);
                vars.toWithdraw += deltaInUnderlying;
                vars.remainingToWithdraw -= deltaInUnderlying;
            }

            emit P2PSupplyDeltaUpdated(_poolToken, delta.p2pSupplyDelta);
            emit P2PAmountsUpdated(_poolToken, delta.p2pSupplyAmount, delta.p2pBorrowAmount);
        }

        /// Transfer withdraw ///

        // Promote pool suppliers.
        if (
            vars.remainingToWithdraw > 0 &&
            !p2pDisabled[_poolToken] &&
            suppliersOnPool[_poolToken].getHead() != address(0)
        ) {
            (uint256 matched, uint256 gasConsumedInMatching) = _matchSuppliers(
                _poolToken,
                vars.remainingToWithdraw,
                vars.remainingGasForMatching
            );
            if (vars.remainingGasForMatching <= gasConsumedInMatching)
                vars.remainingGasForMatching = 0;
            else vars.remainingGasForMatching -= gasConsumedInMatching;

            if (matched > 0) {
                vars.remainingToWithdraw -= matched;
                vars.toWithdraw += matched;
            }
        }

        // If this value is equal to 0 the withdraw will revert on Compound.
        if (vars.toWithdraw.div(vars.poolSupplyIndex) > 0)
            _withdrawFromPool(_poolToken, vars.toWithdraw); // Reverts on error.

        /// Breaking withdraw ///

        // Demote peer-to-peer borrowers.
        if (vars.remainingToWithdraw > 0) {
            uint256 unmatched = _unmatchBorrowers(
                _poolToken,
                vars.remainingToWithdraw,
                vars.remainingGasForMatching
            );

            // Increase the peer-to-peer borrow delta.
            if (unmatched < vars.remainingToWithdraw) {
                delta.p2pBorrowDelta += (vars.remainingToWithdraw - unmatched).div(
                    lastPoolIndexes[_poolToken].lastBorrowPoolIndex
                );
                emit P2PBorrowDeltaUpdated(_poolToken, delta.p2pBorrowDelta);
            }

            delta.p2pSupplyAmount -= vars.remainingToWithdraw.div(vars.p2pSupplyIndex);
            delta.p2pBorrowAmount -= unmatched.div(p2pBorrowIndex[_poolToken]);
            emit P2PAmountsUpdated(_poolToken, delta.p2pSupplyAmount, delta.p2pBorrowAmount);

            _borrowFromPool(_poolToken, vars.remainingToWithdraw); // Reverts on error.
        }

        _leaveMarketIfNeeded(_poolToken, _supplier);
        vars.underlyingToken.safeTransfer(_receiver, _amount);

        emit Withdrawn(
            _supplier,
            _receiver,
            _poolToken,
            _amount,
            supplierSupplyBalance.onPool,
            supplierSupplyBalance.inP2P
        );
    }

    /// @dev Implements repay logic without security checks.
    /// @param _poolToken The address of the market the user wants to interact with.
    /// @param _repayer The address of the account repaying the debt.
    /// @param _onBehalf The address of the account whose debt is repaid.
    /// @param _amount The amount of token (in underlying).
    /// @param _maxGasForMatching The maximum amount of gas to consume within a matching engine loop.
    function _unsafeRepayLogic(
        address _poolToken,
        address _repayer,
        address _onBehalf,
        uint256 _amount,
        uint256 _maxGasForMatching
    ) internal {
        if (lastBorrowBlock[_onBehalf] == block.number) revert SameBlockBorrowRepay();

        ERC20 underlyingToken = _getUnderlying(_poolToken);
        underlyingToken.safeTransferFrom(_repayer, address(this), _amount);

        RepayVars memory vars;
        vars.remainingToRepay = _amount;
        vars.remainingGasForMatching = _maxGasForMatching;
        vars.poolBorrowIndex = lastPoolIndexes[_poolToken].lastBorrowPoolIndex;

        Types.BorrowBalance storage borrowerBorrowBalance = borrowBalanceInOf[_poolToken][
            _onBehalf
        ];

        /// Pool repay ///

        // Repay borrow on pool.
        vars.borrowedOnPool = borrowerBorrowBalance.onPool;
        if (vars.borrowedOnPool > 0) {
            vars.maxToRepayOnPool = vars.borrowedOnPool.mul(vars.poolBorrowIndex);

            if (vars.maxToRepayOnPool > vars.remainingToRepay) {
                vars.toRepay = vars.remainingToRepay;

                borrowerBorrowBalance.onPool -= CompoundMath.min(
                    vars.borrowedOnPool,
                    vars.toRepay.div(vars.poolBorrowIndex)
                ); // In cdUnit.
                _updateBorrowerInDS(_poolToken, _onBehalf);

                _repayToPool(_poolToken, underlyingToken, vars.toRepay); // Reverts on error.
                _leaveMarketIfNeeded(_poolToken, _onBehalf);

                emit Repaid(
                    _repayer,
                    _onBehalf,
                    _poolToken,
                    _amount,
                    borrowerBorrowBalance.onPool,
                    borrowerBorrowBalance.inP2P
                );

                return;
            } else {
                vars.toRepay = vars.maxToRepayOnPool;
                vars.remainingToRepay -= vars.toRepay;

                borrowerBorrowBalance.onPool = 0;
            }
        }

        Types.Delta storage delta = deltas[_poolToken];
        vars.p2pSupplyIndex = p2pSupplyIndex[_poolToken];
        vars.p2pBorrowIndex = p2pBorrowIndex[_poolToken];

        borrowerBorrowBalance.inP2P -= CompoundMath.min(
            borrowerBorrowBalance.inP2P,
            vars.remainingToRepay.div(vars.p2pBorrowIndex)
        ); // In peer-to-peer borrow unit.
        _updateBorrowerInDS(_poolToken, _onBehalf);

        // Reduce the peer-to-peer borrow delta.
        if (vars.remainingToRepay > 0 && delta.p2pBorrowDelta > 0) {
            uint256 deltaInUnderlying = delta.p2pBorrowDelta.mul(vars.poolBorrowIndex);
            if (deltaInUnderlying > vars.remainingToRepay) {
                delta.p2pBorrowDelta -= vars.remainingToRepay.div(vars.poolBorrowIndex);
                delta.p2pBorrowAmount -= vars.remainingToRepay.div(vars.p2pBorrowIndex);
                vars.toRepay += vars.remainingToRepay;
                vars.remainingToRepay = 0;
            } else {
                delta.p2pBorrowDelta = 0;
                delta.p2pBorrowAmount -= deltaInUnderlying.div(vars.p2pBorrowIndex);
                vars.toRepay += deltaInUnderlying;
                vars.remainingToRepay -= deltaInUnderlying;
            }

            emit P2PBorrowDeltaUpdated(_poolToken, delta.p2pBorrowDelta);
            emit P2PAmountsUpdated(_poolToken, delta.p2pSupplyAmount, delta.p2pBorrowAmount);
        }

        // Repay the fee.
        if (vars.remainingToRepay > 0) {
            // Fee = (p2pBorrowAmount - p2pBorrowDelta) - (p2pSupplyAmount - p2pSupplyDelta).
            // No need to subtract p2pBorrowDelta as it is zero.
            vars.feeToRepay = CompoundMath.safeSub(
                delta.p2pBorrowAmount.mul(vars.p2pBorrowIndex),
                delta.p2pSupplyAmount.mul(vars.p2pSupplyIndex).safeSub(
                    delta.p2pSupplyDelta.mul(ICToken(_poolToken).exchangeRateStored())
                )
            );

            if (vars.feeToRepay > 0) {
                uint256 feeRepaid = CompoundMath.min(vars.feeToRepay, vars.remainingToRepay);
                vars.remainingToRepay -= feeRepaid;
                delta.p2pBorrowAmount -= feeRepaid.div(vars.p2pBorrowIndex);
                emit P2PAmountsUpdated(_poolToken, delta.p2pSupplyAmount, delta.p2pBorrowAmount);
            }
        }

        /// Transfer repay ///

        // Promote pool borrowers.
        if (
            vars.remainingToRepay > 0 &&
            !p2pDisabled[_poolToken] &&
            borrowersOnPool[_poolToken].getHead() != address(0)
        ) {
            (uint256 matched, uint256 gasConsumedInMatching) = _matchBorrowers(
                _poolToken,
                vars.remainingToRepay,
                vars.remainingGasForMatching
            );
            if (vars.remainingGasForMatching <= gasConsumedInMatching)
                vars.remainingGasForMatching = 0;
            else vars.remainingGasForMatching -= gasConsumedInMatching;

            if (matched > 0) {
                vars.remainingToRepay -= matched;
                vars.toRepay += matched;
            }
        }

        _repayToPool(_poolToken, underlyingToken, vars.toRepay); // Reverts on error.

        /// Breaking repay ///

        // Unmote peer-to-peer suppliers.
        if (vars.remainingToRepay > 0) {
            uint256 unmatched = _unmatchSuppliers(
                _poolToken,
                vars.remainingToRepay,
                vars.remainingGasForMatching
            );

            // Increase the peer-to-peer supply delta.
            if (unmatched < vars.remainingToRepay) {
                delta.p2pSupplyDelta += (vars.remainingToRepay - unmatched).div(
                    ICToken(_poolToken).exchangeRateStored() // Exchange rate has already been updated.
                );
                emit P2PSupplyDeltaUpdated(_poolToken, delta.p2pSupplyDelta);
            }

            delta.p2pSupplyAmount -= unmatched.div(vars.p2pSupplyIndex);
            delta.p2pBorrowAmount -= vars.remainingToRepay.div(vars.p2pBorrowIndex);
            emit P2PAmountsUpdated(_poolToken, delta.p2pSupplyAmount, delta.p2pBorrowAmount);

            _supplyToPool(_poolToken, underlyingToken, vars.remainingToRepay); // Reverts on error.
        }

        _leaveMarketIfNeeded(_poolToken, _onBehalf);

        emit Repaid(
            _repayer,
            _onBehalf,
            _poolToken,
            _amount,
            borrowerBorrowBalance.onPool,
            borrowerBorrowBalance.inP2P
        );
    }

    /// @dev Supplies underlying tokens to Compound.
    /// @param _poolToken The address of the pool token.
    /// @param _underlyingToken The underlying token of the market to supply to.
    /// @param _amount The amount of token (in underlying).
    function _supplyToPool(
        address _poolToken,
        ERC20 _underlyingToken,
        uint256 _amount
    ) internal {
        if (_poolToken == cEth) {
            IWETH(wEth).withdraw(_amount); // Turn wETH into ETH.
            ICEther(_poolToken).mint{value: _amount}();
        } else {
            _underlyingToken.safeApprove(_poolToken, _amount);
            if (ICToken(_poolToken).mint(_amount) != 0) revert MintOnCompoundFailed();
        }
    }

    /// @dev Withdraws underlying tokens from Compound.
    /// @param _poolToken The address of the pool token.
    /// @param _amount The amount of token (in underlying).
    function _withdrawFromPool(address _poolToken, uint256 _amount) internal {
        // Withdraw only what is possible. The remaining dust is taken from the contract balance.
        _amount = CompoundMath.min(ICToken(_poolToken).balanceOfUnderlying(address(this)), _amount);
        if (ICToken(_poolToken).redeemUnderlying(_amount) != 0) revert RedeemOnCompoundFailed();
        if (_poolToken == cEth) IWETH(address(wEth)).deposit{value: _amount}(); // Turn the ETH received in wETH.
    }

    /// @dev Borrows underlying tokens from Compound.
    /// @param _poolToken The address of the pool token.
    /// @param _amount The amount of token (in underlying).
    function _borrowFromPool(address _poolToken, uint256 _amount) internal {
        if ((ICToken(_poolToken).borrow(_amount) != 0)) revert BorrowOnCompoundFailed();
        if (_poolToken == cEth) IWETH(address(wEth)).deposit{value: _amount}(); // Turn the ETH received in wETH.
    }

    /// @dev Repays underlying tokens to Compound.
    /// @param _poolToken The address of the pool token.
    /// @param _underlyingToken The underlying token of the market to repay to.
    /// @param _amount The amount of token (in underlying).
    function _repayToPool(
        address _poolToken,
        ERC20 _underlyingToken,
        uint256 _amount
    ) internal {
        // Repay only what is necessary. The remaining tokens stays on the contracts and are claimable by the DAO.
        _amount = Math.min(
            _amount,
            ICToken(_poolToken).borrowBalanceCurrent(address(this)) // The debt of the contract.
        );

        if (_amount > 0) {
            if (_poolToken == cEth) {
                IWETH(wEth).withdraw(_amount); // Turn wETH into ETH.
                ICEther(_poolToken).repayBorrow{value: _amount}();
            } else {
                _underlyingToken.safeApprove(_poolToken, _amount);
                if (ICToken(_poolToken).repayBorrow(_amount) != 0) revert RepayOnCompoundFailed();
            }
        }
    }

    /// @dev Enters the user into the market if not already there.
    /// @param _user The address of the user to update.
    /// @param _poolToken The address of the market to check.
    function _enterMarketIfNeeded(address _poolToken, address _user) internal {
        if (!userMembership[_poolToken][_user]) {
            userMembership[_poolToken][_user] = true;
            enteredMarkets[_user].push(_poolToken);
        }
    }

    /// @dev Removes the user from the market if its balances are null.
    /// @param _user The address of the user to update.
    /// @param _poolToken The address of the market to check.
    function _leaveMarketIfNeeded(address _poolToken, address _user) internal {
        if (
            userMembership[_poolToken][_user] &&
            supplyBalanceInOf[_poolToken][_user].inP2P == 0 &&
            supplyBalanceInOf[_poolToken][_user].onPool == 0 &&
            borrowBalanceInOf[_poolToken][_user].inP2P == 0 &&
            borrowBalanceInOf[_poolToken][_user].onPool == 0
        ) {
            uint256 index;
            while (enteredMarkets[_user][index] != _poolToken) {
                unchecked {
                    ++index;
                }
            }
            userMembership[_poolToken][_user] = false;

            uint256 length = enteredMarkets[_user].length;
            if (index != length - 1)
                enteredMarkets[_user][index] = enteredMarkets[_user][length - 1];
            enteredMarkets[_user].pop();
        }
    }

    /// @dev Returns whether a given user is liquidatable and the applicable close factor, given the deprecated status of the borrowed market.
    /// @param _user The user to check.
    /// @param _isDeprecated Whether the borrowed market is deprecated or not.
    /// @return liquidationAllowed Whether the liquidation is allowed or not.
    /// @return closeFactor The close factor to apply.
    function _liquidationAllowed(address _user, bool _isDeprecated)
        internal
        view
        returns (bool liquidationAllowed, uint256 closeFactor)
    {
        if (_isDeprecated) {
            liquidationAllowed = true;
            closeFactor = WAD; // Allow liquidation of the whole debt.
        } else {
            liquidationAllowed = _isLiquidatable(_user, address(0), 0, 0);
            if (liquidationAllowed) closeFactor = comptroller.closeFactorMantissa();
        }
    }
}

// SPDX-License-Identifier: GNU AGPLv3
pragma solidity >=0.5.0;

import "./IOracle.sol";

interface IIncentivesVault {
    function isPaused() external view returns (bool);

    function bonus() external view returns (uint256);

    function MAX_BASIS_POINTS() external view returns (uint256);

    function incentivesTreasuryVault() external view returns (address);

    function oracle() external view returns (IOracle);

    function setOracle(IOracle _newOracle) external;

    function setIncentivesTreasuryVault(address _newIncentivesTreasuryVault) external;

    function setBonus(uint256 _newBonus) external;

    function setPauseStatus(bool _newStatus) external;

    function transferTokensToDao(address _token, uint256 _amount) external;

    function tradeCompForMorphoTokens(address _to, uint256 _amount) external;
}

// SPDX-License-Identifier: GNU AGPLv3
pragma solidity >=0.5.0;

interface IInterestRatesManager {
    function updateP2PIndexes(address _marketAddress) external;
}

// SPDX-License-Identifier: GNU AGPLv3
pragma solidity >=0.5.0;

interface IOracle {
    function consult(uint256 _amountIn) external returns (uint256);
}

// SPDX-License-Identifier: GNU AGPLv3
pragma solidity >=0.5.0;

interface IPositionsManager {
    function supplyLogic(
        address _poolToken,
        address _supplier,
        address _onBehalf,
        uint256 _amount,
        uint256 _maxGasForMatching
    ) external;

    function borrowLogic(
        address _poolToken,
        uint256 _amount,
        uint256 _maxGasForMatching
    ) external;

    function withdrawLogic(
        address _poolToken,
        uint256 _amount,
        address _supplier,
        address _receiver,
        uint256 _maxGasForMatching
    ) external;

    function repayLogic(
        address _poolToken,
        address _repayer,
        address _onBehalf,
        uint256 _amount,
        uint256 _maxGasForMatching
    ) external;

    function liquidateLogic(
        address _poolTokenBorrowed,
        address _poolTokenCollateral,
        address _borrower,
        uint256 _amount
    ) external;

    function increaseP2PDeltasLogic(address _poolToken, uint256 _amount) external;
}

// SPDX-License-Identifier: GNU AGPLv3
pragma solidity >=0.5.0;

import "./compound/ICompound.sol";

interface IRewardsManager {
    function initialize(address _morpho) external;

    function claimRewards(address[] calldata, address) external returns (uint256);

    function userUnclaimedCompRewards(address) external view returns (uint256);

    function compSupplierIndex(address, address) external view returns (uint256);

    function compBorrowerIndex(address, address) external view returns (uint256);

    function getLocalCompSupplyState(address _cTokenAddress)
        external
        view
        returns (IComptroller.CompMarketState memory);

    function getLocalCompBorrowState(address _cTokenAddress)
        external
        view
        returns (IComptroller.CompMarketState memory);

    function accrueUserSupplyUnclaimedRewards(
        address,
        address,
        uint256
    ) external;

    function accrueUserBorrowUnclaimedRewards(
        address,
        address,
        uint256
    ) external;
}

// SPDX-License-Identifier: GNU AGPLv3
pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256) external;
}

// SPDX-License-Identifier: GNU AGPLv3
pragma solidity >=0.5.0;

interface ICEth {
    function accrueInterest() external returns (uint256);

    function borrowRate() external returns (uint256);

    function borrowIndex() external returns (uint256);

    function borrowBalanceStored(address) external returns (uint256);

    function mint() external payable;

    function exchangeRateCurrent() external returns (uint256);

    function exchangeRateStored() external view returns (uint256);

    function supplyRatePerBlock() external returns (uint256);

    function redeem(uint256) external returns (uint256);

    function redeemUnderlying(uint256) external returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function transfer(address dst, uint256 amount) external returns (bool);

    function balanceOf(address) external returns (uint256);

    function balanceOfUnderlying(address account) external returns (uint256);

    function borrow(uint256) external returns (uint256);

    function repayBorrow() external payable;

    function borrowBalanceCurrent(address) external returns (uint256);

    function borrowRatePerBlock() external view returns (uint256);
}

interface IComptroller {
    struct CompMarketState {
        /// @notice The market's last updated compBorrowIndex or compSupplyIndex
        uint224 index;
        /// @notice The block number the index was last updated at
        uint32 block;
    }

    function liquidationIncentiveMantissa() external view returns (uint256);

    function closeFactorMantissa() external view returns (uint256);

    function admin() external view returns (address);

    function oracle() external view returns (address);

    function borrowCaps(address) external view returns (uint256);

    function markets(address)
        external
        view
        returns (
            bool isListed,
            uint256 collateralFactorMantissa,
            bool isComped
        );

    function enterMarkets(address[] calldata cTokens) external returns (uint256[] memory);

    function exitMarket(address cToken) external returns (uint256);

    function mintAllowed(
        address cToken,
        address minter,
        uint256 mintAmount
    ) external returns (uint256);

    function mintVerify(
        address cToken,
        address minter,
        uint256 mintAmount,
        uint256 mintTokens
    ) external;

    function redeemAllowed(
        address cToken,
        address redeemer,
        uint256 redeemTokens
    ) external returns (uint256);

    function redeemVerify(
        address cToken,
        address redeemer,
        uint256 redeemAmount,
        uint256 redeemTokens
    ) external;

    function borrowAllowed(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external returns (uint256);

    function borrowVerify(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external;

    function repayBorrowAllowed(
        address cToken,
        address payer,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);

    function repayBorrowVerify(
        address cToken,
        address payer,
        address borrower,
        uint256 repayAmount,
        uint256 borrowerIndex
    ) external;

    function liquidateBorrowAllowed(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);

    function liquidateBorrowVerify(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount,
        uint256 seizeTokens
    ) external;

    function seizeAllowed(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);

    function seizeVerify(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external;

    function transferAllowed(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external returns (uint256);

    function transferVerify(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external;

    /*** Liquidity/Liquidation Calculations ***/

    function liquidateCalculateSeizeTokens(
        address cTokenBorrowed,
        address cTokenCollateral,
        uint256 repayAmount
    ) external view returns (uint256, uint256);

    function getAccountLiquidity(address)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function getHypotheticalAccountLiquidity(
        address,
        address,
        uint256,
        uint256
    )
        external
        returns (
            uint256,
            uint256,
            uint256
        );

    function checkMembership(address, address) external view returns (bool);

    function mintGuardianPaused(address) external view returns (bool);

    function borrowGuardianPaused(address) external view returns (bool);

    function seizeGuardianPaused() external view returns (bool);

    function claimComp(address holder) external;

    function claimComp(address holder, address[] memory cTokens) external;

    function compSpeeds(address) external view returns (uint256);

    function compSupplySpeeds(address) external view returns (uint256);

    function compBorrowSpeeds(address) external view returns (uint256);

    function compSupplyState(address) external view returns (CompMarketState memory);

    function compBorrowState(address) external view returns (CompMarketState memory);

    function getCompAddress() external view returns (address);

    function _setPriceOracle(address newOracle) external returns (uint256);

    function _setMintPaused(ICToken cToken, bool state) external returns (bool);

    function _setBorrowPaused(ICToken cToken, bool state) external returns (bool);

    function _setCollateralFactor(ICToken cToken, uint256 newCollateralFactorMantissa)
        external
        returns (uint256);

    function _setCompSpeeds(
        ICToken[] memory cTokens,
        uint256[] memory supplySpeeds,
        uint256[] memory borrowSpeeds
    ) external;
}

interface IInterestRateModel {
    function getBorrowRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) external view returns (uint256);

    function getSupplyRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves,
        uint256 reserveFactorMantissa
    ) external view returns (uint256);
}

interface ICToken {
    function isCToken() external returns (bool);

    function transfer(address dst, uint256 amount) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function balanceOfUnderlying(address owner) external returns (uint256);

    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );

    function borrowRatePerBlock() external view returns (uint256);

    function supplyRatePerBlock() external view returns (uint256);

    function totalBorrowsCurrent() external returns (uint256);

    function borrowBalanceCurrent(address account) external returns (uint256);

    function borrowBalanceStored(address account) external view returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function exchangeRateStored() external view returns (uint256);

    function getCash() external view returns (uint256);

    function seize(
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);

    function borrowRate() external returns (uint256);

    function borrowIndex() external view returns (uint256);

    function borrow(uint256) external returns (uint256);

    function repayBorrow(uint256) external returns (uint256);

    function repayBorrowBehalf(address borrower, uint256 repayAmount) external returns (uint256);

    function liquidateBorrow(
        address borrower,
        uint256 repayAmount,
        address cTokenCollateral
    ) external returns (uint256);

    function underlying() external view returns (address);

    function mint(uint256) external returns (uint256);

    function redeemUnderlying(uint256) external returns (uint256);

    function accrueInterest() external returns (uint256);

    function totalSupply() external view returns (uint256);

    function totalBorrows() external view returns (uint256);

    function accrualBlockNumber() external view returns (uint256);

    function totalReserves() external view returns (uint256);

    function interestRateModel() external view returns (IInterestRateModel);

    function reserveFactorMantissa() external view returns (uint256);

    function initialExchangeRateMantissa() external view returns (uint256);

    /*** Admin Functions ***/

    function _setPendingAdmin(address payable newPendingAdmin) external returns (uint256);

    function _acceptAdmin() external returns (uint256);

    function _setComptroller(IComptroller newComptroller) external returns (uint256);

    function _setReserveFactor(uint256 newReserveFactorMantissa) external returns (uint256);

    function _reduceReserves(uint256 reduceAmount) external returns (uint256);

    function _setInterestRateModel(IInterestRateModel newInterestRateModel)
        external
        returns (uint256);
}

interface ICEther is ICToken {
    function mint() external payable;

    function repayBorrow() external payable;
}

interface ICompoundOracle {
    function getUnderlyingPrice(address) external view returns (uint256);
}

// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

/// @title CompoundMath.
/// @author Morpho Labs.
/// @custom:contact [email protected]
/// @dev Library emulating in solidity 8+ the behavior of Compound's mulScalarTruncate and divScalarByExpTruncate functions.
library CompoundMath {
    /// ERRORS ///

    /// @notice Reverts when the number exceeds 224 bits.
    error NumberExceeds224Bits();

    /// @notice Reverts when the number exceeds 32 bits.
    error NumberExceeds32Bits();

    /// INTERNAL ///

    function mul(uint256 x, uint256 y) internal pure returns (uint256) {
        return (x * y) / 1e18;
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256) {
        return ((1e18 * x * 1e18) / y) / 1e18;
    }

    function safe224(uint256 n) internal pure returns (uint224) {
        if (n >= 2**224) revert NumberExceeds224Bits();
        return uint224(n);
    }

    function safe32(uint256 n) internal pure returns (uint32) {
        if (n >= 2**32) revert NumberExceeds32Bits();
        return uint32(n);
    }

    function min(
        uint256 a,
        uint256 b,
        uint256 c
    ) internal pure returns (uint256) {
        return a < b ? a < c ? a : c : b < c ? b : c;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a - b : 0;
    }
}

// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

/// @title Double Linked List.
/// @author Morpho Labs.
/// @custom:contact [email protected]
/// @notice Modified double linked list with capped sorting insertion.
library DoubleLinkedList {
    /// STRUCTS ///

    struct Account {
        address prev;
        address next;
        uint256 value;
    }

    struct List {
        mapping(address => Account) accounts;
        address head;
        address tail;
    }

    /// ERRORS ///

    /// @notice Thrown when the account is already inserted in the double linked list.
    error AccountAlreadyInserted();

    /// @notice Thrown when the account to remove does not exist.
    error AccountDoesNotExist();

    /// @notice Thrown when the address is zero at insertion.
    error AddressIsZero();

    /// @notice Thrown when the value is zero at insertion.
    error ValueIsZero();

    /// INTERNAL ///

    /// @notice Returns the `account` linked to `_id`.
    /// @param _list The list to search in.
    /// @param _id The address of the account.
    /// @return The value of the account.
    function getValueOf(List storage _list, address _id) internal view returns (uint256) {
        return _list.accounts[_id].value;
    }

    /// @notice Returns the address at the head of the `_list`.
    /// @param _list The list to get the head.
    /// @return The address of the head.
    function getHead(List storage _list) internal view returns (address) {
        return _list.head;
    }

    /// @notice Returns the address at the tail of the `_list`.
    /// @param _list The list to get the tail.
    /// @return The address of the tail.
    function getTail(List storage _list) internal view returns (address) {
        return _list.tail;
    }

    /// @notice Returns the next id address from the current `_id`.
    /// @param _list The list to search in.
    /// @param _id The address of the account.
    /// @return The address of the next account.
    function getNext(List storage _list, address _id) internal view returns (address) {
        return _list.accounts[_id].next;
    }

    /// @notice Returns the previous id address from the current `_id`.
    /// @param _list The list to search in.
    /// @param _id The address of the account.
    /// @return The address of the previous account.
    function getPrev(List storage _list, address _id) internal view returns (address) {
        return _list.accounts[_id].prev;
    }

    /// @notice Removes an account of the `_list`.
    /// @param _list The list to search in.
    /// @param _id The address of the account.
    function remove(List storage _list, address _id) internal {
        Account memory account = _list.accounts[_id];
        if (account.value == 0) revert AccountDoesNotExist();

        if (account.prev != address(0)) _list.accounts[account.prev].next = account.next;
        else _list.head = account.next;
        if (account.next != address(0)) _list.accounts[account.next].prev = account.prev;
        else _list.tail = account.prev;

        delete _list.accounts[_id];
    }

    /// @notice Inserts an account in the `_list` at the right slot based on its `_value`.
    /// @param _list The list to search in.
    /// @param _id The address of the account.
    /// @param _value The value of the account.
    /// @param _maxIterations The max number of iterations.
    function insertSorted(
        List storage _list,
        address _id,
        uint256 _value,
        uint256 _maxIterations
    ) internal {
        if (_value == 0) revert ValueIsZero();
        if (_id == address(0)) revert AddressIsZero();
        if (_list.accounts[_id].value != 0) revert AccountAlreadyInserted();

        uint256 numberOfIterations;
        address next = _list.head; // If not added at the end of the list `_id` will be inserted before `next`.

        while (
            numberOfIterations < _maxIterations &&
            next != address(0) &&
            _list.accounts[next].value >= _value
        ) {
            next = _list.accounts[next].next;
            unchecked {
                ++numberOfIterations;
            }
        }

        // Account is not the new tail.
        if (numberOfIterations < _maxIterations && next != address(0)) {
            // Account is the new head.
            if (next == _list.head) {
                _list.accounts[_id] = Account({prev: address(0), next: next, value: _value});
                _list.head = _id;
                _list.accounts[next].prev = _id;
            }
            // Account is not the new head.
            else {
                address prev = _list.accounts[next].prev;
                _list.accounts[_id] = Account({prev: prev, next: next, value: _value});
                _list.accounts[prev].next = _id;
                _list.accounts[next].prev = _id;
            }
        }
        // Account is the new tail.
        else {
            // Account is the new head.
            if (_list.head == address(0)) {
                _list.accounts[_id] = Account({prev: address(0), next: address(0), value: _value});
                _list.head = _id;
                _list.tail = _id;
            }
            // Account is not the new head.
            else {
                address tail = _list.tail;
                _list.accounts[_id] = Account({prev: tail, next: address(0), value: _value});
                _list.accounts[tail].next = _id;
                _list.tail = _id;
            }
        }
    }
}

// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

/// @title Types.
/// @author Morpho Labs.
/// @custom:contact [email protected]
/// @dev Common types and structs used in Morpho contracts.
library Types {
    /// ENUMS ///

    enum PositionType {
        SUPPLIERS_IN_P2P,
        SUPPLIERS_ON_POOL,
        BORROWERS_IN_P2P,
        BORROWERS_ON_POOL
    }

    /// STRUCTS ///

    struct SupplyBalance {
        uint256 inP2P; // In peer-to-peer supply scaled unit, a unit that grows in underlying value, to keep track of the interests earned by suppliers in peer-to-peer. Multiply by the peer-to-peer supply index to get the underlying amount.
        uint256 onPool; // In pool supply scaled unit. Multiply by the pool supply index to get the underlying amount.
    }

    struct BorrowBalance {
        uint256 inP2P; // In peer-to-peer borrow scaled unit, a unit that grows in underlying value, to keep track of the interests paid by borrowers in peer-to-peer. Multiply by the peer-to-peer borrow index to get the underlying amount.
        uint256 onPool; // In pool borrow unit, a unit that grows in value, to keep track of the debt increase when borrowers are on Compound. Multiply by the pool borrow index to get the underlying amount.
    }

    // Max gas to consume during the matching process for supply, borrow, withdraw and repay functions.
    struct MaxGasForMatching {
        uint64 supply;
        uint64 borrow;
        uint64 withdraw;
        uint64 repay;
    }

    struct Delta {
        uint256 p2pSupplyDelta; // Difference between the stored peer-to-peer supply amount and the real peer-to-peer supply amount (in pool supply unit).
        uint256 p2pBorrowDelta; // Difference between the stored peer-to-peer borrow amount and the real peer-to-peer borrow amount (in pool borrow unit).
        uint256 p2pSupplyAmount; // Sum of all stored peer-to-peer supply (in peer-to-peer supply unit).
        uint256 p2pBorrowAmount; // Sum of all stored peer-to-peer borrow (in peer-to-peer borrow unit).
    }

    struct AssetLiquidityData {
        uint256 collateralValue; // The collateral value of the asset.
        uint256 maxDebtValue; // The maximum possible debt value of the asset.
        uint256 debtValue; // The debt value of the asset.
        uint256 underlyingPrice; // The price of the token.
        uint256 collateralFactor; // The liquidation threshold applied on this token.
    }

    struct LiquidityData {
        uint256 collateralValue; // The collateral value.
        uint256 maxDebtValue; // The maximum debt value possible.
        uint256 debtValue; // The debt value.
    }

    // Variables are packed together to save gas (will not exceed their limit during Morpho's lifetime).
    struct LastPoolIndexes {
        uint32 lastUpdateBlockNumber; // The last time the local pool and peer-to-peer indexes were updated.
        uint112 lastSupplyPoolIndex; // Last pool supply index.
        uint112 lastBorrowPoolIndex; // Last pool borrow index.
    }

    struct MarketParameters {
        uint16 reserveFactor; // Proportion of the interest earned by users sent to the DAO for each market, in basis point (100% = 10 000). The value is set at market creation.
        uint16 p2pIndexCursor; // Position of the peer-to-peer rate in the pool's spread. Determine the weights of the weighted arithmetic average in the indexes computations ((1 - p2pIndexCursor) * r^S + p2pIndexCursor * r^B) (in basis point).
    }

    struct MarketStatus {
        bool isCreated; // Whether or not this market is created.
        bool isPaused; // Deprecated.
        bool isPartiallyPaused; // Deprecated.
    }

    struct MarketPauseStatus {
        bool isSupplyPaused; // Whether the supply is paused or not.
        bool isBorrowPaused; // Whether the borrow is paused or not
        bool isWithdrawPaused; // Whether the withdraw is paused or not. Note that a "withdraw" is still possible using a liquidation (if not paused).
        bool isRepayPaused; // Whether the repay is paused or not. Note that a "repay" is still possible using a liquidation (if not paused).
        bool isLiquidateCollateralPaused; // Whether the liquidation on this market as collateral is paused or not.
        bool isLiquidateBorrowPaused; // Whether the liquidatation on this market as borrow is paused or not.
        bool isDeprecated; // Whether a market is deprecated or not.
    }
}