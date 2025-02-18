// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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
interface IERC165Upgradeable {
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

//
//
//
//                                                 #####(
//                                              ###########
//                       @@@                   ###/    ####
//                       @@@    @@@@@@&  @@@@       #######.
//          @@@@,  @@@   @@@  @@@@@@@@ @@@@@@@@          ####
//        @@@@@@@@@@@@@ @@@@@ @@@@@@@@ @@@@@@@@  ###     ####
//       @@@@#    @@@@@ @@@@@   @@@@     @@@@    ##########*
//       @@@@@    @@@@@ @@@@@   @@@@     @@@@
//        @@@@@@@@@@@@@ @@@@@   @@@@     @@@@@@
//                @@@@@  @@@    @@@       @@@@@
//        @@@@@@@@@@@@
//           &@@@@.
//
//
//
//
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

// SPDX-License-Identifier: UNLICENSED
// v0.1.3

interface ERCBase {
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
  function isApprovedForAll(address account, address operator) external view returns (bool);
  function getApproved(uint256 tokenId) external view returns (address);
}

interface ERC721Partial is ERCBase {
  function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

interface ERC1155Partial is ERCBase {
  function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata) external;
}

contract Gifts is Initializable, PausableUpgradeable, OwnableUpgradeable, IERC721ReceiverUpgradeable, IERC1155ReceiverUpgradeable {

    bytes4 _ERC721;
    bytes4 _ERC1155;

    event NFTGifted(address indexed owner, address indexed tokenContractAddress, uint256 tokenId, uint indexed id, uint256 timestamp);
    event NFTClaimed(address indexed recipient, address indexed tokenContractAddress, uint256 tokenId, uint indexed id, uint256 timestamp);
    event NFTWithdrawn(address indexed owner, address indexed tokenContractAddress, uint256 tokenId, uint indexed id, uint256 timestamp);

    uint24 constant chainId = 1;

    struct Gift {
        address sender;
        address recipient;
        uint id;
        address tokenContractAddress;
        uint256 tokenId;
        bool claimed;
        bool withdrawn;
    }

    Gift[] gifts;
    mapping (address => uint256[]) giftsSent;
    mapping (address => uint256[]) giftsReceived;

    address _giftSigner;

    uint _defaultFee;

    struct FeeOverride {
        uint fee;
        bool set;
    }

    mapping (address => FeeOverride) senderFeeOverride;
    mapping (address => FeeOverride) tokenContractFeeOverride;

    uint _amountOfGasToSendToRelay;

    function initialize() public initializer {
        _ERC721 = 0x80ac58cd;
        _ERC1155 = 0xd9b67a26;

        // Call the init function of OwnableUpgradeable to set owner
        // Calls will fail without this
        __Ownable_init();

        _defaultFee = 0.01 ether;

        //set the NFT claim signer to be the deployer of the contract.
        //this can be changed after deployment
        _giftSigner = owner();
    }

    function pause() onlyOwner external {
        _pause();
    }

    function unpause() onlyOwner external {
        _unpause();
    }

    function setGiftSigner(address newSigner) onlyOwner external {
        _giftSigner = newSigner;
    }

    function giftSigner() view public returns(address) {
        return _giftSigner;
    }

    function setDefaultFee(uint newFee) onlyOwner external {
        _defaultFee = newFee;
    }

    function getDefaultFee() public view returns (uint) {
        return _defaultFee;
    }

    function setGasToSendToRelay(uint newGasAmount) onlyOwner external {
        _amountOfGasToSendToRelay = newGasAmount;
    }

    function getGasToSendToRelay() public view returns (uint) {
        return _amountOfGasToSendToRelay;
    }

    function isSenderFeeOverride(address sender) public view returns (bool) {
        return senderFeeOverride[sender].set;
    }

    function getSenderFee(address sender) public view returns (uint) {
        return senderFeeOverride[sender].fee;
    }

    function setSenderFee(address sender, uint newFee) onlyOwner external {
        senderFeeOverride[sender] = FeeOverride(newFee, true);
    }

    function unsetSenderFee(address sender) onlyOwner external {
        delete(senderFeeOverride[sender]);
    }

    function isTokenContractFeeOverride(address tokenContractAddress) public view returns (bool) {
        return tokenContractFeeOverride[tokenContractAddress].set;
    }

    function getTokenContractFee(address tokenContractAddress) public view returns (uint) {
        return tokenContractFeeOverride[tokenContractAddress].fee;
    }

    function setTokenContractFee(address tokenContractAddress, uint newFee) onlyOwner external {
        tokenContractFeeOverride[tokenContractAddress] = FeeOverride(newFee, true);
    }

    function unsetTokenContractFee(address tokenContractAddress) onlyOwner external {
        delete(tokenContractFeeOverride[tokenContractAddress]);
    }

    function getFee(address giftSender, address tokenContractAddress) public view returns (uint) {
        uint fee = getDefaultFee();

        //if sender override
        if(isSenderFeeOverride(giftSender) == true) {
            uint senderFee = getSenderFee(giftSender);

            if(senderFee < fee) {
                fee = senderFee;
            }
        }

        //if nftcontract override
        if(isTokenContractFeeOverride(tokenContractAddress) == true) {
            uint tokenContractFee = getTokenContractFee(tokenContractAddress);

            if(tokenContractFee < fee) {
                fee = tokenContractFee;
            }
        }

        //return the lowest number
        return fee;
    }

    function withdrawFees(address payable to) public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0 wei, "Error: No balance to withdraw");
        to.transfer(balance);
    }

    function claimNFT(uint256 giftId,
                      address recipientAddress,
                      bytes32 hashedmessage,
                      uint8 sigV,
                      bytes32 sigR,
                      bytes32 sigS) external whenNotPaused {

        ERCBase tokenContract;

        bytes32 eip712DomainHash = keccak256(
            abi.encode(
                keccak256(
                    abi.encodePacked("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
                ),
                keccak256("Gift3"),
                keccak256("1"),
                chainId,
                address(this)
            )
        );

        bytes32 hashStruct = keccak256(
            abi.encode(
                keccak256(abi.encodePacked("GiftClaim(uint256 giftId,address recip_wallet)")),
                giftId,
                recipientAddress
            )
        );

        bytes32 hash = keccak256(abi.encodePacked("\x19\x01", eip712DomainHash, hashStruct));

        require(hash == hashedmessage, "Hashes do not match");

        address recovered_signer = ecrecover(hash, sigV, sigR, sigS);

        require(recovered_signer == giftSigner(), "Must be signed by GiftSigner");

        Gift memory gift = gifts[giftId];
        if(
            gift.claimed == false &&
            gift.withdrawn == false
        ) {
            tokenContract = ERCBase(gift.tokenContractAddress);

            //set state before safeTransferFrom to avoid re-entrancy
            gifts[giftId].claimed = true;
            gifts[giftId].recipient = recipientAddress;
            giftsReceived[recipientAddress].push(giftId);

            if (tokenContract.supportsInterface(_ERC721)) {
                emit NFTClaimed(recipientAddress, gift.tokenContractAddress, gift.tokenId, giftId, block.timestamp);
                ERC721Partial(gift.tokenContractAddress).safeTransferFrom(address(this), recipientAddress, gift.tokenId);
            } else if(tokenContract.supportsInterface(_ERC1155)) {
                emit NFTClaimed(recipientAddress, gift.tokenContractAddress, gift.tokenId, giftId, block.timestamp);
                ERC1155Partial(gift.tokenContractAddress).safeTransferFrom(address(this), recipientAddress, gift.tokenId, 1, "");
            } else {
                revert("Token contract not ERC721 or ERC1155");
            }

            return;
        }

        revert("Gift not found or already claimed or withdrawn");
    }

    function withdrawNFT(uint256 giftId) external {
        ERCBase tokenContract;

        tokenContract = ERCBase(gifts[giftId].tokenContractAddress);

        require(gifts[giftId].sender == msg.sender, "Caller must be original sender");
        require(gifts[giftId].withdrawn != true, "Gift already withdrawn");
        require(gifts[giftId].claimed != true, "Gift already claimed");

        //set state before safeTransferFrom to avoid re-entrancy
        gifts[giftId].withdrawn = true;
        emit NFTWithdrawn(msg.sender, gifts[giftId].tokenContractAddress, gifts[giftId].tokenId, giftId, block.timestamp);

        if (tokenContract.supportsInterface(_ERC721)) {
          ERC721Partial(gifts[giftId].tokenContractAddress).safeTransferFrom(address(this), msg.sender, gifts[giftId].tokenId);
        }
        else if (tokenContract.supportsInterface(_ERC1155)) {
          ERC1155Partial(gifts[giftId].tokenContractAddress).safeTransferFrom(address(this), msg.sender, gifts[giftId].tokenId, 1, "");
        } else {
          revert("Contract is not ERC721 or ERC1155");
        }

        return;
    }

    function giftNFT(address tokenContractAddress, uint256 tokenId) external payable whenNotPaused {
        require(tokenContractAddress != address(0), "Token contract cannot be 0x0");

        ERCBase tokenContract;
        tokenContract = ERCBase(tokenContractAddress);

        // load the amount of gas to split off and send to relay to fund claim txn
        uint amountOfGasToSendToRelay = getGasToSendToRelay();

        //check if enough fee has been sent in the transaction
        //this will also check for overrides for sender and contract
        //this will also check it includes the amount of gas to send to the relay for claim txn
        require(msg.value >= (getFee(msg.sender, tokenContractAddress) + amountOfGasToSendToRelay), "Transaction not including enough fee.");

        //set state before safeTransferFrom to avoid re-entrancy
        Gift memory currentGift;
        currentGift.id = gifts.length;
        currentGift.sender = msg.sender;
        currentGift.tokenContractAddress = tokenContractAddress;
        currentGift.tokenId = tokenId;
        currentGift.claimed = false;
        currentGift.withdrawn = false;
        //currentGift.block = block.number;

        gifts.push(currentGift);
        giftsSent[msg.sender].push(currentGift.id);

        //send gas to relay/signer
        address signer = giftSigner();
        payable(signer).transfer(amountOfGasToSendToRelay);

        emit NFTGifted(msg.sender, tokenContractAddress, tokenId, currentGift.id, block.timestamp);

        if (tokenContract.supportsInterface(_ERC721)) {
            require(
                tokenContract.getApproved(tokenId) == address(this) ||
                tokenContract.isApprovedForAll(msg.sender, address(this)),
                    "Token not yet approved for transfer");

            ERC721Partial(tokenContractAddress).safeTransferFrom(msg.sender, address(this), tokenId);
        }
        else if (tokenContract.supportsInterface(_ERC1155)) {
            require(
                tokenContract.isApprovedForAll(msg.sender, address(this)),
                    "Token not yet approved for transfer");

            ERC1155Partial(tokenContractAddress).safeTransferFrom(msg.sender, address(this), tokenId, 1, "");
        } else {
            revert("Token contract is not ERC721 or ERC1155");
        }

    }

    function getGiftsSent(address giftSender) public view returns (uint[] memory) {
        return giftsSent[giftSender];
    }

    function getGiftsReceived(address giftRecipient) public view returns (uint[] memory) {
        return giftsReceived[giftRecipient];
    }

    function getGiftSender(uint giftId) public view returns (address) {
        return gifts[giftId].sender;
    }

    function getGiftRecipient(uint giftId) public view returns (address) {
        return gifts[giftId].recipient;
    }

    function getGiftTokenContractAddress(uint giftId) public view returns (address) {
        return gifts[giftId].tokenContractAddress;
    }

    function getGiftTokenId(uint giftId) public view returns (uint) {
        return gifts[giftId].tokenId;
    }

    function isGiftClaimed(uint giftId) public view returns (bool) {
        return gifts[giftId].claimed;
    }

    function isGiftWithdrawn(uint giftId) public view returns (bool) {
        return gifts[giftId].withdrawn;
    }

    /**
     * Implements ERC721 recieve support.
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /**
     * Implements ERC1155 recieve support.
     */
    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    /**
     * Implements ERC1155 recieve support.
     */
    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceID) external override pure returns (bool) {
        return  interfaceID == 0x80ac58cd ||    // ERC-721 support
                interfaceID == 0x01ffc9a7 ||    // ERC-165 support (i.e. `bytes4(keccak256('supportsInterface(bytes4)'))`).
                interfaceID == 0x4e2312e0;      // ERC-1155 `ERC1155TokenReceiver` support (i.e. `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)")) ^ bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`).
    }

    receive () external payable { }

    fallback () external payable { }

}