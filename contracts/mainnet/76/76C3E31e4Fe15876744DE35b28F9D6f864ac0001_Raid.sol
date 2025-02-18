// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";
import "../utils/ContextUpgradeable.sol";
import "../utils/StringsUpgradeable.sol";
import "../utils/introspection/ERC165Upgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
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
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
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
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {IConfetti} from "../interfaces/IConfetti.sol";
import {IParty} from "../interfaces/IParty.sol";
import {IRaid} from "../interfaces/IRaid.sol";
import {ISeeder} from "../interfaces/ISeeder.sol";
import {Seedable} from "../randomness/Seedable.sol";

/// @title RaidParty Raid Contract
/// @author Hasan Gondal <[email protected]>
/// @notice RAIDOOOOOOOOOOOOOOOOOOOOOOOOOOOOR

/**
 *   ___      _    _ ___          _
 *  | _ \__ _(_)__| | _ \__ _ _ _| |_ _  _
 *  |   / _` | / _` |  _/ _` | '_|  _| || |
 *  |_|_\__,_|_\__,_|_| \__,_|_|  \__|\_, |
 *                                    |__/
 */

contract Raid is IRaid, Initializable, AccessControlUpgradeable, Seedable {
    bool public started;
    bool public halted;
    bool public bossesCreated;

    uint32 private roundId;
    uint32 public weightTotal;
    uint64 public lastSnapshotTime;
    uint64 private constant PRECISION = 1e18;

    uint256 public seed;
    uint256 public seedId;

    IParty public party;
    ISeeder public seeder;
    IConfetti public confetti;

    Boss[] public bosses;
    Snapshot[] public snapshots;

    mapping(uint32 => Round) public rounds;
    mapping(address => Raider) public raiders;

    modifier notHalted() {
        require(!halted, "Raid: HALT_ACTIVE");
        _;
    }

    modifier raidActive() {
        require(started, "Raid: NOT_STARTED");
        _;
    }

    modifier partyCaller() {
        require(msg.sender == address(party), "Raid: NOT_PARTY_CALLER");
        _;
    }

    function initialize(
        address admin,
        IParty _party,
        ISeeder _seeder,
        IConfetti _confetti
    ) external initializer {
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, admin);

        party = _party;
        seeder = _seeder;
        confetti = _confetti;
    }

    function setParty(IParty _party) external onlyRole(DEFAULT_ADMIN_ROLE) {
        party = _party;
    }

    function setSeeder(ISeeder _seeder) external onlyRole(DEFAULT_ADMIN_ROLE) {
        seeder = _seeder;
    }

    function setHalted(bool _halted) external onlyRole(DEFAULT_ADMIN_ROLE) {
        halted = _halted;
    }

    function updateSeed() external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (started) {
            _syncRounds(uint32(block.number));
        }

        seed = seeder.getSeedSafe(address(this), seedId);
    }

    function requestSeed() external onlyRole(DEFAULT_ADMIN_ROLE) {
        seedId += 1;
        seeder.requestSeed(seedId);
    }

    function createBosses(Boss[] calldata _bosses)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        delete bosses;
        delete weightTotal;

        for (uint256 i; i < _bosses.length; i++) {
            Boss calldata boss = _bosses[i];
            weightTotal += boss.weight;
            bosses.push(boss);
        }

        bossesCreated = true;
    }

    function updateBoss(uint32 id, Boss calldata boss)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(bosses.length > id, "Raid::updateBoss: INVALID_BOSS");

        if (started) {
            _syncRounds(uint32(block.number));
        }

        weightTotal -= bosses[id].weight;
        weightTotal += boss.weight;
        bosses[id] = boss;
    }

    function appendBoss(Boss calldata boss)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        if (started) {
            _syncRounds(uint32(block.number));
        }

        weightTotal += boss.weight;
        bosses.push(boss);
    }

    function manualSync(uint32 maxBlock) external {
        require(
            maxBlock > rounds[roundId].finalBlock,
            "Raid::manualSync: CANNOT_SYNC_PAST"
        );

        _syncRounds(maxBlock);
    }

    function start() external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!started, "Raid::start: NOT_STARTED");
        require(bossesCreated, "Raid::start: NO_BOSSES_CREATED");

        seed = seeder.getSeedSafe(address(this), seedId);
        rounds[roundId] = _rollRound(seed, uint32(block.number));

        started = true;
        lastSnapshotTime = uint64(block.timestamp);
    }

    function commitSnapshot() external raidActive {
        require(
            block.timestamp >= lastSnapshotTime + 23 hours,
            "Raid::commitSnapshot: SNAPSHOT_TOO_RECENT"
        );

        _syncRounds(uint32(block.number));

        Snapshot memory snapshot = _createSnapshot();
        snapshots.push(snapshot);

        lastSnapshotTime = uint64(block.timestamp);
    }

    function getRaidData() external view returns (RaidData memory data) {
        uint256 _seed = seed;
        uint32 _roundId = roundId;
        Round memory round = rounds[_roundId];
        while (block.number > round.finalBlock) {
            _roundId += 1;
            _seed = _rollSeed(_seed);
            round = _rollRound(_seed, round.finalBlock + 1);
        }

        data.boss = round.boss;
        data.roundId = _roundId;
        data.health = uint32(round.finalBlock - block.number);
        data.maxHealth = bosses[round.boss].blockHealth;
        data.seed = _seed;
    }

    function getPendingRewards(address user) external view returns (uint256) {
        Raider memory raider = raiders[user];
        (, uint256 rewards) = _fetchRewards(raider);
        return rewards;
    }

    function updateDamage(address user, uint32 _dpb)
        external
        notHalted
        raidActive
        partyCaller
    {
        Raider storage raider = raiders[user];
        if (raider.startedAt == 0) {
            raider.dpb = _dpb;
            raider.startedAt = uint32(block.number);
            raider.startBlock = uint32(block.number);
            raider.startRound = _lazyFetchRoundId(uint32(block.number));
            raider.startSnapshot = uint32(snapshots.length + 1);

            return;
        }

        (uint32 _roundId, uint256 rewards) = _fetchRewards(raider);

        raider.startRound = _roundId;
        raider.pendingRewards = rewards;
        raider.dpb = _dpb;
        raider.startBlock = uint32(block.number);
        raider.startSnapshot = uint32(snapshots.length + 1);
    }

    function claimRewards(address user) external notHalted {
        Raider storage raider = raiders[user];

        (uint32 _roundId, uint256 rewards) = _fetchRewards(raider);

        raider.startRound = _roundId;
        raider.pendingRewards = 0;
        raider.startBlock = uint32(block.number);
        raider.startSnapshot = uint32(snapshots.length + 1);

        if (rewards > 0) {
            confetti.mint(user, rewards);
        }
    }

    /** Internal */

    function _rollSeed(uint256 oldSeed) internal pure returns (uint256 rolled) {
        assembly {
            mstore(0x00, oldSeed)
            rolled := keccak256(0x00, 0x20)
        }
    }

    function _rollRound(uint256 _seed, uint32 startBlock)
        internal
        view
        returns (Round memory round)
    {
        // FIXME: check if we will overflow
        unchecked {
            uint32 roll = uint32(_seed % weightTotal);
            uint256 weight = 0;
            uint32 _bossWeight;

            for (uint16 bossId; bossId < bosses.length; bossId++) {
                _bossWeight = bosses[bossId].weight;

                if (roll <= weight + _bossWeight) {
                    round.boss = bossId;
                    round.roll = roll;
                    round.startBlock = startBlock;
                    round.finalBlock = startBlock + bosses[bossId].blockHealth;

                    return round;
                }

                weight += _bossWeight;
            }
        }
    }

    function _syncRounds(uint32 maxBlock) internal {
        // FIXME: check if we will overflow
        unchecked {
            Round memory round = rounds[roundId];

            while (
                block.number > round.finalBlock && maxBlock > round.finalBlock
            ) {
                roundId += 1;
                seed = _rollSeed(seed);
                round = _rollRound(seed, round.finalBlock + 1);
                rounds[roundId] = round;
            }
        }
    }

    function _createSnapshot()
        internal
        view
        returns (Snapshot memory snapshot)
    {
        uint32 _roundId;

        if (snapshots.length > 0) {
            _roundId = snapshots[snapshots.length - 1].finalRound + 1;
        }

        snapshot.initialRound = _roundId;
        snapshot.initialBlock = rounds[_roundId].startBlock;

        while (_roundId < roundId) {
            Round memory round = rounds[_roundId];
            Boss memory boss = bosses[round.boss];

            snapshot.attackDealt +=
                uint256(boss.blockHealth) *
                uint256(boss.multiplier);

            _roundId += 1;
        }

        snapshot.finalRound = _roundId - 1;
        snapshot.finalBlock = rounds[_roundId - 1].finalBlock;
    }

    function _fetchRewards(Raider memory raider)
        internal
        view
        returns (uint32, uint256)
    {
        if (raider.dpb > 0) {
            if (snapshots.length > raider.startSnapshot) {
                (
                    uint32 _roundId,
                    uint256 rewards
                ) = _fetchNewRewardsWithSnapshot(raider);
                rewards += raider.pendingRewards;
                return (_roundId, rewards);
            } else {
                (uint32 _roundId, uint256 rewards) = _fetchNewRewards(raider);
                rewards += raider.pendingRewards;
                return (_roundId, rewards);
            }
        }

        return (_lazyFetchRoundId(uint32(block.number)), raider.pendingRewards);
    }

    function _fetchNewRewards(Raider memory raider)
        internal
        view
        returns (uint32 _roundId, uint256 rewards)
    {
        // FIXME: check if we will overflow
        unchecked {
            Boss memory boss;
            Round memory round;

            uint256 _seed = seed;

            if (raider.startRound <= roundId) {
                _roundId = raider.startRound;
                for (_roundId; _roundId <= roundId; _roundId++) {
                    round = rounds[_roundId];
                    boss = bosses[round.boss];
                    rewards += _roundReward(raider, round, boss);
                }
                _roundId -= 1;
            } else {
                _roundId = roundId;
                round = rounds[_roundId];
            }

            while (block.number > round.finalBlock) {
                _roundId += 1;
                _seed = _rollSeed(_seed);
                round = _rollRound(_seed, round.finalBlock + 1);
                boss = bosses[round.boss];

                if (_roundId >= raider.startRound) {
                    rewards += _roundReward(raider, round, boss);
                }
            }
        }
    }

    function _fetchNewRewardsWithSnapshot(Raider memory raider)
        internal
        view
        returns (uint32 _roundId, uint256 rewards)
    {
        // FIXME: check if we will overflow
        unchecked {
            Boss memory boss;
            Round memory round;

            _roundId = raider.startRound;
            uint256 _snapshotId = raider.startSnapshot;
            uint32 _lastRound = snapshots[_snapshotId].initialRound;

            for (_roundId; _roundId < _lastRound; _roundId++) {
                round = rounds[_roundId];
                boss = bosses[round.boss];
                rewards += _roundReward(raider, round, boss);
            }

            for (_snapshotId; _snapshotId < snapshots.length; _snapshotId++) {
                rewards += snapshots[_snapshotId].attackDealt * raider.dpb;
                _roundId = snapshots[_snapshotId].finalRound;
                round = rounds[_roundId];
            }

            uint256 _seed = seed;
            while (block.number > round.finalBlock) {
                _roundId += 1;
                _seed = _rollSeed(_seed);
                round = _rollRound(_seed, round.finalBlock + 1);
                boss = bosses[round.boss];
                rewards += _roundReward(raider, round, boss);
            }
        }
    }

    function _lazyFetchRoundId(uint32 maxBlock)
        internal
        view
        returns (uint32 _roundId)
    {
        // FIXME: check if we will overflow
        unchecked {
            _roundId = roundId;
            Round memory round = rounds[_roundId];
            uint256 _seed = seed;
            while (maxBlock > round.finalBlock) {
                _roundId += 1;
                _seed = _rollSeed(_seed);
                round = _rollRound(_seed, round.finalBlock + 1);
            }
        }
    }

    function _roundReward(
        Raider memory raider,
        Round memory round,
        Boss memory boss
    ) internal view returns (uint256 reward) {
        // cases -
        // User lasts the entire round [XXXXXXXXX];
        // User joins mid round [000XXXXXX];
        // User joins and leaves mid round [000XXX000];
        // User leaves mid round [XXXXXX000];

        unchecked {
            uint256 blocksDefeated = boss.blockHealth;

            if (
                block.number > round.finalBlock &&
                raider.startBlock > round.startBlock
            ) {
                blocksDefeated = round.finalBlock - raider.startBlock;
            } else if (
                round.finalBlock > block.number &&
                raider.startBlock > round.startBlock
            ) {
                blocksDefeated = block.number - raider.startBlock;
            } else if (
                round.finalBlock > block.number &&
                round.startBlock >= raider.startBlock
            ) {
                blocksDefeated = block.number - round.startBlock;
            }

            reward =
                (1e18 *
                    uint256(blocksDefeated) *
                    uint256(boss.multiplier) *
                    uint256(raider.dpb)) /
                PRECISION;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IConfetti is IERC20 {
    function mint(address to, uint256 amount) external;

    function burn(uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/Stats.sol";

interface IParty {
    event Equipped(address indexed user, uint8 item, uint8 slot, uint256 id);

    event Unequipped(address indexed user, uint8 item, uint8 slot, uint256 id);

    event DamageUpdated(address indexed user, uint32 damageCurr);

    struct PartyData {
        uint256 hero;
        mapping(uint256 => uint256) fighters;
    }

    struct Action {
        ActionType action;
        uint256 id;
        uint8 slot;
    }

    enum Property {
        HERO,
        FIGHTER
    }

    enum ActionType {
        UNEQUIP,
        EQUIP
    }

    function act(
        Action[] calldata heroActions,
        Action[] calldata fighterActions
    ) external;

    function equip(
        Property item,
        uint256 id,
        uint8 slot
    ) external;

    function unequip(Property item, uint8 slot) external;

    function enhance(
        Property item,
        uint8 slot,
        uint256 burnTokenId
    ) external;

    function getUserHero(address user) external view returns (uint256);

    function getUserFighters(address user)
        external
        view
        returns (uint256[] memory);

    function getDamage(address user) external view returns (uint32);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRaid {
    struct Round {
        uint16 boss;
        uint32 roll;
        uint32 startBlock;
        uint32 finalBlock;
    }

    struct Raider {
        uint32 dpb;
        uint32 startedAt;
        uint32 startBlock;
        uint32 startRound;
        uint32 startSnapshot;
        uint256 pendingRewards;
    }

    struct Boss {
        uint32 weight;
        uint32 blockHealth;
        uint128 multiplier;
    }

    struct Snapshot {
        uint32 initialBlock;
        uint32 initialRound;
        uint32 finalBlock;
        uint32 finalRound;
        uint256 attackDealt;
    }

    struct RaidData {
        uint16 boss;
        uint32 roundId;
        uint32 health;
        uint32 maxHealth;
        uint256 seed;
    }

    function updateDamage(address user, uint32 _dpb) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/Randomness.sol";

interface ISeeder {
    event Requested(address indexed origin, uint256 indexed identifier);

    event Seeded(bytes32 identifier, uint256 randomness);

    function getIdReferenceCount(
        bytes32 randomnessId,
        address origin,
        uint256 startIdx
    ) external view returns (uint256);

    function getIdentifiers(
        bytes32 randomnessId,
        address origin,
        uint256 startIdx,
        uint256 count
    ) external view returns (uint256[] memory);

    function requestSeed(uint256 identifier) external;

    function getSeed(address origin, uint256 identifier)
        external
        view
        returns (uint256);

    function getSeedSafe(address origin, uint256 identifier)
        external
        view
        returns (uint256);

    function executeRequestMulti() external;

    function isSeeded(address origin, uint256 identifier)
        external
        view
        returns (bool);

    function setFee(uint256 fee) external;

    function getFee() external view returns (uint256);

    function getData(address origin, uint256 identifier)
        external
        view
        returns (Randomness.SeedData memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Randomness {
    struct SeedData {
        uint256 batch;
        bytes32 randomnessId;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Stats {
    struct HeroStats {
        uint8 dmgMultiplier;
        uint8 partySize;
        uint8 enhancement;
    }

    struct FighterStats {
        uint32 dmg;
        uint8 enhancement;
    }

    struct EquipmentStats {
        uint32 dmg;
        uint8 dmgMultiplier;
        uint8 slot;
    }
}

// SPDX-License-Identifier: MIT

/// @title RaidParty Helper Contract for Seedability

/**
 *   ___      _    _ ___          _
 *  | _ \__ _(_)__| | _ \__ _ _ _| |_ _  _
 *  |   / _` | / _` |  _/ _` | '_|  _| || |
 *  |_|_\__,_|_\__,_|_| \__,_|_|  \__|\_, |
 *                                    |__/
 */

pragma solidity ^0.8.0;

abstract contract Seedable {
    function _validateSeed(uint256 id) internal pure {
        require(id != 0, "Seedable: not seeded");
    }
}