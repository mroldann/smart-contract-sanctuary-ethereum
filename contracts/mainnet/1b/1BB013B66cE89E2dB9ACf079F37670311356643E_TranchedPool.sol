pragma solidity ^0.6.0;
import "../Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {


    }


    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}

pragma solidity >=0.4.24 <0.7.0;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

pragma solidity ^0.6.0;

import "../utils/EnumerableSet.sol";
import "../utils/Address.sol";
import "../GSN/Context.sol";
import "../Initializable.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
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
 *     require(hasRole(MY_ROLE, _msgSender()));
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
 */
abstract contract AccessControlUpgradeSafe is Initializable, ContextUpgradeSafe {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {


    }

    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
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
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
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
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

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
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

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
    function renounceRole(bytes32 role, address account) public virtual {
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
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }

    uint256[49] private __gap;
}

pragma solidity ^0.6.0;

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
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

pragma solidity ^0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity ^0.6.0;

/**
 * @title SignedSafeMath
 * @dev Signed math operations with safety checks that revert on error.
 */
library SignedSafeMath {
    int256 constant private _INT256_MIN = -2**255;

    /**
     * @dev Multiplies two signed integers, reverts on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Integer division of two signed integers truncating the quotient, reverts on division by zero.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    /**
     * @dev Subtracts two signed integers, reverts on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    /**
     * @dev Adds two signed integers, reverts on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}

pragma solidity ^0.6.0;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

pragma solidity ^0.6.2;

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
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

pragma solidity ^0.6.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

pragma solidity ^0.6.0;

import "../GSN/Context.sol";
import "../Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract PausableUpgradeSafe is Initializable, ContextUpgradeSafe {
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

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {


        _paused = false;

    }


    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    uint256[49] private __gap;
}

pragma solidity ^0.6.0;
import "../Initializable.sol";

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
contract ReentrancyGuardUpgradeSafe is Initializable {
    bool private _notEntered;


    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {


        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;

    }


    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }

    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over `owner`'s tokens,
     * given `owner`'s signed approval.
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
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for `permit`, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

// SPDX-License-Identifier: AGPL-3.0-only
// solhint-disable
// Imported from https://github.com/UMAprotocol/protocol/blob/4d1c8cc47a4df5e79f978cb05647a7432e111a3d/packages/core/contracts/common/implementation/FixedPoint.sol
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/math/SignedSafeMath.sol";

/**
 * @title Library for fixed point arithmetic on uints
 */
library FixedPoint {
  using SafeMath for uint256;
  using SignedSafeMath for int256;

  // Supports 18 decimals. E.g., 1e18 represents "1", 5e17 represents "0.5".
  // For unsigned values:
  //   This can represent a value up to (2^256 - 1)/10^18 = ~10^59. 10^59 will be stored internally as uint256 10^77.
  uint256 private constant FP_SCALING_FACTOR = 10 ** 18;

  // --------------------------------------- UNSIGNED -----------------------------------------------------------------------------
  struct Unsigned {
    uint256 rawValue;
  }

  /**
   * @notice Constructs an `Unsigned` from an unscaled uint, e.g., `b=5` gets stored internally as `5**18`.
   * @param a uint to convert into a FixedPoint.
   * @return the converted FixedPoint.
   */
  function fromUnscaledUint(uint256 a) internal pure returns (Unsigned memory) {
    return Unsigned(a.mul(FP_SCALING_FACTOR));
  }

  /**
   * @notice Whether `a` is equal to `b`.
   * @param a a FixedPoint.
   * @param b a uint256.
   * @return True if equal, or False.
   */
  function isEqual(Unsigned memory a, uint256 b) internal pure returns (bool) {
    return a.rawValue == fromUnscaledUint(b).rawValue;
  }

  /**
   * @notice Whether `a` is equal to `b`.
   * @param a a FixedPoint.
   * @param b a FixedPoint.
   * @return True if equal, or False.
   */
  function isEqual(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {
    return a.rawValue == b.rawValue;
  }

  /**
   * @notice Whether `a` is greater than `b`.
   * @param a a FixedPoint.
   * @param b a FixedPoint.
   * @return True if `a > b`, or False.
   */
  function isGreaterThan(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {
    return a.rawValue > b.rawValue;
  }

  /**
   * @notice Whether `a` is greater than `b`.
   * @param a a FixedPoint.
   * @param b a uint256.
   * @return True if `a > b`, or False.
   */
  function isGreaterThan(Unsigned memory a, uint256 b) internal pure returns (bool) {
    return a.rawValue > fromUnscaledUint(b).rawValue;
  }

  /**
   * @notice Whether `a` is greater than `b`.
   * @param a a uint256.
   * @param b a FixedPoint.
   * @return True if `a > b`, or False.
   */
  function isGreaterThan(uint256 a, Unsigned memory b) internal pure returns (bool) {
    return fromUnscaledUint(a).rawValue > b.rawValue;
  }

  /**
   * @notice Whether `a` is greater than or equal to `b`.
   * @param a a FixedPoint.
   * @param b a FixedPoint.
   * @return True if `a >= b`, or False.
   */
  function isGreaterThanOrEqual(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {
    return a.rawValue >= b.rawValue;
  }

  /**
   * @notice Whether `a` is greater than or equal to `b`.
   * @param a a FixedPoint.
   * @param b a uint256.
   * @return True if `a >= b`, or False.
   */
  function isGreaterThanOrEqual(Unsigned memory a, uint256 b) internal pure returns (bool) {
    return a.rawValue >= fromUnscaledUint(b).rawValue;
  }

  /**
   * @notice Whether `a` is greater than or equal to `b`.
   * @param a a uint256.
   * @param b a FixedPoint.
   * @return True if `a >= b`, or False.
   */
  function isGreaterThanOrEqual(uint256 a, Unsigned memory b) internal pure returns (bool) {
    return fromUnscaledUint(a).rawValue >= b.rawValue;
  }

  /**
   * @notice Whether `a` is less than `b`.
   * @param a a FixedPoint.
   * @param b a FixedPoint.
   * @return True if `a < b`, or False.
   */
  function isLessThan(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {
    return a.rawValue < b.rawValue;
  }

  /**
   * @notice Whether `a` is less than `b`.
   * @param a a FixedPoint.
   * @param b a uint256.
   * @return True if `a < b`, or False.
   */
  function isLessThan(Unsigned memory a, uint256 b) internal pure returns (bool) {
    return a.rawValue < fromUnscaledUint(b).rawValue;
  }

  /**
   * @notice Whether `a` is less than `b`.
   * @param a a uint256.
   * @param b a FixedPoint.
   * @return True if `a < b`, or False.
   */
  function isLessThan(uint256 a, Unsigned memory b) internal pure returns (bool) {
    return fromUnscaledUint(a).rawValue < b.rawValue;
  }

  /**
   * @notice Whether `a` is less than or equal to `b`.
   * @param a a FixedPoint.
   * @param b a FixedPoint.
   * @return True if `a <= b`, or False.
   */
  function isLessThanOrEqual(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {
    return a.rawValue <= b.rawValue;
  }

  /**
   * @notice Whether `a` is less than or equal to `b`.
   * @param a a FixedPoint.
   * @param b a uint256.
   * @return True if `a <= b`, or False.
   */
  function isLessThanOrEqual(Unsigned memory a, uint256 b) internal pure returns (bool) {
    return a.rawValue <= fromUnscaledUint(b).rawValue;
  }

  /**
   * @notice Whether `a` is less than or equal to `b`.
   * @param a a uint256.
   * @param b a FixedPoint.
   * @return True if `a <= b`, or False.
   */
  function isLessThanOrEqual(uint256 a, Unsigned memory b) internal pure returns (bool) {
    return fromUnscaledUint(a).rawValue <= b.rawValue;
  }

  /**
   * @notice The minimum of `a` and `b`.
   * @param a a FixedPoint.
   * @param b a FixedPoint.
   * @return the minimum of `a` and `b`.
   */
  function min(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {
    return a.rawValue < b.rawValue ? a : b;
  }

  /**
   * @notice The maximum of `a` and `b`.
   * @param a a FixedPoint.
   * @param b a FixedPoint.
   * @return the maximum of `a` and `b`.
   */
  function max(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {
    return a.rawValue > b.rawValue ? a : b;
  }

  /**
   * @notice Adds two `Unsigned`s, reverting on overflow.
   * @param a a FixedPoint.
   * @param b a FixedPoint.
   * @return the sum of `a` and `b`.
   */
  function add(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {
    return Unsigned(a.rawValue.add(b.rawValue));
  }

  /**
   * @notice Adds an `Unsigned` to an unscaled uint, reverting on overflow.
   * @param a a FixedPoint.
   * @param b a uint256.
   * @return the sum of `a` and `b`.
   */
  function add(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {
    return add(a, fromUnscaledUint(b));
  }

  /**
   * @notice Subtracts two `Unsigned`s, reverting on overflow.
   * @param a a FixedPoint.
   * @param b a FixedPoint.
   * @return the difference of `a` and `b`.
   */
  function sub(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {
    return Unsigned(a.rawValue.sub(b.rawValue));
  }

  /**
   * @notice Subtracts an unscaled uint256 from an `Unsigned`, reverting on overflow.
   * @param a a FixedPoint.
   * @param b a uint256.
   * @return the difference of `a` and `b`.
   */
  function sub(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {
    return sub(a, fromUnscaledUint(b));
  }

  /**
   * @notice Subtracts an `Unsigned` from an unscaled uint256, reverting on overflow.
   * @param a a uint256.
   * @param b a FixedPoint.
   * @return the difference of `a` and `b`.
   */
  function sub(uint256 a, Unsigned memory b) internal pure returns (Unsigned memory) {
    return sub(fromUnscaledUint(a), b);
  }

  /**
   * @notice Multiplies two `Unsigned`s, reverting on overflow.
   * @dev This will "floor" the product.
   * @param a a FixedPoint.
   * @param b a FixedPoint.
   * @return the product of `a` and `b`.
   */
  function mul(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {
    // There are two caveats with this computation:
    // 1. Max output for the represented number is ~10^41, otherwise an intermediate value overflows. 10^41 is
    // stored internally as a uint256 ~10^59.
    // 2. Results that can't be represented exactly are truncated not rounded. E.g., 1.4 * 2e-18 = 2.8e-18, which
    // would round to 3, but this computation produces the result 2.
    // No need to use SafeMath because FP_SCALING_FACTOR != 0.
    return Unsigned(a.rawValue.mul(b.rawValue) / FP_SCALING_FACTOR);
  }

  /**
   * @notice Multiplies an `Unsigned` and an unscaled uint256, reverting on overflow.
   * @dev This will "floor" the product.
   * @param a a FixedPoint.
   * @param b a uint256.
   * @return the product of `a` and `b`.
   */
  function mul(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {
    return Unsigned(a.rawValue.mul(b));
  }

  /**
   * @notice Multiplies two `Unsigned`s and "ceil's" the product, reverting on overflow.
   * @param a a FixedPoint.
   * @param b a FixedPoint.
   * @return the product of `a` and `b`.
   */
  function mulCeil(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {
    uint256 mulRaw = a.rawValue.mul(b.rawValue);
    uint256 mulFloor = mulRaw / FP_SCALING_FACTOR;
    uint256 mod = mulRaw.mod(FP_SCALING_FACTOR);
    if (mod != 0) {
      return Unsigned(mulFloor.add(1));
    } else {
      return Unsigned(mulFloor);
    }
  }

  /**
   * @notice Multiplies an `Unsigned` and an unscaled uint256 and "ceil's" the product, reverting on overflow.
   * @param a a FixedPoint.
   * @param b a FixedPoint.
   * @return the product of `a` and `b`.
   */
  function mulCeil(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {
    // Since b is an int, there is no risk of truncation and we can just mul it normally
    return Unsigned(a.rawValue.mul(b));
  }

  /**
   * @notice Divides one `Unsigned` by an `Unsigned`, reverting on overflow or division by 0.
   * @dev This will "floor" the quotient.
   * @param a a FixedPoint numerator.
   * @param b a FixedPoint denominator.
   * @return the quotient of `a` divided by `b`.
   */
  function div(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {
    // There are two caveats with this computation:
    // 1. Max value for the number dividend `a` represents is ~10^41, otherwise an intermediate value overflows.
    // 10^41 is stored internally as a uint256 10^59.
    // 2. Results that can't be represented exactly are truncated not rounded. E.g., 2 / 3 = 0.6 repeating, which
    // would round to 0.666666666666666667, but this computation produces the result 0.666666666666666666.
    return Unsigned(a.rawValue.mul(FP_SCALING_FACTOR).div(b.rawValue));
  }

  /**
   * @notice Divides one `Unsigned` by an unscaled uint256, reverting on overflow or division by 0.
   * @dev This will "floor" the quotient.
   * @param a a FixedPoint numerator.
   * @param b a uint256 denominator.
   * @return the quotient of `a` divided by `b`.
   */
  function div(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {
    return Unsigned(a.rawValue.div(b));
  }

  /**
   * @notice Divides one unscaled uint256 by an `Unsigned`, reverting on overflow or division by 0.
   * @dev This will "floor" the quotient.
   * @param a a uint256 numerator.
   * @param b a FixedPoint denominator.
   * @return the quotient of `a` divided by `b`.
   */
  function div(uint256 a, Unsigned memory b) internal pure returns (Unsigned memory) {
    return div(fromUnscaledUint(a), b);
  }

  /**
   * @notice Divides one `Unsigned` by an `Unsigned` and "ceil's" the quotient, reverting on overflow or division by 0.
   * @param a a FixedPoint numerator.
   * @param b a FixedPoint denominator.
   * @return the quotient of `a` divided by `b`.
   */
  function divCeil(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {
    uint256 aScaled = a.rawValue.mul(FP_SCALING_FACTOR);
    uint256 divFloor = aScaled.div(b.rawValue);
    uint256 mod = aScaled.mod(b.rawValue);
    if (mod != 0) {
      return Unsigned(divFloor.add(1));
    } else {
      return Unsigned(divFloor);
    }
  }

  /**
   * @notice Divides one `Unsigned` by an unscaled uint256 and "ceil's" the quotient, reverting on overflow or division by 0.
   * @param a a FixedPoint numerator.
   * @param b a uint256 denominator.
   * @return the quotient of `a` divided by `b`.
   */
  function divCeil(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {
    // Because it is possible that a quotient gets truncated, we can't just call "Unsigned(a.rawValue.div(b))"
    // similarly to mulCeil with a uint256 as the second parameter. Therefore we need to convert b into an Unsigned.
    // This creates the possibility of overflow if b is very large.
    return divCeil(a, fromUnscaledUint(b));
  }

  /**
   * @notice Raises an `Unsigned` to the power of an unscaled uint256, reverting on overflow. E.g., `b=2` squares `a`.
   * @dev This will "floor" the result.
   * @param a a FixedPoint numerator.
   * @param b a uint256 denominator.
   * @return output is `a` to the power of `b`.
   */
  function pow(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory output) {
    output = fromUnscaledUint(1);
    for (uint256 i = 0; i < b; i = i.add(1)) {
      output = mul(output, a);
    }
  }

  // ------------------------------------------------- SIGNED -------------------------------------------------------------
  // Supports 18 decimals. E.g., 1e18 represents "1", 5e17 represents "0.5".
  // For signed values:
  //   This can represent a value up (or down) to +-(2^255 - 1)/10^18 = ~10^58. 10^58 will be stored internally as int256 10^76.
  int256 private constant SFP_SCALING_FACTOR = 10 ** 18;

  struct Signed {
    int256 rawValue;
  }

  function fromSigned(Signed memory a) internal pure returns (Unsigned memory) {
    require(a.rawValue >= 0, "Negative value provided");
    return Unsigned(uint256(a.rawValue));
  }

  function fromUnsigned(Unsigned memory a) internal pure returns (Signed memory) {
    require(a.rawValue <= uint256(type(int256).max), "Unsigned too large");
    return Signed(int256(a.rawValue));
  }

  /**
   * @notice Constructs a `Signed` from an unscaled int, e.g., `b=5` gets stored internally as `5**18`.
   * @param a int to convert into a FixedPoint.Signed.
   * @return the converted FixedPoint.Signed.
   */
  function fromUnscaledInt(int256 a) internal pure returns (Signed memory) {
    return Signed(a.mul(SFP_SCALING_FACTOR));
  }

  /**
   * @notice Whether `a` is equal to `b`.
   * @param a a FixedPoint.Signed.
   * @param b a int256.
   * @return True if equal, or False.
   */
  function isEqual(Signed memory a, int256 b) internal pure returns (bool) {
    return a.rawValue == fromUnscaledInt(b).rawValue;
  }

  /**
   * @notice Whether `a` is equal to `b`.
   * @param a a FixedPoint.Signed.
   * @param b a FixedPoint.Signed.
   * @return True if equal, or False.
   */
  function isEqual(Signed memory a, Signed memory b) internal pure returns (bool) {
    return a.rawValue == b.rawValue;
  }

  /**
   * @notice Whether `a` is greater than `b`.
   * @param a a FixedPoint.Signed.
   * @param b a FixedPoint.Signed.
   * @return True if `a > b`, or False.
   */
  function isGreaterThan(Signed memory a, Signed memory b) internal pure returns (bool) {
    return a.rawValue > b.rawValue;
  }

  /**
   * @notice Whether `a` is greater than `b`.
   * @param a a FixedPoint.Signed.
   * @param b an int256.
   * @return True if `a > b`, or False.
   */
  function isGreaterThan(Signed memory a, int256 b) internal pure returns (bool) {
    return a.rawValue > fromUnscaledInt(b).rawValue;
  }

  /**
   * @notice Whether `a` is greater than `b`.
   * @param a an int256.
   * @param b a FixedPoint.Signed.
   * @return True if `a > b`, or False.
   */
  function isGreaterThan(int256 a, Signed memory b) internal pure returns (bool) {
    return fromUnscaledInt(a).rawValue > b.rawValue;
  }

  /**
   * @notice Whether `a` is greater than or equal to `b`.
   * @param a a FixedPoint.Signed.
   * @param b a FixedPoint.Signed.
   * @return True if `a >= b`, or False.
   */
  function isGreaterThanOrEqual(Signed memory a, Signed memory b) internal pure returns (bool) {
    return a.rawValue >= b.rawValue;
  }

  /**
   * @notice Whether `a` is greater than or equal to `b`.
   * @param a a FixedPoint.Signed.
   * @param b an int256.
   * @return True if `a >= b`, or False.
   */
  function isGreaterThanOrEqual(Signed memory a, int256 b) internal pure returns (bool) {
    return a.rawValue >= fromUnscaledInt(b).rawValue;
  }

  /**
   * @notice Whether `a` is greater than or equal to `b`.
   * @param a an int256.
   * @param b a FixedPoint.Signed.
   * @return True if `a >= b`, or False.
   */
  function isGreaterThanOrEqual(int256 a, Signed memory b) internal pure returns (bool) {
    return fromUnscaledInt(a).rawValue >= b.rawValue;
  }

  /**
   * @notice Whether `a` is less than `b`.
   * @param a a FixedPoint.Signed.
   * @param b a FixedPoint.Signed.
   * @return True if `a < b`, or False.
   */
  function isLessThan(Signed memory a, Signed memory b) internal pure returns (bool) {
    return a.rawValue < b.rawValue;
  }

  /**
   * @notice Whether `a` is less than `b`.
   * @param a a FixedPoint.Signed.
   * @param b an int256.
   * @return True if `a < b`, or False.
   */
  function isLessThan(Signed memory a, int256 b) internal pure returns (bool) {
    return a.rawValue < fromUnscaledInt(b).rawValue;
  }

  /**
   * @notice Whether `a` is less than `b`.
   * @param a an int256.
   * @param b a FixedPoint.Signed.
   * @return True if `a < b`, or False.
   */
  function isLessThan(int256 a, Signed memory b) internal pure returns (bool) {
    return fromUnscaledInt(a).rawValue < b.rawValue;
  }

  /**
   * @notice Whether `a` is less than or equal to `b`.
   * @param a a FixedPoint.Signed.
   * @param b a FixedPoint.Signed.
   * @return True if `a <= b`, or False.
   */
  function isLessThanOrEqual(Signed memory a, Signed memory b) internal pure returns (bool) {
    return a.rawValue <= b.rawValue;
  }

  /**
   * @notice Whether `a` is less than or equal to `b`.
   * @param a a FixedPoint.Signed.
   * @param b an int256.
   * @return True if `a <= b`, or False.
   */
  function isLessThanOrEqual(Signed memory a, int256 b) internal pure returns (bool) {
    return a.rawValue <= fromUnscaledInt(b).rawValue;
  }

  /**
   * @notice Whether `a` is less than or equal to `b`.
   * @param a an int256.
   * @param b a FixedPoint.Signed.
   * @return True if `a <= b`, or False.
   */
  function isLessThanOrEqual(int256 a, Signed memory b) internal pure returns (bool) {
    return fromUnscaledInt(a).rawValue <= b.rawValue;
  }

  /**
   * @notice The minimum of `a` and `b`.
   * @param a a FixedPoint.Signed.
   * @param b a FixedPoint.Signed.
   * @return the minimum of `a` and `b`.
   */
  function min(Signed memory a, Signed memory b) internal pure returns (Signed memory) {
    return a.rawValue < b.rawValue ? a : b;
  }

  /**
   * @notice The maximum of `a` and `b`.
   * @param a a FixedPoint.Signed.
   * @param b a FixedPoint.Signed.
   * @return the maximum of `a` and `b`.
   */
  function max(Signed memory a, Signed memory b) internal pure returns (Signed memory) {
    return a.rawValue > b.rawValue ? a : b;
  }

  /**
   * @notice Adds two `Signed`s, reverting on overflow.
   * @param a a FixedPoint.Signed.
   * @param b a FixedPoint.Signed.
   * @return the sum of `a` and `b`.
   */
  function add(Signed memory a, Signed memory b) internal pure returns (Signed memory) {
    return Signed(a.rawValue.add(b.rawValue));
  }

  /**
   * @notice Adds an `Signed` to an unscaled int, reverting on overflow.
   * @param a a FixedPoint.Signed.
   * @param b an int256.
   * @return the sum of `a` and `b`.
   */
  function add(Signed memory a, int256 b) internal pure returns (Signed memory) {
    return add(a, fromUnscaledInt(b));
  }

  /**
   * @notice Subtracts two `Signed`s, reverting on overflow.
   * @param a a FixedPoint.Signed.
   * @param b a FixedPoint.Signed.
   * @return the difference of `a` and `b`.
   */
  function sub(Signed memory a, Signed memory b) internal pure returns (Signed memory) {
    return Signed(a.rawValue.sub(b.rawValue));
  }

  /**
   * @notice Subtracts an unscaled int256 from an `Signed`, reverting on overflow.
   * @param a a FixedPoint.Signed.
   * @param b an int256.
   * @return the difference of `a` and `b`.
   */
  function sub(Signed memory a, int256 b) internal pure returns (Signed memory) {
    return sub(a, fromUnscaledInt(b));
  }

  /**
   * @notice Subtracts an `Signed` from an unscaled int256, reverting on overflow.
   * @param a an int256.
   * @param b a FixedPoint.Signed.
   * @return the difference of `a` and `b`.
   */
  function sub(int256 a, Signed memory b) internal pure returns (Signed memory) {
    return sub(fromUnscaledInt(a), b);
  }

  /**
   * @notice Multiplies two `Signed`s, reverting on overflow.
   * @dev This will "floor" the product.
   * @param a a FixedPoint.Signed.
   * @param b a FixedPoint.Signed.
   * @return the product of `a` and `b`.
   */
  function mul(Signed memory a, Signed memory b) internal pure returns (Signed memory) {
    // There are two caveats with this computation:
    // 1. Max output for the represented number is ~10^41, otherwise an intermediate value overflows. 10^41 is
    // stored internally as an int256 ~10^59.
    // 2. Results that can't be represented exactly are truncated not rounded. E.g., 1.4 * 2e-18 = 2.8e-18, which
    // would round to 3, but this computation produces the result 2.
    // No need to use SafeMath because SFP_SCALING_FACTOR != 0.
    return Signed(a.rawValue.mul(b.rawValue) / SFP_SCALING_FACTOR);
  }

  /**
   * @notice Multiplies an `Signed` and an unscaled int256, reverting on overflow.
   * @dev This will "floor" the product.
   * @param a a FixedPoint.Signed.
   * @param b an int256.
   * @return the product of `a` and `b`.
   */
  function mul(Signed memory a, int256 b) internal pure returns (Signed memory) {
    return Signed(a.rawValue.mul(b));
  }

  /**
   * @notice Multiplies two `Signed`s and "ceil's" the product, reverting on overflow.
   * @param a a FixedPoint.Signed.
   * @param b a FixedPoint.Signed.
   * @return the product of `a` and `b`.
   */
  function mulAwayFromZero(Signed memory a, Signed memory b) internal pure returns (Signed memory) {
    int256 mulRaw = a.rawValue.mul(b.rawValue);
    int256 mulTowardsZero = mulRaw / SFP_SCALING_FACTOR;
    // Manual mod because SignedSafeMath doesn't support it.
    int256 mod = mulRaw % SFP_SCALING_FACTOR;
    if (mod != 0) {
      bool isResultPositive = isLessThan(a, 0) == isLessThan(b, 0);
      int256 valueToAdd = isResultPositive ? int256(1) : int256(-1);
      return Signed(mulTowardsZero.add(valueToAdd));
    } else {
      return Signed(mulTowardsZero);
    }
  }

  /**
   * @notice Multiplies an `Signed` and an unscaled int256 and "ceil's" the product, reverting on overflow.
   * @param a a FixedPoint.Signed.
   * @param b a FixedPoint.Signed.
   * @return the product of `a` and `b`.
   */
  function mulAwayFromZero(Signed memory a, int256 b) internal pure returns (Signed memory) {
    // Since b is an int, there is no risk of truncation and we can just mul it normally
    return Signed(a.rawValue.mul(b));
  }

  /**
   * @notice Divides one `Signed` by an `Signed`, reverting on overflow or division by 0.
   * @dev This will "floor" the quotient.
   * @param a a FixedPoint numerator.
   * @param b a FixedPoint denominator.
   * @return the quotient of `a` divided by `b`.
   */
  function div(Signed memory a, Signed memory b) internal pure returns (Signed memory) {
    // There are two caveats with this computation:
    // 1. Max value for the number dividend `a` represents is ~10^41, otherwise an intermediate value overflows.
    // 10^41 is stored internally as an int256 10^59.
    // 2. Results that can't be represented exactly are truncated not rounded. E.g., 2 / 3 = 0.6 repeating, which
    // would round to 0.666666666666666667, but this computation produces the result 0.666666666666666666.
    return Signed(a.rawValue.mul(SFP_SCALING_FACTOR).div(b.rawValue));
  }

  /**
   * @notice Divides one `Signed` by an unscaled int256, reverting on overflow or division by 0.
   * @dev This will "floor" the quotient.
   * @param a a FixedPoint numerator.
   * @param b an int256 denominator.
   * @return the quotient of `a` divided by `b`.
   */
  function div(Signed memory a, int256 b) internal pure returns (Signed memory) {
    return Signed(a.rawValue.div(b));
  }

  /**
   * @notice Divides one unscaled int256 by an `Signed`, reverting on overflow or division by 0.
   * @dev This will "floor" the quotient.
   * @param a an int256 numerator.
   * @param b a FixedPoint denominator.
   * @return the quotient of `a` divided by `b`.
   */
  function div(int256 a, Signed memory b) internal pure returns (Signed memory) {
    return div(fromUnscaledInt(a), b);
  }

  /**
   * @notice Divides one `Signed` by an `Signed` and "ceil's" the quotient, reverting on overflow or division by 0.
   * @param a a FixedPoint numerator.
   * @param b a FixedPoint denominator.
   * @return the quotient of `a` divided by `b`.
   */
  function divAwayFromZero(Signed memory a, Signed memory b) internal pure returns (Signed memory) {
    int256 aScaled = a.rawValue.mul(SFP_SCALING_FACTOR);
    int256 divTowardsZero = aScaled.div(b.rawValue);
    // Manual mod because SignedSafeMath doesn't support it.
    int256 mod = aScaled % b.rawValue;
    if (mod != 0) {
      bool isResultPositive = isLessThan(a, 0) == isLessThan(b, 0);
      int256 valueToAdd = isResultPositive ? int256(1) : int256(-1);
      return Signed(divTowardsZero.add(valueToAdd));
    } else {
      return Signed(divTowardsZero);
    }
  }

  /**
   * @notice Divides one `Signed` by an unscaled int256 and "ceil's" the quotient, reverting on overflow or division by 0.
   * @param a a FixedPoint numerator.
   * @param b an int256 denominator.
   * @return the quotient of `a` divided by `b`.
   */
  function divAwayFromZero(Signed memory a, int256 b) internal pure returns (Signed memory) {
    // Because it is possible that a quotient gets truncated, we can't just call "Signed(a.rawValue.div(b))"
    // similarly to mulCeil with an int256 as the second parameter. Therefore we need to convert b into an Signed.
    // This creates the possibility of overflow if b is very large.
    return divAwayFromZero(a, fromUnscaledInt(b));
  }

  /**
   * @notice Raises an `Signed` to the power of an unscaled uint256, reverting on overflow. E.g., `b=2` squares `a`.
   * @dev This will "floor" the result.
   * @param a a FixedPoint.Signed.
   * @param b a uint256 (negative exponents are not allowed).
   * @return output is `a` to the power of `b`.
   */
  function pow(Signed memory a, uint256 b) internal pure returns (Signed memory output) {
    output = fromUnscaledInt(1);
    for (uint256 i = 0; i < b; i = i.add(1)) {
      output = mul(output, a);
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;

pragma experimental ABIEncoderV2;

import {ITranchedPool} from "./ITranchedPool.sol";

interface IBackerRewards {
  struct BackerRewardsTokenInfo {
    uint256 rewardsClaimed; // gfi claimed
    uint256 accRewardsPerPrincipalDollarAtMint; // Pool's accRewardsPerPrincipalDollar at PoolToken mint()
  }

  struct BackerRewardsInfo {
    uint256 accRewardsPerPrincipalDollar; // accumulator gfi per interest dollar
  }

  /// @notice Staking rewards parameters relevant to a TranchedPool
  struct StakingRewardsPoolInfo {
    // @notice the value `StakingRewards.accumulatedRewardsPerToken()` at the last checkpoint
    uint256 accumulatedRewardsPerTokenAtLastCheckpoint;
    // @notice last time the rewards info was updated
    //
    // we need this in order to know how much to pro rate rewards after the term is over.
    uint256 lastUpdateTime;
    // @notice staking rewards parameters for each slice of the tranched pool
    StakingRewardsSliceInfo[] slicesInfo;
  }

  /// @notice Staking rewards paramters relevant to a TranchedPool slice
  struct StakingRewardsSliceInfo {
    // @notice fidu share price when the slice is first drawn down
    //
    // we need to save this to calculate what an equivalent position in
    // the senior pool would be at the time the slice is downdown
    uint256 fiduSharePriceAtDrawdown;
    // @notice the amount of principal deployed at the last checkpoint
    //
    // we use this to calculate the amount of principal that should
    // acctually accrue rewards during between the last checkpoint and
    // and subsequent updates
    uint256 principalDeployedAtLastCheckpoint;
    // @notice the value of StakingRewards.accumulatedRewardsPerToken() at time of drawdown
    //
    // we need to keep track of this to use this as a base value to accumulate rewards
    // for tokens. If the token has never claimed staking rewards, we use this value
    // and the current staking rewards accumulator
    uint256 accumulatedRewardsPerTokenAtDrawdown;
    // @notice amount of rewards per token accumulated over the lifetime of the slice that a backer
    //          can claim
    uint256 accumulatedRewardsPerTokenAtLastCheckpoint;
    // @notice the amount of rewards per token accumulated over the lifetime of the slice
    //
    // this value is "unrealized" because backers will be unable to claim against this value.
    // we keep this value so that we can always accumulate rewards for the amount of capital
    // deployed at any point in time, but not allow backers to withdraw them until a payment
    // is made. For example: we want to accumulate rewards when a backer does a drawdown. but
    // a backer shouldn't be allowed to claim rewards until a payment is made.
    //
    // this value is scaled depending on the current proportion of capital currently deployed
    // in the slice. For example, if the staking rewards contract accrued 10 rewards per token
    // between the current checkpoint and a new update, and only 20% of the capital was deployed
    // during that period, we would accumulate 2 (10 * 20%) rewards.
    uint256 unrealizedAccumulatedRewardsPerTokenAtLastCheckpoint;
  }

  /// @notice Staking rewards parameters relevant to a PoolToken
  struct StakingRewardsTokenInfo {
    // @notice the amount of rewards accumulated the last time a token's rewards were withdrawn
    uint256 accumulatedRewardsPerTokenAtLastWithdraw;
  }

  /// @notice total amount of GFI rewards available, times 1e18
  function totalRewards() external view returns (uint256);

  /// @notice interest $ eligible for gfi rewards, times 1e18
  function maxInterestDollarsEligible() external view returns (uint256);

  /// @notice counter of total interest repayments, times 1e6
  function totalInterestReceived() external view returns (uint256);

  /// @notice totalRewards/totalGFISupply * 100, times 1e18
  function totalRewardPercentOfTotalGFI() external view returns (uint256);

  /// @notice Get backer rewards metadata for a pool token
  function getTokenInfo(uint256 poolTokenId) external view returns (BackerRewardsTokenInfo memory);

  /// @notice Get backer staking rewards metadata for a pool token
  function getStakingRewardsTokenInfo(
    uint256 poolTokenId
  ) external view returns (StakingRewardsTokenInfo memory);

  /// @notice Get backer staking rewards for a pool
  function getBackerStakingRewardsPoolInfo(
    ITranchedPool pool
  ) external view returns (StakingRewardsPoolInfo memory);

  /// @notice Calculates the accRewardsPerPrincipalDollar for a given pool,
  ///   when a interest payment is received by the protocol
  /// @param _interestPaymentAmount Atomic usdc amount of the interest payment
  function allocateRewards(uint256 _interestPaymentAmount) external;

  /// @notice callback for TranchedPools when they drawdown
  /// @param sliceIndex index of the tranched pool slice
  /// @dev initializes rewards info for the calling TranchedPool if it's the first
  ///  drawdown for the given slice
  function onTranchedPoolDrawdown(uint256 sliceIndex) external;

  /// @notice When a pool token is minted for multiple drawdowns,
  ///   set accRewardsPerPrincipalDollarAtMint to the current accRewardsPerPrincipalDollar price
  /// @param poolAddress Address of the pool associated with the pool token
  /// @param tokenId Pool token id
  function setPoolTokenAccRewardsPerPrincipalDollarAtMint(
    address poolAddress,
    uint256 tokenId
  ) external;

  /// @notice PoolToken request to withdraw all allocated rewards
  /// @param tokenId Pool token id
  /// @return amount of rewards withdrawn
  function withdraw(uint256 tokenId) external returns (uint256);

  /**
   * @notice Set BackerRewards and BackerStakingRewards metadata for tokens created by a pool token split.
   * @param originalBackerRewardsTokenInfo backer rewards info for the pool token that was split
   * @param originalStakingRewardsTokenInfo backer staking rewards info for the pool token that was split
   * @param newTokenId id of one of the tokens in the split
   * @param newRewardsClaimed rewardsClaimed value for the new token.
   */
  function setBackerAndStakingRewardsTokenInfoOnSplit(
    BackerRewardsTokenInfo memory originalBackerRewardsTokenInfo,
    StakingRewardsTokenInfo memory originalStakingRewardsTokenInfo,
    uint256 newTokenId,
    uint256 newRewardsClaimed
  ) external;

  /**
   * @notice Calculate the gross available gfi rewards for a PoolToken
   * @param tokenId Pool token id
   * @return The amount of GFI claimable
   */
  function poolTokenClaimableRewards(uint256 tokenId) external view returns (uint256);

  /// @notice Clear all BackerRewards and StakingRewards associated data for `tokenId`
  function clearTokenInfo(uint256 tokenId) external;
}

// SPDX-License-Identifier: MIT
// Taken from https://github.com/compound-finance/compound-protocol/blob/master/contracts/CTokenInterfaces.sol
pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;

import "./IERC20withDec.sol";

interface ICUSDCContract is IERC20withDec {
  /*** User Interface ***/

  function mint(uint256 mintAmount) external returns (uint256);

  function redeem(uint256 redeemTokens) external returns (uint256);

  function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

  function borrow(uint256 borrowAmount) external returns (uint256);

  function repayBorrow(uint256 repayAmount) external returns (uint256);

  function repayBorrowBehalf(address borrower, uint256 repayAmount) external returns (uint256);

  function liquidateBorrow(
    address borrower,
    uint256 repayAmount,
    address cTokenCollateral
  ) external returns (uint256);

  function getAccountSnapshot(
    address account
  ) external view returns (uint256, uint256, uint256, uint256);

  function balanceOfUnderlying(address owner) external returns (uint256);

  function exchangeRateCurrent() external returns (uint256);

  /*** Admin Functions ***/

  function _addReserves(uint256 addAmount) external returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;

import {ITranchedPool} from "./ITranchedPool.sol";
import {ICreditLine} from "./ICreditLine.sol";
import {ISchedule} from "./ISchedule.sol";

interface ICreditLine {
  function balance() external view returns (uint256);

  function interestOwed() external view returns (uint256);

  function principalOwed() external view returns (uint256);

  function termEndTime() external view returns (uint256);

  function nextDueTime() external view returns (uint256);

  function interestAccruedAsOf() external view returns (uint256);

  function lastFullPaymentTime() external view returns (uint256);

  function borrower() external view returns (address);

  function currentLimit() external view returns (uint256);

  function limit() external view returns (uint256);

  function maxLimit() external view returns (uint256);

  function interestApr() external view returns (uint256);

  function lateFeeApr() external view returns (uint256);

  function isLate() external view returns (bool);

  function withinPrincipalGracePeriod() external view returns (bool);

  /// @notice Cumulative interest accrued up to now
  function totalInterestAccrued() external view returns (uint256);

  /// @notice Cumulative interest accrued up to `timestamp`
  function totalInterestAccruedAt(uint256 timestamp) external view returns (uint256);

  /// @notice Cumulative interest paid back up to now
  function totalInterestPaid() external view returns (uint256);

  /// @notice Cumulative interest owed up to now
  function totalInterestOwed() external view returns (uint256);

  /// @notice Cumulative interest owed up to `timestamp`
  function totalInterestOwedAt(uint256 timestamp) external view returns (uint256);

  /// @notice Interest that would be owed at `timestamp`
  function interestOwedAt(uint256 timestamp) external view returns (uint256);

  /// @notice Interest accrued in the current payment period up to now. Converted to
  ///   owed interest once we cross into the next payment period. Is 0 if the
  ///   current time is after loan maturity (all interest accrued immediately becomes
  ///   interest owed).
  function interestAccrued() external view returns (uint256);

  /// @notice Interest accrued in the current payment period for `timestamp`. Coverted to
  ///   owed interest once we cross into the payment period after `timestamp`. Is 0
  ///   if `timestamp` is after loan maturity (all interest accrued immediately becomes
  ///   interest owed).
  function interestAccruedAt(uint256 timestamp) external view returns (uint256);

  /// @notice Principal owed up to `timestamp`
  function principalOwedAt(uint256 timestamp) external view returns (uint256);

  /// @notice Returns the total amount of principal thats been paid
  function totalPrincipalPaid() external view returns (uint256);

  /// @notice Cumulative principal owed at timestamp
  function totalPrincipalOwedAt(uint256 timestamp) external view returns (uint256);

  /// @notice Cumulative principal owed at current timestamp
  function totalPrincipalOwed() external view returns (uint256);

  function setLimit(uint256 newAmount) external;

  function setMaxLimit(uint256 newAmount) external;

  /// @notice Time of first drawdown
  function termStartTime() external view returns (uint256);

  /// @notice Initialize a brand new credit line
  function initialize(
    address _config,
    address owner,
    address _borrower,
    uint256 _limit,
    uint256 _interestApr,
    ISchedule _schedule,
    uint256 _lateFeeApr
  ) external;

  /// @notice Process a bulk payment, allocating the payment amount based on the payment waterfall
  function pay(uint paymentAmount) external returns (ITranchedPool.PaymentAllocation memory);

  /**
   * Process a payment according to the waterfall described in `Accountant.allocatePayment`
   * @param principalPayment principal payment amount
   * @param interestPayment interest payment amount
   * @return payment allocation
   */
  function pay(
    uint256 principalPayment,
    uint256 interestPayment
  ) external returns (ITranchedPool.PaymentAllocation memory);

  /// @notice Drawdown on the line
  /// @param amount amount to drawdown. Cannot exceed the line's limit
  function drawdown(uint256 amount) external;
}

// SPDX-License-Identifier: MIT
// Taken from https://github.com/compound-finance/compound-protocol/blob/master/contracts/CTokenInterfaces.sol
pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;

interface ICurveLP {
  function coins(uint256) external view returns (address);

  function token() external view returns (address);

  function calc_token_amount(uint256[2] calldata amounts) external view returns (uint256);

  function lp_price() external view returns (uint256);

  function add_liquidity(
    uint256[2] calldata amounts,
    uint256 min_mint_amount,
    bool use_eth,
    address receiver
  ) external returns (uint256);

  function remove_liquidity(
    uint256 _amount,
    uint256[2] calldata min_amounts
  ) external returns (uint256);

  function remove_liquidity_one_coin(
    uint256 token_amount,
    uint256 i,
    uint256 min_amount
  ) external returns (uint256);

  function get_dy(uint256 i, uint256 j, uint256 dx) external view returns (uint256);

  function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy) external returns (uint256);

  function balances(uint256 arg0) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;

import {IERC20} from "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";

/*
Only addition is the `decimals` function, which we need, and which both our Fidu and USDC use, along with most ERC20's.
*/

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20withDec is IERC20 {
  /**
   * @dev Returns the number of decimals used for the token
   */
  function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;

import "./IERC20withDec.sol";

interface IFidu is IERC20withDec {
  function mintTo(address to, uint256 amount) external;

  function burnFrom(address to, uint256 amount) external;

  function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;

abstract contract IGo {
  uint256 public constant ID_TYPE_0 = 0;
  uint256 public constant ID_TYPE_1 = 1;
  uint256 public constant ID_TYPE_2 = 2;
  uint256 public constant ID_TYPE_3 = 3;
  uint256 public constant ID_TYPE_4 = 4;
  uint256 public constant ID_TYPE_5 = 5;
  uint256 public constant ID_TYPE_6 = 6;
  uint256 public constant ID_TYPE_7 = 7;
  uint256 public constant ID_TYPE_8 = 8;
  uint256 public constant ID_TYPE_9 = 9;
  uint256 public constant ID_TYPE_10 = 10;

  /// @notice Returns the address of the UniqueIdentity contract.
  function uniqueIdentity() external virtual returns (address);

  function go(address account) public view virtual returns (bool);

  function goOnlyIdTypes(
    address account,
    uint256[] calldata onlyIdTypes
  ) public view virtual returns (bool);

  /**
   * @notice Returns whether the provided account is go-listed for use of the SeniorPool on the Goldfinch protocol.
   * @param account The account whose go status to obtain
   * @return true if `account` is go listed
   */
  function goSeniorPool(address account) public view virtual returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;

interface IGoldfinchConfig {
  function getNumber(uint256 index) external returns (uint256);

  function getAddress(uint256 index) external returns (address);

  function setAddress(uint256 index, address newAddress) external returns (address);

  function setNumber(uint256 index, uint256 newNumber) external returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;

interface IGoldfinchFactory {
  function createCreditLine() external returns (address);

  function createBorrower(address owner) external returns (address);

  function createPool(
    address _borrower,
    uint256 _juniorFeePercent,
    uint256 _limit,
    uint256 _interestApr,
    uint256 _paymentPeriodInDays,
    uint256 _termInDays,
    uint256 _lateFeeApr,
    uint256[] calldata _allowedUIDTypes
  ) external returns (address);

  function createMigratedPool(
    address _borrower,
    uint256 _juniorFeePercent,
    uint256 _limit,
    uint256 _interestApr,
    uint256 _paymentPeriodInDays,
    uint256 _termInDays,
    uint256 _lateFeeApr,
    uint256[] calldata _allowedUIDTypes
  ) external returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;

import "./openzeppelin/IERC721.sol";

interface IPoolTokens is IERC721 {
  struct TokenInfo {
    address pool;
    uint256 tranche;
    uint256 principalAmount;
    uint256 principalRedeemed;
    uint256 interestRedeemed;
  }

  struct MintParams {
    uint256 principalAmount;
    uint256 tranche;
  }

  struct PoolInfo {
    uint256 totalMinted;
    uint256 totalPrincipalRedeemed;
    bool created;
  }

  /**
   * @notice Called by pool to create a debt position in a particular tranche and amount
   * @param params Struct containing the tranche and the amount
   * @param to The address that should own the position
   * @return tokenId The token ID (auto-incrementing integer across all pools)
   */
  function mint(MintParams calldata params, address to) external returns (uint256);

  /**
   * @notice Redeem principal and interest on a pool token. Called by valid pools as part of their redemption
   *  flow
   * @param tokenId pool token id
   * @param principalRedeemed principal to redeem. This cannot exceed the token's principal amount, and
   *  the redemption cannot cause the pool's total principal redeemed to exceed the pool's total minted
   *  principal
   * @param interestRedeemed interest to redeem.
   */
  function redeem(uint256 tokenId, uint256 principalRedeemed, uint256 interestRedeemed) external;

  /**
   * @notice Withdraw a pool token's principal up to the token's principalAmount. Called by valid pools
   *  as part of their withdraw flow before the pool is locked (i.e. before the principal is committed)
   * @param tokenId pool token id
   * @param principalAmount principal to withdraw
   */
  function withdrawPrincipal(uint256 tokenId, uint256 principalAmount) external;

  /**
   * @notice Burns a specific ERC721 token and removes deletes the token metadata for PoolTokens, BackerReards,
   *  and BackerStakingRewards
   * @param tokenId uint256 id of the ERC721 token to be burned.
   */
  function burn(uint256 tokenId) external;

  /**
   * @notice Called by the GoldfinchFactory to register the pool as a valid pool. Only valid pools can mint/redeem
   * tokens
   * @param newPool The address of the newly created pool
   */
  function onPoolCreated(address newPool) external;

  function getTokenInfo(uint256 tokenId) external view returns (TokenInfo memory);

  function getPoolInfo(address pool) external view returns (PoolInfo memory);

  /// @notice Query if `pool` is a valid pool. A pool is valid if it was created by the Goldfinch Factory
  function validPool(address pool) external view returns (bool);

  function isApprovedOrOwner(address spender, uint256 tokenId) external view returns (bool);

  /**
   * @notice Splits a pool token into two smaller positions. The original token is burned and all
   * its associated data is deleted.
   * @param tokenId id of the token to split.
   * @param newPrincipal1 principal amount for the first token in the split. The principal amount for the
   *  second token in the split is implicitly the original token's principal amount less newPrincipal1
   * @return tokenId1 id of the first token in the split
   * @return tokenId2 id of the second token in the split
   */
  function splitToken(
    uint256 tokenId,
    uint256 newPrincipal1
  ) external returns (uint256 tokenId1, uint256 tokenId2);

  /**
   * @notice Mint event emitted for a new TranchedPool deposit or when an existing pool token is
   *  split
   * @param owner address to which the token was minted
   * @param pool tranched pool that the deposit was in
   * @param tokenId ERC721 tokenId
   * @param amount the deposit amount
   * @param tranche id of the tranche of the deposit
   */
  event TokenMinted(
    address indexed owner,
    address indexed pool,
    uint256 indexed tokenId,
    uint256 amount,
    uint256 tranche
  );

  /**
   * @notice Redeem event emitted when interest and/or principal is redeemed in the token's pool
   * @param owner owner of the pool token
   * @param pool tranched pool that the token belongs to
   * @param principalRedeemed amount of principal redeemed from the pool
   * @param interestRedeemed amount of interest redeemed from the pool
   * @param tranche id of the tranche the token belongs to
   */
  event TokenRedeemed(
    address indexed owner,
    address indexed pool,
    uint256 indexed tokenId,
    uint256 principalRedeemed,
    uint256 interestRedeemed,
    uint256 tranche
  );

  /**
   * @notice Burn event emitted when the token owner/operator manually burns the token or burns
   *  it implicitly by splitting it
   * @param owner owner of the pool token
   * @param pool tranched pool that the token belongs to
   */
  event TokenBurned(address indexed owner, address indexed pool, uint256 indexed tokenId);

  /**
   * @notice Split event emitted when the token owner/operator splits the token
   * @param pool tranched pool to which the orginal and split tokens belong
   * @param tokenId id of the original token that was split
   * @param newTokenId1 id of the first split token
   * @param newPrincipal1 principalAmount of the first split token
   * @param newTokenId2 id of the second split token
   * @param newPrincipal2 principalAmount of the second split token
   */
  event TokenSplit(
    address indexed owner,
    address indexed pool,
    uint256 indexed tokenId,
    uint256 newTokenId1,
    uint256 newPrincipal1,
    uint256 newTokenId2,
    uint256 newPrincipal2
  );

  /**
   * @notice Principal Withdrawn event emitted when a token's principal is withdrawn from the pool
   *  BEFORE the pool's drawdown period
   * @param pool tranched pool of the token
   * @param principalWithdrawn amount of principal withdrawn from the pool
   */
  event TokenPrincipalWithdrawn(
    address indexed owner,
    address indexed pool,
    uint256 indexed tokenId,
    uint256 principalWithdrawn,
    uint256 tranche
  );
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;

interface IRequiresUID {
  function hasAllowedUID(address sender) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;

interface ISchedule {
  /**
   * @notice Returns the period that timestamp resides in
   */
  function periodAt(uint256 startTime, uint256 timestamp) external view returns (uint256);

  /**
   * @notice Returns the principal period that timestamp resides in
   */
  function principalPeriodAt(uint256 startTime, uint256 timestamp) external view returns (uint256);

  /**
   * @notice Returns the interest period that timestamp resides in
   */
  function interestPeriodAt(uint256 startTime, uint256 timestamp) external view returns (uint256);

  /**
   * @notice Returns true if the given timestamp resides in a principal grace period
   */
  function withinPrincipalGracePeriodAt(
    uint256 startTime,
    uint256 timestamp
  ) external view returns (bool);

  /**
   * Returns the next timestamp where either principal or interest will come due following `timestamp`
   */
  function nextDueTimeAt(uint256 startTime, uint256 timestamp) external view returns (uint256);

  /**
   * @notice Returns the previous timestamp where either principal or timestamp came due
   */
  function previousDueTimeAt(uint256 startTime, uint256 timestamp) external view returns (uint256);

  /**
   * @notice Returns the previous timestamp where new interest came due
   */
  function previousInterestDueTimeAt(
    uint256 startTime,
    uint256 timestamp
  ) external view returns (uint256);

  /**
   * @notice Returns the previous timestamp where new principal came due
   */
  function previousPrincipalDueTimeAt(
    uint256 startTime,
    uint256 timestamp
  ) external view returns (uint256);

  /**
   * @notice Returns the total number of principal periods
   */
  function totalPrincipalPeriods() external view returns (uint256);

  /**
   * @notice Returns the total number of interest periods
   */
  function totalInterestPeriods() external view returns (uint256);

  /**
   * @notice Returns the timestamp that the term will end
   */
  function termEndTime(uint256 startTime) external view returns (uint256);

  /**
   * @notice Returns the timestamp that the term began
   */
  function termStartTime(uint256 startTime) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;

import {ITranchedPool} from "./ITranchedPool.sol";
import {ISeniorPoolEpochWithdrawals} from "./ISeniorPoolEpochWithdrawals.sol";

abstract contract ISeniorPool is ISeniorPoolEpochWithdrawals {
  uint256 public sharePrice;
  uint256 public totalLoansOutstanding;
  uint256 public totalWritedowns;

  function deposit(uint256 amount) external virtual returns (uint256 depositShares);

  function depositWithPermit(
    uint256 amount,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external virtual returns (uint256 depositShares);

  /**
   * @notice Withdraw `usdcAmount` of USDC, bypassing the epoch withdrawal system. Callable
   * by Zapper only.
   */
  function withdraw(uint256 usdcAmount) external virtual returns (uint256 amount);

  /**
   * @notice Withdraw `fiduAmount` of FIDU converted to USDC at the current share price,
   * bypassing the epoch withdrawal system. Callable by Zapper only
   */
  function withdrawInFidu(uint256 fiduAmount) external virtual returns (uint256 amount);

  function invest(ITranchedPool pool) external virtual returns (uint256);

  function estimateInvestment(ITranchedPool pool) external view virtual returns (uint256);

  function redeem(uint256 tokenId) external virtual;

  function writedown(uint256 tokenId) external virtual;

  function calculateWritedown(
    uint256 tokenId
  ) external view virtual returns (uint256 writedownAmount);

  function sharesOutstanding() external view virtual returns (uint256);

  function assets() external view virtual returns (uint256);

  function getNumShares(uint256 amount) public view virtual returns (uint256);

  event DepositMade(address indexed capitalProvider, uint256 amount, uint256 shares);
  event WithdrawalMade(address indexed capitalProvider, uint256 userAmount, uint256 reserveAmount);
  event InterestCollected(address indexed payer, uint256 amount);
  event PrincipalCollected(address indexed payer, uint256 amount);
  event ReserveFundsCollected(address indexed user, uint256 amount);
  event ReserveSharesCollected(address indexed user, address indexed reserve, uint256 amount);

  event PrincipalWrittenDown(address indexed tranchedPool, int256 amount);
  event InvestmentMadeInSenior(address indexed tranchedPool, uint256 amount);
  event InvestmentMadeInJunior(address indexed tranchedPool, uint256 amount);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;

pragma experimental ABIEncoderV2;

interface ISeniorPoolEpochWithdrawals {
  /**
   * @notice A withdrawal epoch
   * @param endsAt timestamp the epoch ends
   * @param fiduRequested amount of fidu requested in the epoch, including fidu
   *                      carried over from previous epochs
   * @param fiduLiquidated Amount of fidu that was liquidated at the end of this epoch
   * @param usdcAllocated Amount of usdc that was allocated to liquidate fidu.
   *                      Does not consider withdrawal fees.
   */
  struct Epoch {
    uint256 endsAt;
    uint256 fiduRequested;
    uint256 fiduLiquidated;
    uint256 usdcAllocated;
  }

  /**
   * @notice A user's request for withdrawal
   * @param epochCursor id of next epoch the user can liquidate their request
   * @param fiduRequested amount of fidu left to liquidate since last checkpoint
   * @param usdcWithdrawable amount of usdc available for a user to withdraw
   */
  struct WithdrawalRequest {
    uint256 epochCursor;
    uint256 usdcWithdrawable;
    uint256 fiduRequested;
  }

  /**
   * @notice Returns the amount of unallocated usdc in the senior pool, taking into account
   *         usdc that _will_ be allocated to withdrawals when a checkpoint happens
   */
  function usdcAvailable() external view returns (uint256);

  /// @notice Current duration of withdrawal epochs, in seconds
  function epochDuration() external view returns (uint256);

  /// @notice Update epoch duration
  function setEpochDuration(uint256 newEpochDuration) external;

  /// @notice The current withdrawal epoch
  function currentEpoch() external view returns (Epoch memory);

  /// @notice Get request by tokenId. A request is considered active if epochCursor > 0.
  function withdrawalRequest(uint256 tokenId) external view returns (WithdrawalRequest memory);

  /**
   * @notice Submit a request to withdraw `fiduAmount` of FIDU. Request is rejected
   * if caller already owns a request token. A non-transferrable request token is
   * minted to the caller
   * @return tokenId token minted to caller
   */
  function requestWithdrawal(uint256 fiduAmount) external returns (uint256 tokenId);

  /**
   * @notice Add `fiduAmount` FIDU to a withdrawal request for `tokenId`. Caller
   * must own tokenId
   */
  function addToWithdrawalRequest(uint256 fiduAmount, uint256 tokenId) external;

  /**
   * @notice Cancel request for tokenId. The fiduRequested (minus a fee) is returned
   * to the caller. Caller must own tokenId.
   * @return fiduReceived the fidu amount returned to the caller
   */
  function cancelWithdrawalRequest(uint256 tokenId) external returns (uint256 fiduReceived);

  /**
   * @notice Transfer the usdcWithdrawable of request for tokenId to the caller.
   * Caller must own tokenId
   */
  function claimWithdrawalRequest(uint256 tokenId) external returns (uint256 usdcReceived);

  /// @notice Emitted when the epoch duration is changed
  event EpochDurationChanged(uint256 newDuration);

  /// @notice Emitted when a new withdraw request has been created
  event WithdrawalRequested(
    uint256 indexed epochId,
    uint256 indexed tokenId,
    address indexed operator,
    uint256 fiduRequested
  );

  /// @notice Emitted when a user adds to their existing withdraw request
  /// @param epochId epoch that the withdraw was added to
  /// @param tokenId id of token that represents the position being added to
  /// @param operator address that added to the request
  /// @param fiduRequested amount of additional fidu added to request
  event WithdrawalAddedTo(
    uint256 indexed epochId,
    uint256 indexed tokenId,
    address indexed operator,
    uint256 fiduRequested
  );

  /// @notice Emitted when a withdraw request has been canceled
  event WithdrawalCanceled(
    uint256 indexed epochId,
    uint256 indexed tokenId,
    address indexed operator,
    uint256 fiduCanceled,
    uint256 reserveFidu
  );

  /// @notice Emitted when an epoch has been checkpointed
  /// @param epochId id of epoch that ended
  /// @param endTime timestamp the epoch ended
  /// @param fiduRequested amount of FIDU oustanding when the epoch ended
  /// @param usdcAllocated amount of USDC allocated to liquidate FIDU
  /// @param fiduLiquidated amount of FIDU liquidated using `usdcAllocated`
  event EpochEnded(
    uint256 indexed epochId,
    uint256 endTime,
    uint256 fiduRequested,
    uint256 usdcAllocated,
    uint256 fiduLiquidated
  );

  /// @notice Emitted when an epoch could not be finalized and is extended instead
  /// @param epochId id of epoch that was extended
  /// @param newEndTime new epoch end time
  /// @param oldEndTime previous epoch end time
  event EpochExtended(uint256 indexed epochId, uint256 newEndTime, uint256 oldEndTime);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;

import "./ISeniorPool.sol";
import "./ITranchedPool.sol";

abstract contract ISeniorPoolStrategy {
  function getLeverageRatio(ITranchedPool pool) public view virtual returns (uint256);

  /**
   * @notice Determines how much money to invest in the senior tranche based on what is committed to the junior
   * tranche, what is committed to the senior tranche, and a leverage ratio to the junior tranche. Because
   * it takes into account what is already committed to the senior tranche, the value returned by this
   * function can be used "idempotently" to achieve the investment target amount without exceeding that target.
   * @param seniorPool The senior pool to invest from
   * @param pool The tranched pool to invest into (as the senior)
   * @return amount of money to invest into the tranched pool's senior tranche, from the senior pool
   */
  function invest(
    ISeniorPool seniorPool,
    ITranchedPool pool
  ) public view virtual returns (uint256 amount);

  /**
   * @notice A companion of `invest()`: determines how much would be returned by `invest()`, as the
   * value to invest into the senior tranche, if the junior tranche were locked and the senior tranche
   * were not locked.
   * @param seniorPool The senior pool to invest from
   * @param pool The tranched pool to invest into (as the senior)
   * @return The amount of money to invest into the tranched pool's senior tranche, from the senior pool
   */
  function estimateInvestment(
    ISeniorPool seniorPool,
    ITranchedPool pool
  ) public view virtual returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;

pragma experimental ABIEncoderV2;

import {IERC721} from "./openzeppelin/IERC721.sol";
import {IERC721Metadata} from "./openzeppelin/IERC721Metadata.sol";
import {IERC721Enumerable} from "./openzeppelin/IERC721Enumerable.sol";

interface IStakingRewards is IERC721, IERC721Metadata, IERC721Enumerable {
  /// @notice Get the staking rewards position
  /// @param tokenId id of the position token
  /// @return position the position
  function getPosition(uint256 tokenId) external view returns (StakedPosition memory position);

  /// @notice Unstake an amount of `stakingToken()` (FIDU, FiduUSDCCurveLP, etc) associated with
  ///   a given position and transfer to msg.sender. Any remaining staked amount will continue to
  ///   accrue rewards.
  /// @dev This function checkpoints rewards
  /// @param tokenId A staking position token ID
  /// @param amount Amount of `stakingToken()` to be unstaked from the position
  function unstake(uint256 tokenId, uint256 amount) external;

  /// @notice Add `amount` to an existing FIDU position (`tokenId`)
  /// @param tokenId A staking position token ID
  /// @param amount Amount of `stakingToken()` to be added to tokenId's position
  function addToStake(uint256 tokenId, uint256 amount) external;

  /// @notice Returns the staked balance of a given position token.
  /// @dev The value returned is the bare amount, not the effective amount. The bare amount represents
  ///   the number of tokens the user has staked for a given position. The effective amount is the bare
  ///   amount multiplied by the token's underlying asset type multiplier. This multiplier is a crypto-
  ///   economic parameter determined by governance.
  /// @param tokenId A staking position token ID
  /// @return Amount of staked tokens denominated in `stakingToken().decimals()`
  function stakedBalanceOf(uint256 tokenId) external view returns (uint256);

  /// @notice Deposit to FIDU and USDC into the Curve LP, and stake your Curve LP tokens in the same transaction.
  /// @param fiduAmount The amount of FIDU to deposit
  /// @param usdcAmount The amount of USDC to deposit
  function depositToCurveAndStakeFrom(
    address nftRecipient,
    uint256 fiduAmount,
    uint256 usdcAmount
  ) external;

  /// @notice "Kick" a user's reward multiplier. If they are past their lock-up period, their reward
  ///   multiplier will be reset to 1x.
  /// @dev This will also checkpoint their rewards up to the current time.
  function kick(uint256 tokenId) external;

  /// @notice Accumulated rewards per token at the last checkpoint
  function accumulatedRewardsPerToken() external view returns (uint256);

  /// @notice The block timestamp when rewards were last checkpointed
  function lastUpdateTime() external view returns (uint256);

  /// @notice Claim rewards for a given staked position
  /// @param tokenId A staking position token ID
  /// @return amount of rewards claimed
  function getReward(uint256 tokenId) external returns (uint256);

  /* ========== EVENTS ========== */

  event RewardAdded(uint256 reward);
  event Staked(
    address indexed user,
    uint256 indexed tokenId,
    uint256 amount,
    StakedPositionType positionType,
    uint256 baseTokenExchangeRate
  );
  event DepositedAndStaked(
    address indexed user,
    uint256 depositedAmount,
    uint256 indexed tokenId,
    uint256 amount
  );
  event DepositedToCurve(
    address indexed user,
    uint256 fiduAmount,
    uint256 usdcAmount,
    uint256 tokensReceived
  );
  event DepositedToCurveAndStaked(
    address indexed user,
    uint256 fiduAmount,
    uint256 usdcAmount,
    uint256 indexed tokenId,
    uint256 amount
  );
  event AddToStake(
    address indexed user,
    uint256 indexed tokenId,
    uint256 amount,
    StakedPositionType positionType
  );
  event Unstaked(
    address indexed user,
    uint256 indexed tokenId,
    uint256 amount,
    StakedPositionType positionType
  );
  event UnstakedMultiple(address indexed user, uint256[] tokenIds, uint256[] amounts);
  event RewardPaid(address indexed user, uint256 indexed tokenId, uint256 reward);
  event RewardsParametersUpdated(
    address indexed who,
    uint256 targetCapacity,
    uint256 minRate,
    uint256 maxRate,
    uint256 minRateAtPercent,
    uint256 maxRateAtPercent
  );
  event EffectiveMultiplierUpdated(
    address indexed who,
    StakedPositionType positionType,
    uint256 multiplier
  );
}

/// @notice Indicates which ERC20 is staked
enum StakedPositionType {
  Fidu,
  CurveLP
}

struct Rewards {
  uint256 totalUnvested;
  uint256 totalVested;
  // @dev DEPRECATED (definition kept for storage slot)
  //   For legacy vesting positions, this was used in the case of slashing.
  //   For non-vesting positions, this is unused.
  uint256 totalPreviouslyVested;
  uint256 totalClaimed;
  uint256 startTime;
  // @dev DEPRECATED (definition kept for storage slot)
  //   For legacy vesting positions, this is the endTime of the vesting.
  //   For non-vesting positions, this is 0.
  uint256 endTime;
}

struct StakedPosition {
  // @notice Staked amount denominated in `stakingToken().decimals()`
  uint256 amount;
  // @notice Struct describing rewards owed with vesting
  Rewards rewards;
  // @notice Multiplier applied to staked amount when locking up position
  uint256 leverageMultiplier;
  // @notice Time in seconds after which position can be unstaked
  uint256 lockedUntil;
  // @notice Type of the staked position
  StakedPositionType positionType;
  // @notice Multiplier applied to staked amount to denominate in `baseStakingToken().decimals()`
  // @dev This field should not be used directly; it may be 0 for staked positions created prior to GIP-1.
  //  If you need this field, use `safeEffectiveMultiplier()`, which correctly handles old staked positions.
  uint256 unsafeEffectiveMultiplier;
  // @notice Exchange rate applied to staked amount to denominate in `baseStakingToken().decimals()`
  // @dev This field should not be used directly; it may be 0 for staked positions created prior to GIP-1.
  //  If you need this field, use `safeBaseTokenExchangeRate()`, which correctly handles old staked positions.
  uint256 unsafeBaseTokenExchangeRate;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;
import {ISchedule} from "./ISchedule.sol";
import {ITranchedPool} from "./ITranchedPool.sol";
import {ICreditLine} from "./ICreditLine.sol";

interface ITranchedPool {
  struct TrancheInfo {
    uint256 id;
    uint256 principalDeposited;
    uint256 principalSharePrice;
    uint256 interestSharePrice;
    uint256 lockedUntil;
  }
  struct PoolSlice {
    TrancheInfo seniorTranche;
    TrancheInfo juniorTranche;
    uint256 totalInterestAccrued;
    uint256 principalDeployed;
  }
  enum Tranches {
    Reserved,
    Senior,
    Junior
  }

  /// @notice Pool's credit line, responsible for managing the loan's accounting variables
  function creditLine() external view returns (ICreditLine);

  /// @notice Time when the pool was initialized. Zero if uninitialized
  function createdAt() external view returns (uint256);

  /// @notice Initialize the pool. Can only be called once, and should be called in the same transaction as
  ///   contract creation to avoid initialization front-running
  /// @param _config address of GoldfinchConfig
  /// @param _borrower address of borrower, a non-transferrable role for performing privileged actions like
  ///   drawdown
  /// @param _juniorFeePercent percent (whole number) of senior interest that gets re-allocated to the junior tranche.
  ///   valid range is [0, 100]
  /// @param _limit the max USDC amount that can be drawn down across all pool slices
  /// @param _interestApr interest rate for the loan
  /// @param _lateFeeApr late fee interest rate for the loan, which kicks in `LatenessGracePeriodInDays` days after a
  ///   payment becomes late
  /// @param _fundableAt earliest time at which the first slice can be funded
  function initialize(
    address _config,
    address _borrower,
    uint256 _juniorFeePercent,
    uint256 _limit,
    uint256 _interestApr,
    ISchedule _schedule,
    uint256 _lateFeeApr,
    uint256 _fundableAt,
    uint256[] calldata _allowedUIDTypes
  ) external;

  /// @notice TrancheInfo for tranche with id `trancheId`. The senior tranche of slice i has id 2*(i-1)+1. The
  ///   junior tranche of slice i has id 2*i. Slice indices start at 1.
  /// @param trancheId id of tranche. Valid ids are in the range [1, 2*numSlices]
  function getTranche(uint256 trancheId) external view returns (ITranchedPool.TrancheInfo memory);

  /**
   * @notice Get the array of all UID types that are allowed to interact with this pool.
   * @return array of UID types
   *
   * @dev This only exists on TranchedPools deployed from Nov 2022 onward
   */
  function getAllowedUIDTypes() external view virtual returns (uint256[] memory);

  /// @notice Pay down the credit line. Excess payments are refunded to the caller
  /// @param amount USDC amount to pay
  /// @return PaymentAllocation info on how the payment was allocated
  /// @dev {this} must be approved by msg.sender to transfer {amount} of USDC
  function pay(uint256 amount) external returns (PaymentAllocation memory);

  /// @notice Pay down the credit line, separating the principal and interest payments. You must pay back all interest
  ///   before paying back principal. Excess payments are refunded to the caller
  /// @param principalPayment USDC amount to pay down principal
  /// @param interestPayment USDC amount to pay down interest
  /// @return PaymentAllocation info on how the payment was allocated
  /// @dev {this} must be approved by msg.sender to transfer {principalPayment} + {interestPayment} of USDC
  function pay(
    uint256 principalPayment,
    uint256 interestPayment
  ) external returns (PaymentAllocation memory);

  /// @notice Compute interest and principal owed on the current balance at a future timestamp
  /// @param timestamp time to calculate up to
  /// @return interestOwed amount of obligated interest owed at `timestamp`
  /// @return interestAccrued amount of accrued interest (not yet owed) that can be paid at `timestamp`
  /// @return principalOwed amount of principal owed at `timestamp`
  function getAmountsOwed(
    uint256 timestamp
  ) external view returns (uint256 interestOwed, uint256 interestAccrued, uint256 principalOwed);

  /// @notice Get a slice by index
  /// @param index of slice. Valid indices are on the interval [0, numSlices - 1]
  function poolSlices(uint256 index) external view returns (ITranchedPool.PoolSlice memory);

  /// @notice Lock the junior capital in the junior tranche of the current slice. The capital is locked for
  ///   `DrawdownPeriodInSeconds` seconds and gives the senior pool time to decide how much to invest (ensure
  ///   leverage ratio cannot change for the period). During this period the borrower has the option to lock
  ///   the senior capital by calling `lockPool()`. Backers may withdraw their junior capital if the the senior
  ///   tranche has not been locked and the drawdown period has ended. Only the borrower can call this function.
  function lockJuniorCapital() external;

  /// @notice Lock the senior capital in the senior tranche of the current slice and reset the lock period of
  ///   the junior capital to match the senior capital lock period. During this period the borrower has the
  ///   option to draw down the pool. Beyond the drawdown period any unused capital is available to withdraw by
  ///   all depositors.
  function lockPool() external;

  /// @notice Initialize the next slice for the pool. Enables backers and the senior pool to provide additional
  ///   capital to the borrower.
  /// @param _fundableAt time at which the new slice (now the current slice) becomes fundable
  function initializeNextSlice(uint256 _fundableAt) external;

  /// @notice Query the total capital supplied to the pool's junior tranches
  function totalJuniorDeposits() external view returns (uint256);

  /// @notice Drawdown the loan. The credit line's balance should increase by the amount drawn down.
  ///   Junior capital must be locked before this function can be called. If senior capital isn't locked
  ///   then this function will lock it for you (convenience to avoid calling lockPool() separately).
  ///   This function should revert if the amount requested exceeds the the current slice's currentLimit
  ///   This function should revert if the caller is not the borrower.
  /// @param amount USDC to drawdown. This amount is transferred to the caller
  function drawdown(uint256 amount) external;

  /// @notice Update `fundableAt` to a new timestamp. Only the borrower can call this.
  function setFundableAt(uint256 newFundableAt) external;

  /// @notice Supply capital to this pool. Caller can't deposit to the junior tranche if the junior pool is locked.
  ///   Caller can't deposit to a senior tranche if the pool is locked. Caller can't deposit if they are missing the
  ///   required UID NFT.
  /// @param tranche id of tranche to supply capital to. Id must correspond to a tranche in the current slice.
  /// @param amount amount of capital to supply
  /// @return tokenId NFT representing your position in this pool
  function deposit(uint256 tranche, uint256 amount) external returns (uint256 tokenId);

  function depositWithPermit(
    uint256 tranche,
    uint256 amount,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 tokenId);

  /// @notice Query the max amount available to withdraw for tokenId's position
  /// @param tokenId position to query max amount withdrawable for
  /// @return interestRedeemable total interest withdrawable on the position
  /// @return principalRedeemable total principal redeemable on the position
  function availableToWithdraw(
    uint256 tokenId
  ) external view returns (uint256 interestRedeemable, uint256 principalRedeemable);

  /// @notice Withdraw an already deposited amount if the funds are available. Caller must be the owner or
  ///   approved by the owner on tokenId. Amount withdrawn is sent to the caller.
  /// @param tokenId the NFT representing the position
  /// @param amount amount to withdraw (must be <= interest+principal available to withdraw)
  /// @return interestWithdrawn interest withdrawn
  /// @return principalWithdrawn principal withdrawn
  function withdraw(
    uint256 tokenId,
    uint256 amount
  ) external returns (uint256 interestWithdrawn, uint256 principalWithdrawn);

  /// @notice Similar to withdraw but withdraw the max interest and principal available for `tokenId`
  function withdrawMax(
    uint256 tokenId
  ) external returns (uint256 interestWithdrawn, uint256 principalWithdrawn);

  /// @notice Withdraw from multiple tokens
  /// @param tokenIds NFT positions to withdraw. Caller must be an owner or approved on all tokens in the array
  /// @param amounts amounts to withdraw from positions such that amounts[i] is withdrawn from position tokenIds[i]
  function withdrawMultiple(uint256[] calldata tokenIds, uint256[] calldata amounts) external;

  function assess() external;

  /// @notice Get the current number of slices for this pool
  /// @return numSlices total current slice count
  function numSlices() external view returns (uint256);

  /// @notice Result of applying a payment to a v2 pool
  /// @param owedInterestPayment payment portion of interest owed
  /// @param accruedInterestPayment payment portion of accrued (but not yet owed) interest
  /// @param principalPayment payment portion on principal owed
  /// @param additionalBalancePayment payment portion on any balance that is currently owed
  /// @param paymentRemaining payment amount leftover
  struct PaymentAllocation {
    uint256 owedInterestPayment;
    uint256 accruedInterestPayment;
    uint256 principalPayment;
    uint256 additionalBalancePayment;
    uint256 paymentRemaining;
  }
  /// @notice Event emitted on payment
  /// @param payer address that made the payment
  /// @param pool pool to which the payment was made
  /// @param interest amount of payment allocated to interest (obligated + additional)
  /// @param principal amount of payment allocated to principal owed and remaining balance
  /// @param remaining any excess payment amount that wasn't allocated to a debt owed
  /// @param reserve of payment that went to the protocol reserve
  event PaymentApplied(
    address indexed payer,
    address indexed pool,
    uint256 interest,
    uint256 principal,
    uint256 remaining,
    uint256 reserve
  );
  // Note: This has to exactly match the event in the TranchingLogic library for events to be emitted
  // correctly
  event SharePriceUpdated(
    address indexed pool,
    uint256 indexed tranche,
    uint256 principalSharePrice,
    int256 principalDelta,
    uint256 interestSharePrice,
    int256 interestDelta
  );
  event DepositMade(
    address indexed owner,
    uint256 indexed tranche,
    uint256 indexed tokenId,
    uint256 amount
  );
  event WithdrawalMade(
    address indexed owner,
    uint256 indexed tranche,
    uint256 indexed tokenId,
    uint256 interestWithdrawn,
    uint256 principalWithdrawn
  );
  event ReserveFundsCollected(address indexed from, uint256 amount);
  event CreditLineMigrated(ICreditLine indexed oldCreditLine, ICreditLine indexed newCreditLine);
  event DrawdownMade(address indexed borrower, uint256 amount);
  event DrawdownsPaused(address indexed pool);
  event DrawdownsUnpaused(address indexed pool);
  event EmergencyShutdown(address indexed pool);
  event TrancheLocked(address indexed pool, uint256 trancheId, uint256 lockedUntil);
  event SliceCreated(address indexed pool, uint256 sliceId);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;

/// @title interface for implementers that have an arbitrary associated tag
interface IVersioned {
  /// @notice Returns the version triplet `[major, minor, patch]`
  function getVersion() external pure returns (uint8[3] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {IERC721Enumerable} from "./openzeppelin/IERC721Enumerable.sol";

interface IWithdrawalRequestToken is IERC721Enumerable {
  /// @notice Mint a withdrawal request token to `receiver`
  /// @dev succeeds if and only if called by senior pool
  function mint(address receiver) external returns (uint256 tokenId);

  /// @notice Burn token `tokenId`
  /// @dev suceeds if and only if called by senior pool
  function burn(uint256 tokenId) external;
}

pragma solidity >=0.6.0;

// This file copied from OZ, but with the version pragma updated to use >=.

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

pragma solidity >=0.6.2;

// This file copied from OZ, but with the version pragma updated to use >= & reference other >= pragma interfaces.
// NOTE: Modified to reference our updated pragma version of IERC165
import "./IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

  /**
   * @dev Returns the number of NFTs in ``owner``'s account.
   */
  function balanceOf(address owner) external view returns (uint256 balance);

  /**
   * @dev Returns the owner of the NFT specified by `tokenId`.
   */
  function ownerOf(uint256 tokenId) external view returns (address owner);

  /**
   * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
   * another (`to`).
   *
   *
   *
   * Requirements:
   * - `from`, `to` cannot be zero.
   * - `tokenId` must be owned by `from`.
   * - If the caller is not `from`, it must be have been allowed to move this
   * NFT by either {approve} or {setApprovalForAll}.
   */
  function safeTransferFrom(address from, address to, uint256 tokenId) external;

  /**
   * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
   * another (`to`).
   *
   * Requirements:
   * - If the caller is not `from`, it must be approved to move this NFT by
   * either {approve} or {setApprovalForAll}.
   */
  function transferFrom(address from, address to, uint256 tokenId) external;

  function approve(address to, uint256 tokenId) external;

  function getApproved(uint256 tokenId) external view returns (address operator);

  function setApprovalForAll(address operator, bool _approved) external;

  function isApprovedForAll(address owner, address operator) external view returns (bool);

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes calldata data
  ) external;
}

pragma solidity >=0.6.2;

// This file copied from OZ, but with the version pragma updated to use >=.

import "./IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
  function totalSupply() external view returns (uint256);

  function tokenOfOwnerByIndex(
    address owner,
    uint256 index
  ) external view returns (uint256 tokenId);

  function tokenByIndex(uint256 index) external view returns (uint256);
}

pragma solidity >=0.6.2;

// This file copied from OZ, but with the version pragma updated to use >=.

import "./IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";

/**
 * @title Safe ERC20 Transfer
 * @notice Reverts when transfer is not successful
 * @author Goldfinch
 */
library SafeERC20Transfer {
  function safeERC20Transfer(
    IERC20 erc20,
    address to,
    uint256 amount,
    string memory message
  ) internal {
    /// @dev ZERO address
    require(to != address(0), "ZERO");
    bool success = erc20.transfer(to, amount);
    require(success, message);
  }

  function safeERC20Transfer(IERC20 erc20, address to, uint256 amount) internal {
    safeERC20Transfer(erc20, to, amount, "");
  }

  function safeERC20TransferFrom(
    IERC20 erc20,
    address from,
    address to,
    uint256 amount,
    string memory message
  ) internal {
    require(to != address(0), "ZERO");
    bool success = erc20.transferFrom(from, to, amount);
    require(success, message);
  }

  function safeERC20TransferFrom(IERC20 erc20, address from, address to, uint256 amount) internal {
    safeERC20TransferFrom(erc20, from, to, amount, "");
  }

  function safeERC20Approve(
    IERC20 erc20,
    address spender,
    uint256 allowance,
    string memory message
  ) internal {
    bool success = erc20.approve(spender, allowance);
    require(success, message);
  }

  function safeERC20Approve(IERC20 erc20, address spender, uint256 allowance) internal {
    safeERC20Approve(erc20, spender, allowance, "");
  }
}

pragma solidity >=0.6.12;

// NOTE: this file exists only to remove the extremely long error messages in safe math.

import {SafeMath as OzSafeMath} from "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return OzSafeMath.sub(a, b, "");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    return OzSafeMath.sub(a, b, errorMessage);
  }

  /// @notice Do a - b. If that would result in overflow then return 0
  function saturatingSub(uint256 a, uint256 b) internal pure returns (uint256) {
    return b > a ? 0 : a - b;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return OzSafeMath.div(a, b, "");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    return OzSafeMath.div(a, b, errorMessage);
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return OzSafeMath.mod(a, b, "");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    return OzSafeMath.mod(a, b, errorMessage);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {AccessControlUpgradeSafe} from "@openzeppelin/contracts-ethereum-package/contracts/access/AccessControl.sol";
import {ReentrancyGuardUpgradeSafe} from "@openzeppelin/contracts-ethereum-package/contracts/utils/ReentrancyGuard.sol";
import {Initializable} from "@openzeppelin/contracts-ethereum-package/contracts/Initializable.sol";
import {SafeMath} from "../../library/SafeMath.sol";
import {PauserPausable} from "./PauserPausable.sol";

/**
 * @title BaseUpgradeablePausable contract
 * @notice This is our Base contract that most other contracts inherit from. It includes many standard
 *  useful abilities like upgradeability, pausability, access control, and re-entrancy guards.
 * @author Goldfinch
 */

contract BaseUpgradeablePausable is
  Initializable,
  AccessControlUpgradeSafe,
  PauserPausable,
  ReentrancyGuardUpgradeSafe
{
  bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
  using SafeMath for uint256;
  // Pre-reserving a few slots in the base contract in case we need to add things in the future.
  // This does not actually take up gas cost or storage cost, but it does reserve the storage slots.
  // See OpenZeppelin's use of this pattern here:
  // https://github.com/OpenZeppelin/openzeppelin-contracts-ethereum-package/blob/master/contracts/GSN/Context.sol#L37
  uint256[50] private __gap1;
  uint256[50] private __gap2;
  uint256[50] private __gap3;
  uint256[50] private __gap4;

  // solhint-disable-next-line func-name-mixedcase
  function __BaseUpgradeablePausable__init(address owner) public initializer {
    require(owner != address(0), "Owner cannot be the zero address");
    __AccessControl_init_unchained();
    __Pausable_init_unchained();
    __ReentrancyGuard_init_unchained();

    _setupRole(OWNER_ROLE, owner);
    _setupRole(PAUSER_ROLE, owner);

    _setRoleAdmin(PAUSER_ROLE, OWNER_ROLE);
    _setRoleAdmin(OWNER_ROLE, OWNER_ROLE);
  }

  function isAdmin() public view returns (bool) {
    return hasRole(OWNER_ROLE, _msgSender());
  }

  modifier onlyAdmin() {
    require(isAdmin(), "Must have admin role to perform this action");
    _;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {ImplementationRepository} from "./proxy/ImplementationRepository.sol";
import {ConfigOptions} from "./ConfigOptions.sol";
import {GoldfinchConfig} from "./GoldfinchConfig.sol";
import {IFidu} from "../../interfaces/IFidu.sol";
import {IWithdrawalRequestToken} from "../../interfaces/IWithdrawalRequestToken.sol";
import {ISeniorPool} from "../../interfaces/ISeniorPool.sol";
import {ISeniorPoolStrategy} from "../../interfaces/ISeniorPoolStrategy.sol";
import {IERC20withDec} from "../../interfaces/IERC20withDec.sol";
import {ICUSDCContract} from "../../interfaces/ICUSDCContract.sol";
import {IPoolTokens} from "../../interfaces/IPoolTokens.sol";
import {IBackerRewards} from "../../interfaces/IBackerRewards.sol";
import {IGoldfinchFactory} from "../../interfaces/IGoldfinchFactory.sol";
import {IGo} from "../../interfaces/IGo.sol";
import {IStakingRewards} from "../../interfaces/IStakingRewards.sol";
import {ICurveLP} from "../../interfaces/ICurveLP.sol";

/**
 * @title ConfigHelper
 * @notice A convenience library for getting easy access to other contracts and constants within the
 *  protocol, through the use of the GoldfinchConfig contract
 * @author Goldfinch
 */

library ConfigHelper {
  function getSeniorPool(GoldfinchConfig config) internal view returns (ISeniorPool) {
    return ISeniorPool(seniorPoolAddress(config));
  }

  function getSeniorPoolStrategy(
    GoldfinchConfig config
  ) internal view returns (ISeniorPoolStrategy) {
    return ISeniorPoolStrategy(seniorPoolStrategyAddress(config));
  }

  function getUSDC(GoldfinchConfig config) internal view returns (IERC20withDec) {
    return IERC20withDec(usdcAddress(config));
  }

  function getFidu(GoldfinchConfig config) internal view returns (IFidu) {
    return IFidu(fiduAddress(config));
  }

  function getFiduUSDCCurveLP(GoldfinchConfig config) internal view returns (ICurveLP) {
    return ICurveLP(fiduUSDCCurveLPAddress(config));
  }

  function getCUSDCContract(GoldfinchConfig config) internal view returns (ICUSDCContract) {
    return ICUSDCContract(cusdcContractAddress(config));
  }

  function getPoolTokens(GoldfinchConfig config) internal view returns (IPoolTokens) {
    return IPoolTokens(poolTokensAddress(config));
  }

  function getBackerRewards(GoldfinchConfig config) internal view returns (IBackerRewards) {
    return IBackerRewards(backerRewardsAddress(config));
  }

  function getGoldfinchFactory(GoldfinchConfig config) internal view returns (IGoldfinchFactory) {
    return IGoldfinchFactory(goldfinchFactoryAddress(config));
  }

  function getGFI(GoldfinchConfig config) internal view returns (IERC20withDec) {
    return IERC20withDec(gfiAddress(config));
  }

  function getGo(GoldfinchConfig config) internal view returns (IGo) {
    return IGo(goAddress(config));
  }

  function getStakingRewards(GoldfinchConfig config) internal view returns (IStakingRewards) {
    return IStakingRewards(stakingRewardsAddress(config));
  }

  function getTranchedPoolImplementationRepository(
    GoldfinchConfig config
  ) internal view returns (ImplementationRepository) {
    return
      ImplementationRepository(
        config.getAddress(uint256(ConfigOptions.Addresses.TranchedPoolImplementationRepository))
      );
  }

  function getWithdrawalRequestToken(
    GoldfinchConfig config
  ) internal view returns (IWithdrawalRequestToken) {
    return
      IWithdrawalRequestToken(
        config.getAddress(uint256(ConfigOptions.Addresses.WithdrawalRequestToken))
      );
  }

  function oneInchAddress(GoldfinchConfig config) internal view returns (address) {
    return config.getAddress(uint256(ConfigOptions.Addresses.OneInch));
  }

  function creditLineImplementationAddress(GoldfinchConfig config) internal view returns (address) {
    return config.getAddress(uint256(ConfigOptions.Addresses.CreditLineImplementation));
  }

  /// @dev deprecated because we no longer use GSN
  function trustedForwarderAddress(GoldfinchConfig config) internal view returns (address) {
    return config.getAddress(uint256(ConfigOptions.Addresses.TrustedForwarder));
  }

  function configAddress(GoldfinchConfig config) internal view returns (address) {
    return config.getAddress(uint256(ConfigOptions.Addresses.GoldfinchConfig));
  }

  function poolTokensAddress(GoldfinchConfig config) internal view returns (address) {
    return config.getAddress(uint256(ConfigOptions.Addresses.PoolTokens));
  }

  function backerRewardsAddress(GoldfinchConfig config) internal view returns (address) {
    return config.getAddress(uint256(ConfigOptions.Addresses.BackerRewards));
  }

  function seniorPoolAddress(GoldfinchConfig config) internal view returns (address) {
    return config.getAddress(uint256(ConfigOptions.Addresses.SeniorPool));
  }

  function seniorPoolStrategyAddress(GoldfinchConfig config) internal view returns (address) {
    return config.getAddress(uint256(ConfigOptions.Addresses.SeniorPoolStrategy));
  }

  function goldfinchFactoryAddress(GoldfinchConfig config) internal view returns (address) {
    return config.getAddress(uint256(ConfigOptions.Addresses.GoldfinchFactory));
  }

  function gfiAddress(GoldfinchConfig config) internal view returns (address) {
    return config.getAddress(uint256(ConfigOptions.Addresses.GFI));
  }

  function fiduAddress(GoldfinchConfig config) internal view returns (address) {
    return config.getAddress(uint256(ConfigOptions.Addresses.Fidu));
  }

  function fiduUSDCCurveLPAddress(GoldfinchConfig config) internal view returns (address) {
    return config.getAddress(uint256(ConfigOptions.Addresses.FiduUSDCCurveLP));
  }

  function cusdcContractAddress(GoldfinchConfig config) internal view returns (address) {
    return config.getAddress(uint256(ConfigOptions.Addresses.CUSDCContract));
  }

  function usdcAddress(GoldfinchConfig config) internal view returns (address) {
    return config.getAddress(uint256(ConfigOptions.Addresses.USDC));
  }

  function tranchedPoolAddress(GoldfinchConfig config) internal view returns (address) {
    return config.getAddress(uint256(ConfigOptions.Addresses.TranchedPoolImplementation));
  }

  function reserveAddress(GoldfinchConfig config) internal view returns (address) {
    return config.getAddress(uint256(ConfigOptions.Addresses.TreasuryReserve));
  }

  function protocolAdminAddress(GoldfinchConfig config) internal view returns (address) {
    return config.getAddress(uint256(ConfigOptions.Addresses.ProtocolAdmin));
  }

  function borrowerImplementationAddress(GoldfinchConfig config) internal view returns (address) {
    return config.getAddress(uint256(ConfigOptions.Addresses.BorrowerImplementation));
  }

  function goAddress(GoldfinchConfig config) internal view returns (address) {
    return config.getAddress(uint256(ConfigOptions.Addresses.Go));
  }

  function stakingRewardsAddress(GoldfinchConfig config) internal view returns (address) {
    return config.getAddress(uint256(ConfigOptions.Addresses.StakingRewards));
  }

  function getReserveDenominator(GoldfinchConfig config) internal view returns (uint256) {
    return config.getNumber(uint256(ConfigOptions.Numbers.ReserveDenominator));
  }

  function getWithdrawFeeDenominator(GoldfinchConfig config) internal view returns (uint256) {
    return config.getNumber(uint256(ConfigOptions.Numbers.WithdrawFeeDenominator));
  }

  function getLatenessGracePeriodInDays(GoldfinchConfig config) internal view returns (uint256) {
    return config.getNumber(uint256(ConfigOptions.Numbers.LatenessGracePeriodInDays));
  }

  function getLatenessMaxDays(GoldfinchConfig config) internal view returns (uint256) {
    return config.getNumber(uint256(ConfigOptions.Numbers.LatenessMaxDays));
  }

  function getDrawdownPeriodInSeconds(GoldfinchConfig config) internal view returns (uint256) {
    return config.getNumber(uint256(ConfigOptions.Numbers.DrawdownPeriodInSeconds));
  }

  function getTransferRestrictionPeriodInDays(
    GoldfinchConfig config
  ) internal view returns (uint256) {
    return config.getNumber(uint256(ConfigOptions.Numbers.TransferRestrictionPeriodInDays));
  }

  function getLeverageRatio(GoldfinchConfig config) internal view returns (uint256) {
    return config.getNumber(uint256(ConfigOptions.Numbers.LeverageRatio));
  }

  function getSeniorPoolWithdrawalCancelationFeeInBps(
    GoldfinchConfig config
  ) internal view returns (uint256) {
    return config.getNumber(uint256(ConfigOptions.Numbers.SeniorPoolWithdrawalCancelationFeeInBps));
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

/**
 * @title ConfigOptions
 * @notice A central place for enumerating the configurable options of our GoldfinchConfig contract
 * @author Goldfinch
 */

library ConfigOptions {
  // NEVER EVER CHANGE THE ORDER OF THESE!
  // You can rename or append. But NEVER change the order.
  enum Numbers {
    TransactionLimit,
    /// @dev: TotalFundsLimit used to represent a total cap on senior pool deposits
    /// but is now deprecated
    TotalFundsLimit,
    MaxUnderwriterLimit,
    ReserveDenominator,
    WithdrawFeeDenominator,
    LatenessGracePeriodInDays,
    LatenessMaxDays,
    DrawdownPeriodInSeconds,
    TransferRestrictionPeriodInDays,
    LeverageRatio,
    /// A number in the range [0, 10000] representing basis points of FIDU taken as a fee
    /// when a withdrawal request is canceled.
    SeniorPoolWithdrawalCancelationFeeInBps
  }
  /// @dev TrustedForwarder is deprecated because we no longer use GSN. CreditDesk
  ///   and Pool are deprecated because they are no longer used in the protocol.
  enum Addresses {
    Pool, // deprecated
    CreditLineImplementation,
    GoldfinchFactory,
    CreditDesk, // deprecated
    Fidu,
    USDC,
    TreasuryReserve,
    ProtocolAdmin,
    OneInch,
    TrustedForwarder, // deprecated
    CUSDCContract,
    GoldfinchConfig,
    PoolTokens,
    TranchedPoolImplementation, // deprecated
    SeniorPool,
    SeniorPoolStrategy,
    MigratedTranchedPoolImplementation,
    BorrowerImplementation,
    GFI,
    Go,
    BackerRewards,
    StakingRewards,
    FiduUSDCCurveLP,
    TranchedPoolImplementationRepository,
    WithdrawalRequestToken,
    MonthlyScheduleRepo
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {BaseUpgradeablePausable} from "./BaseUpgradeablePausable.sol";
import {IGoldfinchConfig} from "../../interfaces/IGoldfinchConfig.sol";
import {ConfigOptions} from "./ConfigOptions.sol";

/**
 * @title GoldfinchConfig
 * @notice This contract stores mappings of useful "protocol config state", giving a central place
 *  for all other contracts to access it. For example, the TransactionLimit, or the PoolAddress. These config vars
 *  are enumerated in the `ConfigOptions` library, and can only be changed by admins of the protocol.
 *  Note: While this inherits from BaseUpgradeablePausable, it is not deployed as an upgradeable contract (this
 *    is mostly to save gas costs of having each call go through a proxy)
 * @author Goldfinch
 */

contract GoldfinchConfig is BaseUpgradeablePausable {
  bytes32 public constant GO_LISTER_ROLE = keccak256("GO_LISTER_ROLE");

  mapping(uint256 => address) public addresses;
  mapping(uint256 => uint256) public numbers;
  mapping(address => bool) public goList;

  event AddressUpdated(address owner, uint256 index, address oldValue, address newValue);
  event NumberUpdated(address owner, uint256 index, uint256 oldValue, uint256 newValue);

  event GoListed(address indexed member);
  event NoListed(address indexed member);

  bool public valuesInitialized;

  function initialize(address owner) public initializer {
    require(owner != address(0), "Owner address cannot be empty");

    __BaseUpgradeablePausable__init(owner);

    _setupRole(GO_LISTER_ROLE, owner);

    _setRoleAdmin(GO_LISTER_ROLE, OWNER_ROLE);
  }

  function setAddress(uint256 addressIndex, address newAddress) public onlyAdmin {
    require(addresses[addressIndex] == address(0), "Address has already been initialized");

    emit AddressUpdated(msg.sender, addressIndex, addresses[addressIndex], newAddress);
    addresses[addressIndex] = newAddress;
  }

  function setNumber(uint256 index, uint256 newNumber) public onlyAdmin {
    emit NumberUpdated(msg.sender, index, numbers[index], newNumber);
    numbers[index] = newNumber;
  }

  function setTreasuryReserve(address newTreasuryReserve) public onlyAdmin {
    uint256 key = uint256(ConfigOptions.Addresses.TreasuryReserve);
    emit AddressUpdated(msg.sender, key, addresses[key], newTreasuryReserve);
    addresses[key] = newTreasuryReserve;
  }

  function setSeniorPoolStrategy(address newStrategy) public onlyAdmin {
    uint256 key = uint256(ConfigOptions.Addresses.SeniorPoolStrategy);
    emit AddressUpdated(msg.sender, key, addresses[key], newStrategy);
    addresses[key] = newStrategy;
  }

  function setCreditLineImplementation(address newAddress) public onlyAdmin {
    uint256 key = uint256(ConfigOptions.Addresses.CreditLineImplementation);
    emit AddressUpdated(msg.sender, key, addresses[key], newAddress);
    addresses[key] = newAddress;
  }

  function setTranchedPoolImplementation(address newAddress) public onlyAdmin {
    uint256 key = uint256(ConfigOptions.Addresses.TranchedPoolImplementation);
    emit AddressUpdated(msg.sender, key, addresses[key], newAddress);
    addresses[key] = newAddress;
  }

  function setBorrowerImplementation(address newAddress) public onlyAdmin {
    uint256 key = uint256(ConfigOptions.Addresses.BorrowerImplementation);
    emit AddressUpdated(msg.sender, key, addresses[key], newAddress);
    addresses[key] = newAddress;
  }

  function setGoldfinchConfig(address newAddress) public onlyAdmin {
    uint256 key = uint256(ConfigOptions.Addresses.GoldfinchConfig);
    emit AddressUpdated(msg.sender, key, addresses[key], newAddress);
    addresses[key] = newAddress;
  }

  function initializeFromOtherConfig(
    address _initialConfig,
    uint256 numbersLength,
    uint256 addressesLength
  ) public onlyAdmin {
    require(!valuesInitialized, "Already initialized values");
    IGoldfinchConfig initialConfig = IGoldfinchConfig(_initialConfig);
    for (uint256 i = 0; i < numbersLength; i++) {
      setNumber(i, initialConfig.getNumber(i));
    }

    for (uint256 i = 0; i < addressesLength; i++) {
      if (getAddress(i) == address(0)) {
        setAddress(i, initialConfig.getAddress(i));
      }
    }
    valuesInitialized = true;
  }

  /**
   * @dev Adds a user to go-list
   * @param _member address to add to go-list
   */
  function addToGoList(address _member) public onlyGoListerRole {
    goList[_member] = true;
    emit GoListed(_member);
  }

  /**
   * @dev removes a user from go-list
   * @param _member address to remove from go-list
   */
  function removeFromGoList(address _member) public onlyGoListerRole {
    goList[_member] = false;
    emit NoListed(_member);
  }

  /**
   * @dev adds many users to go-list at once
   * @param _members addresses to ad to go-list
   */
  function bulkAddToGoList(address[] calldata _members) external onlyGoListerRole {
    for (uint256 i = 0; i < _members.length; i++) {
      addToGoList(_members[i]);
    }
  }

  /**
   * @dev removes many users from go-list at once
   * @param _members addresses to remove from go-list
   */
  function bulkRemoveFromGoList(address[] calldata _members) external onlyGoListerRole {
    for (uint256 i = 0; i < _members.length; i++) {
      removeFromGoList(_members[i]);
    }
  }

  /*
    Using custom getters in case we want to change underlying implementation later,
    or add checks or validations later on.
  */
  function getAddress(uint256 index) public view returns (address) {
    return addresses[index];
  }

  function getNumber(uint256 index) public view returns (uint256) {
    return numbers[index];
  }

  modifier onlyGoListerRole() {
    require(
      hasRole(GO_LISTER_ROLE, _msgSender()),
      "Must have go-lister role to perform this action"
    );
    _;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-ethereum-package/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/access/AccessControl.sol";

/**
 * @title PauserPausable
 * @notice Inheriting from OpenZeppelin's Pausable contract, this does small
 *  augmentations to make it work with a PAUSER_ROLE, leveraging the AccessControl contract.
 *  It is meant to be inherited.
 * @author Goldfinch
 */

contract PauserPausable is AccessControlUpgradeSafe, PausableUpgradeSafe {
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

  // solhint-disable-next-line func-name-mixedcase
  function __PauserPausable__init() public initializer {
    __Pausable_init_unchained();
  }

  /**
   * @dev Pauses all functions guarded by Pause
   *
   * See {Pausable-_pause}.
   *
   * Requirements:
   *
   * - the caller must have the PAUSER_ROLE.
   */

  function pause() public onlyPauserRole {
    _pause();
  }

  /**
   * @dev Unpauses the contract
   *
   * See {Pausable-_unpause}.
   *
   * Requirements:
   *
   * - the caller must have the Pauser role
   */
  function unpause() public onlyPauserRole {
    _unpause();
  }

  modifier onlyPauserRole() {
    /// @dev NA: not authorized
    require(hasRole(PAUSER_ROLE, _msgSender()), "NA");
    _;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {IERC20Permit} from "@openzeppelin/contracts/drafts/IERC20Permit.sol";
import {Math} from "@openzeppelin/contracts-ethereum-package/contracts/math/Math.sol";
import {SafeMath} from "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import {ITranchedPool} from "../../interfaces/ITranchedPool.sol";
import {ITranchedPool} from "../../interfaces/ITranchedPool.sol";
import {IRequiresUID} from "../../interfaces/IRequiresUID.sol";
import {IERC20withDec} from "../../interfaces/IERC20withDec.sol";
import {ICreditLine} from "../../interfaces/ICreditLine.sol";
import {IBackerRewards} from "../../interfaces/IBackerRewards.sol";
import {IPoolTokens} from "../../interfaces/IPoolTokens.sol";
import {IVersioned} from "../../interfaces/IVersioned.sol";
import {ISchedule} from "../../interfaces/ISchedule.sol";
import {GoldfinchConfig} from "./GoldfinchConfig.sol";
import {BaseUpgradeablePausable} from "./BaseUpgradeablePausable.sol";
import {ConfigHelper} from "./ConfigHelper.sol";
import {SafeERC20Transfer} from "../../library/SafeERC20Transfer.sol";
import {TranchingLogic} from "./TranchingLogic.sol";

/// @title The main contract to faciliate lending. Backers and the Senior Pool fund the loan
///   through this contract. The borrower draws down on and pays back a loan through this contract.
/// @author Warbler Labs
contract TranchedPool is BaseUpgradeablePausable, ITranchedPool, IRequiresUID, IVersioned {
  GoldfinchConfig public config;

  using ConfigHelper for GoldfinchConfig;
  using TranchingLogic for ITranchedPool.PoolSlice;
  using TranchingLogic for ITranchedPool.TrancheInfo;
  using SafeERC20Transfer for IERC20withDec;

  bytes32 public constant LOCKER_ROLE = keccak256("LOCKER_ROLE");
  bytes32 public constant SENIOR_ROLE = keccak256("SENIOR_ROLE");
  uint8 internal constant MAJOR_VERSION = 1;
  uint8 internal constant MINOR_VERSION = 0;
  uint8 internal constant PATCH_VERSION = 0;

  ICreditLine public override creditLine;
  uint256 public override createdAt;
  uint256 public juniorFeePercent;
  bool public drawdownsPaused;
  uint256[] public allowedUIDTypes;
  uint256 public totalDeployed;
  uint256 public fundableAt;

  mapping(uint256 => ITranchedPool.PoolSlice) internal _poolSlices;

  /// @inheritdoc ITranchedPool
  uint256 public override numSlices;

  /// @inheritdoc ITranchedPool
  function initialize(
    address _config,
    address _borrower,
    uint256 _juniorFeePercent,
    uint256 _limit,
    uint256 _interestApr,
    ISchedule _schedule,
    uint256 _lateFeeApr,
    uint256 _fundableAt,
    uint256[] calldata _allowedUIDTypes
  ) public override initializer {
    require(address(_config) != address(0) && address(_borrower) != address(0), "ZERO");
    require(_juniorFeePercent <= 100, "JF");

    config = GoldfinchConfig(_config);
    address owner = config.protocolAdminAddress();
    __BaseUpgradeablePausable__init(owner);
    _initializeNextSlice(_fundableAt);
    _createAndSetCreditLine(_borrower, _limit, _interestApr, _schedule, _lateFeeApr);

    createdAt = block.timestamp;
    juniorFeePercent = _juniorFeePercent;
    if (_allowedUIDTypes.length == 0) {
      uint256[1] memory defaultAllowedUIDTypes = [config.getGo().ID_TYPE_0()];
      allowedUIDTypes = defaultAllowedUIDTypes;
    } else {
      allowedUIDTypes = _allowedUIDTypes;
    }

    _setupRole(LOCKER_ROLE, _borrower);
    _setupRole(LOCKER_ROLE, owner);
    _setRoleAdmin(LOCKER_ROLE, OWNER_ROLE);
    _setRoleAdmin(SENIOR_ROLE, OWNER_ROLE);

    // Give the senior pool the ability to deposit into the senior pool
    _setupRole(SENIOR_ROLE, address(config.getSeniorPool()));
  }

  function setAllowedUIDTypes(uint256[] calldata ids) external onlyLocker {
    require(
      _poolSlices[0].juniorTranche.principalDeposited == 0 &&
        _poolSlices[0].seniorTranche.principalDeposited == 0,
      "has balance"
    );
    allowedUIDTypes = ids;
  }

  function getAllowedUIDTypes() external view override returns (uint256[] memory) {
    return allowedUIDTypes;
  }

  /// @notice Intentionable no-op. Included to be compatible with the v1 pool interface
  // solhint-disable-next-line no-empty-blocks
  function assess() external override whenNotPaused {}

  /// @inheritdoc ITranchedPool
  /// @dev TL: tranche locked
  /// @dev IA: invalid amount
  /// @dev NA: not authorized. Must have correct UID or be go listed
  function deposit(
    uint256 tranche,
    uint256 amount
  ) public override nonReentrant whenNotPaused returns (uint256) {
    ITranchedPool.TrancheInfo storage trancheInfo = _getTrancheInfo(tranche);
    require(trancheInfo.lockedUntil == 0, "TL");
    require(amount > 0, "IA");
    require(hasAllowedUID(msg.sender), "NA");
    require(block.timestamp >= fundableAt, "Not open");
    // senior tranche ids are always odd numbered
    if (TranchingLogic.isSeniorTrancheId(trancheInfo.id)) {
      require(hasRole(SENIOR_ROLE, _msgSender()), "NA");
    }

    trancheInfo.principalDeposited = trancheInfo.principalDeposited.add(amount);
    uint256 tokenId = config.getPoolTokens().mint(
      IPoolTokens.MintParams({tranche: tranche, principalAmount: amount}),
      msg.sender
    );

    config.getUSDC().safeERC20TransferFrom(msg.sender, address(this), amount);
    emit DepositMade(msg.sender, tranche, tokenId, amount);
    return tokenId;
  }

  function depositWithPermit(
    uint256 tranche,
    uint256 amount,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public override whenNotPaused returns (uint256 tokenId) {
    IERC20Permit(config.usdcAddress()).permit(msg.sender, address(this), amount, deadline, v, r, s);
    return deposit(tranche, amount);
  }

  /// @inheritdoc ITranchedPool
  function withdraw(
    uint256 tokenId,
    uint256 amount
  ) public override nonReentrant whenNotPaused returns (uint256, uint256) {
    IPoolTokens.TokenInfo memory tokenInfo = config.getPoolTokens().getTokenInfo(tokenId);
    ITranchedPool.TrancheInfo storage trancheInfo = _getTrancheInfo(tokenInfo.tranche);

    return _withdraw(trancheInfo, tokenInfo, tokenId, amount);
  }

  /// @inheritdoc ITranchedPool
  /// @dev LEN: argument length mismatch
  function withdrawMultiple(
    uint256[] calldata tokenIds,
    uint256[] calldata amounts
  ) public override {
    require(tokenIds.length == amounts.length, "LEN");

    for (uint256 i = 0; i < amounts.length; i++) {
      withdraw(tokenIds[i], amounts[i]);
    }
  }

  /// @inheritdoc ITranchedPool
  function withdrawMax(
    uint256 tokenId
  )
    external
    override
    nonReentrant
    whenNotPaused
    returns (uint256 interestWithdrawn, uint256 principalWithdrawn)
  {
    IPoolTokens.TokenInfo memory tokenInfo = config.getPoolTokens().getTokenInfo(tokenId);
    ITranchedPool.TrancheInfo storage trancheInfo = _getTrancheInfo(tokenInfo.tranche);

    (uint256 interestRedeemable, uint256 principalRedeemable) = TranchingLogic
      .redeemableInterestAndPrincipal(trancheInfo, tokenInfo);

    uint256 amount = interestRedeemable.add(principalRedeemable);

    return _withdraw(trancheInfo, tokenInfo, tokenId, amount);
  }

  /// @inheritdoc ITranchedPool
  /// @dev DP: drawdowns paused
  /// @dev IF: insufficient funds
  function drawdown(uint256 amount) external override onlyLocker whenNotPaused {
    require(!drawdownsPaused, "DP");
    if (!_locked()) {
      // Assumes the senior pool has invested already (saves the borrower a separate transaction to lock the pool)
      _lockPool();
    }
    // Drawdown only draws down from the current slice for simplicity. It's harder to account for how much
    // money is available from previous slices since depositors can redeem after unlock.
    ITranchedPool.PoolSlice storage currentSlice = _poolSlices[numSlices - 1];
    uint256 amountAvailable = TranchingLogic.sharePriceToUsdc(
      currentSlice.juniorTranche.principalSharePrice,
      currentSlice.juniorTranche.principalDeposited
    );
    amountAvailable = amountAvailable.add(
      TranchingLogic.sharePriceToUsdc(
        currentSlice.seniorTranche.principalSharePrice,
        currentSlice.seniorTranche.principalDeposited
      )
    );

    require(amount <= amountAvailable, "IF");

    creditLine.drawdown(amount);

    // Update the share price to reflect the amount remaining in the pool
    uint256 amountRemaining = amountAvailable.sub(amount);
    uint256 oldJuniorPrincipalSharePrice = currentSlice.juniorTranche.principalSharePrice;
    uint256 oldSeniorPrincipalSharePrice = currentSlice.seniorTranche.principalSharePrice;
    currentSlice.juniorTranche.principalSharePrice = currentSlice
      .juniorTranche
      .calculateExpectedSharePrice(amountRemaining, currentSlice);
    currentSlice.seniorTranche.principalSharePrice = currentSlice
      .seniorTranche
      .calculateExpectedSharePrice(amountRemaining, currentSlice);
    currentSlice.principalDeployed = currentSlice.principalDeployed.add(amount);
    totalDeployed = totalDeployed.add(amount);

    address borrower = creditLine.borrower();
    IBackerRewards backerRewards = IBackerRewards(config.backerRewardsAddress());
    backerRewards.onTranchedPoolDrawdown(numSlices - 1);
    config.getUSDC().safeERC20Transfer(borrower, amount);
    emit DrawdownMade(borrower, amount);
    emit SharePriceUpdated(
      address(this),
      currentSlice.juniorTranche.id,
      currentSlice.juniorTranche.principalSharePrice,
      int256(oldJuniorPrincipalSharePrice.sub(currentSlice.juniorTranche.principalSharePrice)) * -1,
      currentSlice.juniorTranche.interestSharePrice,
      0
    );
    emit SharePriceUpdated(
      address(this),
      currentSlice.seniorTranche.id,
      currentSlice.seniorTranche.principalSharePrice,
      int256(oldSeniorPrincipalSharePrice.sub(currentSlice.seniorTranche.principalSharePrice)) * -1,
      currentSlice.seniorTranche.interestSharePrice,
      0
    );
  }

  function NUM_TRANCHES_PER_SLICE() external pure returns (uint256) {
    return TranchingLogic.NUM_TRANCHES_PER_SLICE;
  }

  /// @inheritdoc ITranchedPool
  function lockJuniorCapital() external override onlyLocker whenNotPaused {
    _lockJuniorCapital(numSlices.sub(1));
  }

  /// @inheritdoc ITranchedPool
  function lockPool() external override onlyLocker whenNotPaused {
    _lockPool();
  }

  /// @inheritdoc ITranchedPool
  function setFundableAt(uint256 newFundableAt) external override onlyLocker {
    fundableAt = newFundableAt;
  }

  /// @inheritdoc ITranchedPool
  /// @dev NL: not locked
  /// @dev LP: late payment
  /// @dev GP: beyond principal grace period
  function initializeNextSlice(uint256 _fundableAt) external override onlyLocker whenNotPaused {
    require(_locked(), "NL");
    require(!creditLine.isLate(), "LP");
    require(creditLine.withinPrincipalGracePeriod(), "GP");
    _initializeNextSlice(_fundableAt);
    emit SliceCreated(address(this), numSlices.sub(1));
  }

  /// @inheritdoc ITranchedPool
  /// @dev IT: invalid timestamp
  /// @dev LI: loan inactive
  function getAmountsOwed(
    uint256 timestamp
  )
    external
    view
    override
    returns (uint256 interestOwed, uint256 interestAccrued, uint256 principalOwed)
  {
    require(timestamp >= block.timestamp, "IT");
    require(creditLine.termEndTime() > 0, "LI");

    return (
      creditLine.interestOwedAt(timestamp),
      creditLine.interestAccruedAt(timestamp),
      creditLine.principalOwedAt(timestamp)
    );
  }

  /// @inheritdoc ITranchedPool
  /// @dev ZA: zero amount
  function pay(
    uint256 amount
  ) external override nonReentrant whenNotPaused returns (PaymentAllocation memory) {
    require(amount > 0, "ZA");
    // Send money to the credit line. Only take what's actually owed
    uint256 maxPayableAmount = creditLine.interestAccrued().add(creditLine.interestOwed()).add(
      creditLine.balance()
    );
    uint256 amountToPay = Math.min(amount, maxPayableAmount);
    config.getUSDC().safeERC20TransferFrom(msg.sender, address(this), amountToPay);

    PaymentAllocation memory pa = _pay(amount);

    // Payment remaining should always be 0 because we don't take excess usdc
    assert(pa.paymentRemaining == 0);
    return pa;
  }

  /// @inheritdoc ITranchedPool
  /// @dev ZA: zero amount
  function pay(
    uint256 principalAmount,
    uint256 interestAmount
  ) external override nonReentrant whenNotPaused returns (PaymentAllocation memory) {
    uint256 totalPayment = principalAmount.add(interestAmount);
    require(totalPayment > 0, "ZA");

    // If there is an excess principal payment then only take what we actually need
    uint256 principalToPay = Math.min(principalAmount, creditLine.balance());

    // If there is an excess interest payment then only take what we actually need
    uint256 maxPayableInterest = creditLine.interestAccrued().add(creditLine.interestOwed());
    uint256 interestToPay = Math.min(interestAmount, maxPayableInterest);
    config.getUSDC().safeERC20TransferFrom(
      msg.sender,
      address(this),
      principalToPay.add(interestToPay)
    );
    PaymentAllocation memory pa = _pay(principalToPay, interestToPay);

    // Payment remaining should always be 0 because we don't take excess usdc
    assert(pa.paymentRemaining == 0);
    return pa;
  }

  /// @notice Pauses the pool and sweeps any remaining funds to the treasury reserve.
  function emergencyShutdown() public onlyAdmin {
    if (!paused()) {
      pause();
    }

    IERC20withDec usdc = config.getUSDC();
    address reserveAddress = config.reserveAddress();
    // Sweep any funds to community reserve
    uint256 poolBalance = usdc.balanceOf(address(this));
    if (poolBalance > 0) {
      config.getUSDC().safeERC20Transfer(reserveAddress, poolBalance);
    }

    uint256 clBalance = usdc.balanceOf(address(creditLine));
    if (clBalance > 0) {
      usdc.safeERC20TransferFrom(address(creditLine), reserveAddress, clBalance);
    }
    emit EmergencyShutdown(address(this));
  }

  /// @notice Pauses all drawdowns (but not deposits/withdraws)
  function pauseDrawdowns() public onlyAdmin {
    drawdownsPaused = true;
    emit DrawdownsPaused(address(this));
  }

  /// @notice Unpause drawdowns
  function unpauseDrawdowns() public onlyAdmin {
    drawdownsPaused = false;
    emit DrawdownsUnpaused(address(this));
  }

  // CreditLine proxy method
  function setLimit(uint256 newAmount) external onlyAdmin {
    return creditLine.setLimit(newAmount);
  }

  function setMaxLimit(uint256 newAmount) external onlyAdmin {
    return creditLine.setMaxLimit(newAmount);
  }

  /// @inheritdoc ITranchedPool
  function getTranche(
    uint256 tranche
  ) public view override returns (ITranchedPool.TrancheInfo memory) {
    return _getTrancheInfo(tranche);
  }

  /// @inheritdoc ITranchedPool
  function poolSlices(
    uint256 index
  ) external view override returns (ITranchedPool.PoolSlice memory) {
    return _poolSlices[index];
  }

  /// @inheritdoc ITranchedPool
  function totalJuniorDeposits() external view override returns (uint256) {
    uint256 total;
    for (uint256 i = 0; i < numSlices; i++) {
      total = total.add(_poolSlices[i].juniorTranche.principalDeposited);
    }
    return total;
  }

  /// @inheritdoc ITranchedPool
  function availableToWithdraw(uint256 tokenId) public view override returns (uint256, uint256) {
    IPoolTokens.TokenInfo memory tokenInfo = config.getPoolTokens().getTokenInfo(tokenId);
    ITranchedPool.TrancheInfo storage trancheInfo = _getTrancheInfo(tokenInfo.tranche);

    if (block.timestamp > trancheInfo.lockedUntil) {
      return TranchingLogic.redeemableInterestAndPrincipal(trancheInfo, tokenInfo);
    } else {
      return (0, 0);
    }
  }

  function hasAllowedUID(address sender) public view override returns (bool) {
    return config.getGo().goOnlyIdTypes(sender, allowedUIDTypes);
  }

  /* Internal functions  */

  /// @dev NL: not locked
  function _pay(
    uint256 principalPayment,
    uint256 interestPayment
  ) internal returns (PaymentAllocation memory) {
    // We need to make sure the pool is locked before we allocate rewards to ensure it's not
    // possible to game rewards by sandwiching an interest payment to an unlocked pool
    // It also causes issues trying to allocate payments to an empty slice (divide by zero)
    require(_locked(), "NL");

    uint256 totalInterestAccruedAtLastCheckpoint = creditLine.totalInterestAccruedAt(
      creditLine.interestAccruedAsOf()
    );
    PaymentAllocation memory pa = creditLine.pay(principalPayment, interestPayment);
    uint256 interestAccruedSinceLastCheckpoint = creditLine.totalInterestAccrued().sub(
      totalInterestAccruedAtLastCheckpoint
    );

    distributeToSlicesAndAllocateBackerRewards(interestAccruedSinceLastCheckpoint, pa);
    return pa;
  }

  function _pay(uint256 paymentAmount) internal returns (PaymentAllocation memory) {
    // We need to make sure the pool is locked before we allocate rewards to ensure it's not
    // possible to game rewards by sandwiching an interest payment to an unlocked pool
    // It also causes issues trying to allocate payments to an empty slice (divide by zero)
    require(_locked(), "NL");

    uint256 interestAccrued = creditLine.totalInterestAccruedAt(creditLine.interestAccruedAsOf());
    PaymentAllocation memory pa = creditLine.pay(paymentAmount);
    interestAccrued = creditLine.totalInterestAccrued().sub(interestAccrued);

    distributeToSlicesAndAllocateBackerRewards(interestAccrued, pa);
    return pa;
  }

  function distributeToSlicesAndAllocateBackerRewards(
    uint256 interestAccrued,
    PaymentAllocation memory pa
  ) internal {
    // Split the interest accrued proportionally across slices so we know how much interest goes to each slice
    // We need this because the slice start at different times, so we cannot retroactively allocate the interest
    // linearly
    uint256[] memory principalPaymentsPerSlice = new uint256[](numSlices);
    for (uint256 i = 0; i < numSlices; i++) {
      ITranchedPool.PoolSlice storage slice = _poolSlices[i];
      uint256 interestForSlice = TranchingLogic.scaleByFraction(
        interestAccrued,
        slice.principalDeployed,
        totalDeployed
      );
      principalPaymentsPerSlice[i] = TranchingLogic.scaleByFraction(
        pa.principalPayment.add(pa.additionalBalancePayment),
        slice.principalDeployed,
        totalDeployed
      );
      _poolSlices[i].totalInterestAccrued = _poolSlices[i].totalInterestAccrued.add(
        interestForSlice
      );
    }

    uint256 interestPayment = pa.owedInterestPayment.add(pa.accruedInterestPayment);
    uint256 principalPayment = pa.principalPayment.add(pa.additionalBalancePayment);
    if (interestPayment > 0 || principalPayment > 0) {
      uint256 reserveAmount = _collectInterestAndPrincipal(interestPayment, principalPayment);

      uint256 principalPaymentsToSlices = 0;
      for (uint256 i = 0; i < numSlices; i++) {
        _poolSlices[i].principalDeployed = _poolSlices[i].principalDeployed.sub(
          principalPaymentsPerSlice[i]
        );
        principalPaymentsToSlices = principalPaymentsToSlices.add(principalPaymentsPerSlice[i]);
      }

      totalDeployed = totalDeployed.sub(principalPaymentsToSlices);

      config.getBackerRewards().allocateRewards(interestPayment);

      emit PaymentApplied(
        creditLine.borrower(),
        address(this),
        pa.owedInterestPayment.add(pa.accruedInterestPayment),
        principalPayment,
        pa.paymentRemaining,
        reserveAmount
      );
    }
  }

  function _collectInterestAndPrincipal(
    uint256 interest,
    uint256 principal
  ) internal returns (uint256) {
    uint256 totalReserveAmount = TranchingLogic.applyToAllSlices(
      _poolSlices,
      numSlices,
      interest,
      principal,
      uint256(100).div(config.getReserveDenominator()), // Convert the denominator to percent
      totalDeployed,
      creditLine,
      juniorFeePercent
    );

    config.getUSDC().safeERC20Transfer(config.reserveAddress(), totalReserveAmount);

    emit ReserveFundsCollected(address(this), totalReserveAmount);

    return totalReserveAmount;
  }

  function _createAndSetCreditLine(
    address _borrower,
    uint256 _maxLimit,
    uint256 _interestApr,
    ISchedule _schedule,
    uint256 _lateFeeApr
  ) internal {
    creditLine = ICreditLine(config.getGoldfinchFactory().createCreditLine());
    creditLine.initialize(
      address(config),
      address(this), // Set self as the owner
      _borrower,
      _maxLimit,
      _interestApr,
      _schedule,
      _lateFeeApr
    );
  }

  // // Internal //////////////////////////////////////////////////////////////////

  /// @dev ZA: Zero amount
  /// @dev IA: Invalid amount - amount too large
  /// @dev TL: Tranched Locked
  function _withdraw(
    ITranchedPool.TrancheInfo storage trancheInfo,
    IPoolTokens.TokenInfo memory tokenInfo,
    uint256 tokenId,
    uint256 amount
  ) internal returns (uint256, uint256) {
    /// @dev NA: not authorized
    require(
      config.getPoolTokens().isApprovedOrOwner(msg.sender, tokenId) && hasAllowedUID(msg.sender),
      "NA"
    );
    require(amount > 0, "ZA");
    (uint256 interestRedeemable, uint256 principalRedeemable) = TranchingLogic
      .redeemableInterestAndPrincipal(trancheInfo, tokenInfo);
    uint256 netRedeemable = interestRedeemable.add(principalRedeemable);

    require(amount <= netRedeemable, "IA");
    require(block.timestamp > trancheInfo.lockedUntil, "TL");

    uint256 interestToRedeem = 0;
    uint256 principalToRedeem = 0;

    // If the tranche has not been locked, ensure the deposited amount is correct
    if (trancheInfo.lockedUntil == 0) {
      trancheInfo.principalDeposited = trancheInfo.principalDeposited.sub(amount);

      principalToRedeem = amount;

      config.getPoolTokens().withdrawPrincipal(tokenId, principalToRedeem);
    } else {
      interestToRedeem = Math.min(interestRedeemable, amount);
      principalToRedeem = Math.min(principalRedeemable, amount.sub(interestToRedeem));

      config.getPoolTokens().redeem(tokenId, principalToRedeem, interestToRedeem);
    }

    config.getUSDC().safeERC20Transfer(msg.sender, principalToRedeem.add(interestToRedeem));

    emit WithdrawalMade(
      msg.sender,
      tokenInfo.tranche,
      tokenId,
      interestToRedeem,
      principalToRedeem
    );

    return (interestToRedeem, principalToRedeem);
  }

  /// @dev TL: tranch locked or has been locked before
  function _lockJuniorCapital(uint256 sliceId) internal {
    require(!_locked() && _poolSlices[sliceId].juniorTranche.lockedUntil == 0, "TL");
    TranchingLogic.lockTranche(_poolSlices[sliceId].juniorTranche, config);
  }

  /// @dev NL: Not locked
  /// @dev TL: tranche locked. The senior pool has already been locked.
  function _lockPool() internal {
    ITranchedPool.PoolSlice storage slice = _poolSlices[numSlices.sub(1)];
    require(slice.juniorTranche.lockedUntil > 0, "NL");
    // Allow locking the pool only once; do not allow extending the lock of an
    // already-locked pool. Otherwise the locker could keep the pool locked
    // indefinitely, preventing withdrawals.
    require(slice.seniorTranche.lockedUntil == 0, "TL");

    uint256 currentTotal = slice.juniorTranche.principalDeposited.add(
      slice.seniorTranche.principalDeposited
    );
    creditLine.setLimit(Math.min(creditLine.limit().add(currentTotal), creditLine.maxLimit()));

    // We start the drawdown period, so backers can withdraw unused capital after borrower draws down
    TranchingLogic.lockTranche(slice.juniorTranche, config);
    TranchingLogic.lockTranche(slice.seniorTranche, config);
  }

  /// @dev SL: slice limit
  function _initializeNextSlice(uint256 newFundableAt) internal {
    require(numSlices < 5, "SL");
    TranchingLogic.initializeNextSlice(_poolSlices, numSlices);
    numSlices = numSlices.add(1);
    fundableAt = newFundableAt;
  }

  // If the senior tranche of the current slice is locked, then the pool is not open to any more deposits
  // (could throw off leverage ratio)
  function _locked() internal view returns (bool) {
    return numSlices == 0 || _poolSlices[numSlices - 1].seniorTranche.lockedUntil > 0;
  }

  function _getTrancheInfo(
    uint256 trancheId
  ) internal view returns (ITranchedPool.TrancheInfo storage) {
    require(
      trancheId > 0 && trancheId <= numSlices.mul(TranchingLogic.NUM_TRANCHES_PER_SLICE),
      "invalid tranche"
    );
    uint256 sliceId = TranchingLogic.trancheIdToSliceIndex(trancheId);
    ITranchedPool.PoolSlice storage slice = _poolSlices[sliceId];
    ITranchedPool.TrancheInfo storage trancheInfo = TranchingLogic.isSeniorTrancheId(trancheId)
      ? slice.seniorTranche
      : slice.juniorTranche;
    return trancheInfo;
  }

  // // Modifiers /////////////////////////////////////////////////////////////////

  /// @inheritdoc IVersioned
  function getVersion() external pure override returns (uint8[3] memory version) {
    (version[0], version[1], version[2]) = (MAJOR_VERSION, MINOR_VERSION, PATCH_VERSION);
  }

  /// @dev NA: not authorized. not locker
  modifier onlyLocker() {
    require(hasRole(LOCKER_ROLE, msg.sender), "NA");
    _;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {ICreditLine} from "../../interfaces/ICreditLine.sol";
import {ITranchedPool} from "../../interfaces/ITranchedPool.sol";
import {IPoolTokens} from "../../interfaces/IPoolTokens.sol";
import {GoldfinchConfig} from "./GoldfinchConfig.sol";
import {ConfigHelper} from "./ConfigHelper.sol";
import {FixedPoint} from "../../external/FixedPoint.sol";
import {Math} from "@openzeppelin/contracts-ethereum-package/contracts/math/Math.sol";
import {SafeMath} from "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";

/**
 * @title TranchingLogic
 * @notice Library for handling the payments waterfall
 * @author Goldfinch
 */

library TranchingLogic {
  using SafeMath for uint256;
  using FixedPoint for FixedPoint.Unsigned;
  using FixedPoint for uint256;
  using ConfigHelper for GoldfinchConfig;

  struct SliceInfo {
    uint256 reserveFeePercent;
    uint256 interestAccrued;
    uint256 principalAccrued;
  }

  struct ApplyResult {
    uint256 interestRemaining;
    uint256 principalRemaining;
    uint256 reserveDeduction;
    uint256 oldInterestSharePrice;
    uint256 oldPrincipalSharePrice;
  }

  uint256 internal constant FP_SCALING_FACTOR = 1e18;
  uint256 public constant NUM_TRANCHES_PER_SLICE = 2;

  function usdcToSharePrice(uint256 amount, uint256 totalShares) public pure returns (uint256) {
    return totalShares == 0 ? 0 : amount.mul(FP_SCALING_FACTOR).div(totalShares);
  }

  function sharePriceToUsdc(uint256 sharePrice, uint256 totalShares) public pure returns (uint256) {
    return sharePrice.mul(totalShares).div(FP_SCALING_FACTOR);
  }

  function lockTranche(ITranchedPool.TrancheInfo storage tranche, GoldfinchConfig config) external {
    tranche.lockedUntil = block.timestamp.add(config.getDrawdownPeriodInSeconds());
    emit TrancheLocked(address(this), tranche.id, tranche.lockedUntil);
  }

  function redeemableInterestAndPrincipal(
    ITranchedPool.TrancheInfo storage trancheInfo,
    IPoolTokens.TokenInfo memory tokenInfo
  ) public view returns (uint256, uint256) {
    // This supports withdrawing before or after locking because principal share price starts at 1
    // and is set to 0 on lock. Interest share price is always 0 until interest payments come back, when it increases
    uint256 maxPrincipalRedeemable = sharePriceToUsdc(
      trancheInfo.principalSharePrice,
      tokenInfo.principalAmount
    );
    // The principalAmount is used as the totalShares because we want the interestSharePrice to be expressed as a
    // percent of total loan value e.g. if the interest is 10% APR, the interestSharePrice should approach a max of 0.1.
    uint256 maxInterestRedeemable = sharePriceToUsdc(
      trancheInfo.interestSharePrice,
      tokenInfo.principalAmount
    );

    uint256 interestRedeemable = maxInterestRedeemable.sub(tokenInfo.interestRedeemed);
    uint256 principalRedeemable = maxPrincipalRedeemable.sub(tokenInfo.principalRedeemed);

    return (interestRedeemable, principalRedeemable);
  }

  function calculateExpectedSharePrice(
    ITranchedPool.TrancheInfo memory tranche,
    uint256 amount,
    ITranchedPool.PoolSlice memory slice
  ) public pure returns (uint256) {
    uint256 sharePrice = usdcToSharePrice(amount, tranche.principalDeposited);
    return _scaleByPercentOwnership(tranche, sharePrice, slice);
  }

  function scaleForSlice(
    ITranchedPool.PoolSlice memory slice,
    uint256 amount,
    uint256 totalDeployed
  ) public pure returns (uint256) {
    return scaleByFraction(amount, slice.principalDeployed, totalDeployed);
  }

  // We need to create this struct so we don't run into a stack too deep error due to too many variables
  function getSliceInfo(
    ITranchedPool.PoolSlice memory slice,
    ICreditLine creditLine,
    uint256 totalDeployed,
    uint256 reserveFeePercent
  ) public view returns (SliceInfo memory) {
    (uint256 interestAccrued, uint256 principalAccrued) = getTotalInterestAndPrincipal(
      slice,
      creditLine,
      totalDeployed
    );
    return
      SliceInfo({
        reserveFeePercent: reserveFeePercent,
        interestAccrued: interestAccrued,
        principalAccrued: principalAccrued
      });
  }

  function getTotalInterestAndPrincipal(
    ITranchedPool.PoolSlice memory slice,
    ICreditLine creditLine,
    uint256 totalDeployed
  ) public view returns (uint256, uint256) {
    uint256 principalAccrued = creditLine.principalOwed();
    // In addition to principal actually owed, we need to account for early principal payments
    // If the borrower pays back 5K early on a 10K loan, the actual principal accrued should be
    // 5K (balance- deployed) + 0 (principal owed)
    principalAccrued = totalDeployed.sub(creditLine.balance()).add(principalAccrued);
    // Now we need to scale that correctly for the slice we're interested in
    principalAccrued = scaleForSlice(slice, principalAccrued, totalDeployed);
    // Finally, we need to account for partial drawdowns. e.g. If 20K was deposited, and only 10K was drawn down,
    // Then principal accrued should start at 10K (total deposited - principal deployed), not 0. This is because
    // share price starts at 1, and is decremented by what was drawn down.
    uint256 totalDeposited = slice.seniorTranche.principalDeposited.add(
      slice.juniorTranche.principalDeposited
    );
    principalAccrued = totalDeposited.sub(slice.principalDeployed).add(principalAccrued);
    return (slice.totalInterestAccrued, principalAccrued);
  }

  function scaleByFraction(
    uint256 amount,
    uint256 fraction,
    uint256 total
  ) public pure returns (uint256) {
    FixedPoint.Unsigned memory totalAsFixedPoint = FixedPoint.fromUnscaledUint(total);
    FixedPoint.Unsigned memory fractionAsFixedPoint = FixedPoint.fromUnscaledUint(fraction);
    return fractionAsFixedPoint.div(totalAsFixedPoint).mul(amount).div(FP_SCALING_FACTOR).rawValue;
  }

  /// @notice apply a payment to all slices
  /// @param poolSlices slices to apply to
  /// @param numSlices number of slices
  /// @param interest amount of interest to apply
  /// @param principal amount of principal to apply
  /// @param reserveFeePercent percentage that protocol will take for reserves
  /// @param totalDeployed total amount of principal deployed
  /// @param creditLine creditline to account for
  /// @param juniorFeePercent percentage the junior tranche will take
  /// @return total amount that will be sent to reserves
  function applyToAllSlices(
    mapping(uint256 => ITranchedPool.PoolSlice) storage poolSlices,
    uint256 numSlices,
    uint256 interest,
    uint256 principal,
    uint256 reserveFeePercent,
    uint256 totalDeployed,
    ICreditLine creditLine,
    uint256 juniorFeePercent
  ) external returns (uint256) {
    ApplyResult memory result = TranchingLogic.applyToAllSeniorTranches(
      poolSlices,
      numSlices,
      interest,
      principal,
      reserveFeePercent,
      totalDeployed,
      creditLine,
      juniorFeePercent
    );

    return
      result.reserveDeduction.add(
        TranchingLogic.applyToAllJuniorTranches(
          poolSlices,
          numSlices,
          result.interestRemaining,
          result.principalRemaining,
          reserveFeePercent,
          totalDeployed,
          creditLine
        )
      );
  }

  function applyToAllSeniorTranches(
    mapping(uint256 => ITranchedPool.PoolSlice) storage poolSlices,
    uint256 numSlices,
    uint256 interest,
    uint256 principal,
    uint256 reserveFeePercent,
    uint256 totalDeployed,
    ICreditLine creditLine,
    uint256 juniorFeePercent
  ) internal returns (ApplyResult memory) {
    ApplyResult memory seniorApplyResult;
    for (uint256 i = 0; i < numSlices; i++) {
      ITranchedPool.PoolSlice storage slice = poolSlices[i];

      SliceInfo memory sliceInfo = getSliceInfo(
        slice,
        creditLine,
        totalDeployed,
        reserveFeePercent
      );

      // Since slices cannot be created when the loan is late, all interest collected can be assumed to split
      // pro-rata across the slices. So we scale the interest and principal to the slice
      ApplyResult memory applyResult = applyToSeniorTranche(
        slice,
        scaleForSlice(slice, interest, totalDeployed),
        scaleForSlice(slice, principal, totalDeployed),
        juniorFeePercent,
        sliceInfo
      );
      emitSharePriceUpdatedEvent(slice.seniorTranche, applyResult);
      seniorApplyResult.interestRemaining = seniorApplyResult.interestRemaining.add(
        applyResult.interestRemaining
      );
      seniorApplyResult.principalRemaining = seniorApplyResult.principalRemaining.add(
        applyResult.principalRemaining
      );
      seniorApplyResult.reserveDeduction = seniorApplyResult.reserveDeduction.add(
        applyResult.reserveDeduction
      );
    }
    return seniorApplyResult;
  }

  function applyToAllJuniorTranches(
    mapping(uint256 => ITranchedPool.PoolSlice) storage poolSlices,
    uint256 numSlices,
    uint256 interest,
    uint256 principal,
    uint256 reserveFeePercent,
    uint256 totalDeployed,
    ICreditLine creditLine
  ) internal returns (uint256 totalReserveAmount) {
    for (uint256 i = 0; i < numSlices; i++) {
      SliceInfo memory sliceInfo = getSliceInfo(
        poolSlices[i],
        creditLine,
        totalDeployed,
        reserveFeePercent
      );
      // Any remaining interest and principal is then shared pro-rata with the junior slices
      ApplyResult memory applyResult = applyToJuniorTranche(
        poolSlices[i],
        scaleForSlice(poolSlices[i], interest, totalDeployed),
        scaleForSlice(poolSlices[i], principal, totalDeployed),
        sliceInfo
      );
      emitSharePriceUpdatedEvent(poolSlices[i].juniorTranche, applyResult);
      totalReserveAmount = totalReserveAmount.add(applyResult.reserveDeduction);
    }
    return totalReserveAmount;
  }

  function emitSharePriceUpdatedEvent(
    ITranchedPool.TrancheInfo memory tranche,
    ApplyResult memory applyResult
  ) internal {
    emit SharePriceUpdated(
      address(this),
      tranche.id,
      tranche.principalSharePrice,
      int256(tranche.principalSharePrice.sub(applyResult.oldPrincipalSharePrice)),
      tranche.interestSharePrice,
      int256(tranche.interestSharePrice.sub(applyResult.oldInterestSharePrice))
    );
  }

  function applyToSeniorTranche(
    ITranchedPool.PoolSlice storage slice,
    uint256 interestRemaining,
    uint256 principalRemaining,
    uint256 juniorFeePercent,
    SliceInfo memory sliceInfo
  ) internal returns (ApplyResult memory) {
    // First determine the expected share price for the senior tranche. This is the gross amount the senior
    // tranche should receive.
    uint256 expectedInterestSharePrice = calculateExpectedSharePrice(
      slice.seniorTranche,
      sliceInfo.interestAccrued,
      slice
    );
    uint256 expectedPrincipalSharePrice = calculateExpectedSharePrice(
      slice.seniorTranche,
      sliceInfo.principalAccrued,
      slice
    );

    // Deduct the junior fee and the protocol reserve
    uint256 desiredNetInterestSharePrice = scaleByFraction(
      expectedInterestSharePrice,
      uint256(100).sub(juniorFeePercent.add(sliceInfo.reserveFeePercent)),
      uint256(100)
    );
    // Collect protocol fee interest received (we've subtracted this from the senior portion above)
    uint256 reserveDeduction = scaleByFraction(
      interestRemaining,
      sliceInfo.reserveFeePercent,
      uint256(100)
    );
    interestRemaining = interestRemaining.sub(reserveDeduction);
    uint256 oldInterestSharePrice = slice.seniorTranche.interestSharePrice;
    uint256 oldPrincipalSharePrice = slice.seniorTranche.principalSharePrice;
    // Apply the interest remaining so we get up to the netInterestSharePrice
    (interestRemaining, principalRemaining) = _applyBySharePrice(
      slice.seniorTranche,
      interestRemaining,
      principalRemaining,
      desiredNetInterestSharePrice,
      expectedPrincipalSharePrice
    );
    return
      ApplyResult({
        interestRemaining: interestRemaining,
        principalRemaining: principalRemaining,
        reserveDeduction: reserveDeduction,
        oldInterestSharePrice: oldInterestSharePrice,
        oldPrincipalSharePrice: oldPrincipalSharePrice
      });
  }

  function applyToJuniorTranche(
    ITranchedPool.PoolSlice storage slice,
    uint256 interestRemaining,
    uint256 principalRemaining,
    SliceInfo memory sliceInfo
  ) public returns (ApplyResult memory) {
    // Then fill up the junior tranche with all the interest remaining, upto the principal share price
    uint256 expectedInterestSharePrice = slice.juniorTranche.interestSharePrice.add(
      usdcToSharePrice(interestRemaining, slice.juniorTranche.principalDeposited)
    );
    uint256 expectedPrincipalSharePrice = calculateExpectedSharePrice(
      slice.juniorTranche,
      sliceInfo.principalAccrued,
      slice
    );
    uint256 oldInterestSharePrice = slice.juniorTranche.interestSharePrice;
    uint256 oldPrincipalSharePrice = slice.juniorTranche.principalSharePrice;
    (interestRemaining, principalRemaining) = _applyBySharePrice(
      slice.juniorTranche,
      interestRemaining,
      principalRemaining,
      expectedInterestSharePrice,
      expectedPrincipalSharePrice
    );

    // All remaining interest and principal is applied towards the junior tranche as interest
    interestRemaining = interestRemaining.add(principalRemaining);
    // Since any principal remaining is treated as interest (there is "extra" interest to be distributed)
    // we need to make sure to collect the protocol fee on the additional interest (we only deducted the
    // fee on the original interest portion)
    uint256 reserveDeduction = scaleByFraction(
      principalRemaining,
      sliceInfo.reserveFeePercent,
      uint256(100)
    );
    interestRemaining = interestRemaining.sub(reserveDeduction);
    principalRemaining = 0;

    (interestRemaining, principalRemaining) = _applyByAmount(
      slice.juniorTranche,
      interestRemaining.add(principalRemaining),
      0,
      interestRemaining.add(principalRemaining),
      0
    );
    return
      ApplyResult({
        interestRemaining: interestRemaining,
        principalRemaining: principalRemaining,
        reserveDeduction: reserveDeduction,
        oldInterestSharePrice: oldInterestSharePrice,
        oldPrincipalSharePrice: oldPrincipalSharePrice
      });
  }

  function trancheIdToSliceIndex(uint256 trancheId) external pure returns (uint256) {
    return trancheId.sub(1).div(NUM_TRANCHES_PER_SLICE);
  }

  function initializeNextSlice(
    mapping(uint256 => ITranchedPool.PoolSlice) storage poolSlices,
    uint256 sliceIndex
  ) external {
    poolSlices[sliceIndex] = ITranchedPool.PoolSlice({
      seniorTranche: ITranchedPool.TrancheInfo({
        id: sliceIndexToSeniorTrancheId(sliceIndex),
        principalSharePrice: usdcToSharePrice(1, 1),
        interestSharePrice: 0,
        principalDeposited: 0,
        lockedUntil: 0
      }),
      juniorTranche: ITranchedPool.TrancheInfo({
        id: sliceIndexToJuniorTrancheId(sliceIndex),
        principalSharePrice: usdcToSharePrice(1, 1),
        interestSharePrice: 0,
        principalDeposited: 0,
        lockedUntil: 0
      }),
      totalInterestAccrued: 0,
      principalDeployed: 0
    });
  }

  function sliceIndexToJuniorTrancheId(uint256 sliceIndex) public pure returns (uint256) {
    // 0 -> 2
    // 1 -> 4
    return sliceIndex.mul(NUM_TRANCHES_PER_SLICE).add(2);
  }

  function sliceIndexToSeniorTrancheId(uint256 sliceIndex) public pure returns (uint256) {
    // 0 -> 1
    // 1 -> 3
    return sliceIndex.mul(NUM_TRANCHES_PER_SLICE).add(1);
  }

  function isSeniorTrancheId(uint256 trancheId) external pure returns (bool) {
    return trancheId.mod(TranchingLogic.NUM_TRANCHES_PER_SLICE) == 1;
  }

  function isJuniorTrancheId(uint256 trancheId) external pure returns (bool) {
    return trancheId != 0 && trancheId.mod(TranchingLogic.NUM_TRANCHES_PER_SLICE) == 0;
  }

  // // INTERNAL //////////////////////////////////////////////////////////////////

  function _applyToSharePrice(
    uint256 amountRemaining,
    uint256 currentSharePrice,
    uint256 desiredAmount,
    uint256 totalShares
  ) internal pure returns (uint256, uint256) {
    // If no money left to apply, or don't need any changes, return the original amounts
    if (amountRemaining == 0 || desiredAmount == 0) {
      return (amountRemaining, currentSharePrice);
    }
    if (amountRemaining < desiredAmount) {
      // We don't have enough money to adjust share price to the desired level. So just use whatever amount is left
      desiredAmount = amountRemaining;
    }
    uint256 sharePriceDifference = usdcToSharePrice(desiredAmount, totalShares);
    return (amountRemaining.sub(desiredAmount), currentSharePrice.add(sharePriceDifference));
  }

  function _scaleByPercentOwnership(
    ITranchedPool.TrancheInfo memory tranche,
    uint256 amount,
    ITranchedPool.PoolSlice memory slice
  ) internal pure returns (uint256) {
    uint256 totalDeposited = slice.juniorTranche.principalDeposited.add(
      slice.seniorTranche.principalDeposited
    );
    return scaleByFraction(amount, tranche.principalDeposited, totalDeposited);
  }

  function _desiredAmountFromSharePrice(
    uint256 desiredSharePrice,
    uint256 actualSharePrice,
    uint256 totalShares
  ) internal pure returns (uint256) {
    // If the desired share price is lower, then ignore it, and leave it unchanged
    if (desiredSharePrice < actualSharePrice) {
      desiredSharePrice = actualSharePrice;
    }
    uint256 sharePriceDifference = desiredSharePrice.sub(actualSharePrice);
    return sharePriceToUsdc(sharePriceDifference, totalShares);
  }

  function _applyByAmount(
    ITranchedPool.TrancheInfo storage tranche,
    uint256 interestRemaining,
    uint256 principalRemaining,
    uint256 desiredInterestAmount,
    uint256 desiredPrincipalAmount
  ) internal returns (uint256, uint256) {
    uint256 totalShares = tranche.principalDeposited;
    uint256 newSharePrice;

    (interestRemaining, newSharePrice) = _applyToSharePrice(
      interestRemaining,
      tranche.interestSharePrice,
      desiredInterestAmount,
      totalShares
    );
    tranche.interestSharePrice = newSharePrice;

    (principalRemaining, newSharePrice) = _applyToSharePrice(
      principalRemaining,
      tranche.principalSharePrice,
      desiredPrincipalAmount,
      totalShares
    );
    tranche.principalSharePrice = newSharePrice;
    return (interestRemaining, principalRemaining);
  }

  function _applyBySharePrice(
    ITranchedPool.TrancheInfo storage tranche,
    uint256 interestRemaining,
    uint256 principalRemaining,
    uint256 desiredInterestSharePrice,
    uint256 desiredPrincipalSharePrice
  ) internal returns (uint256, uint256) {
    uint256 desiredInterestAmount = _desiredAmountFromSharePrice(
      desiredInterestSharePrice,
      tranche.interestSharePrice,
      tranche.principalDeposited
    );
    uint256 desiredPrincipalAmount = _desiredAmountFromSharePrice(
      desiredPrincipalSharePrice,
      tranche.principalSharePrice,
      tranche.principalDeposited
    );
    return
      _applyByAmount(
        tranche,
        interestRemaining,
        principalRemaining,
        desiredInterestAmount,
        desiredPrincipalAmount
      );
  }

  // // Events /////////////////////////////////////////////////////////////////////

  // NOTE: this needs to match the event in TranchedPool
  event TrancheLocked(address indexed pool, uint256 trancheId, uint256 lockedUntil);

  event SharePriceUpdated(
    address indexed pool,
    uint256 indexed tranche,
    uint256 principalSharePrice,
    int256 principalDelta,
    uint256 interestSharePrice,
    int256 interestDelta
  );
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {BaseUpgradeablePausable} from "../BaseUpgradeablePausable.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

/// @title User Controlled Upgrades (UCU) Proxy Repository
/// A repository maintaing a collection of "lineages" of implementation contracts
///
/// Lineages are a sequence of implementations each lineage can be thought of as
/// a "major" revision of implementations. Implementations between lineages are
/// considered incompatible.
contract ImplementationRepository is BaseUpgradeablePausable {
  address internal constant INVALID_IMPL = address(0);
  uint256 internal constant INVALID_LINEAGE_ID = 0;

  /// @notice returns data that will be delegatedCalled when the given implementation
  ///           is upgraded to
  mapping(address => bytes) public upgradeDataFor;

  /// @dev mapping from one implementation to the succeeding implementation
  mapping(address => address) internal _nextImplementationOf;

  /// @notice Returns the id of the lineage a given implementation belongs to
  mapping(address => uint256) public lineageIdOf;

  /// @dev internal because we expose this through the `currentImplementation(uint256)` api
  mapping(uint256 => address) internal _currentOfLineage;

  /// @notice Returns the id of the most recently created lineage
  uint256 public currentLineageId;

  // //////// External ////////////////////////////////////////////////////////////

  /// @notice initialize the repository's state
  /// @dev reverts if `_owner` is the null address
  /// @dev reverts if `implementation` is not a contract
  /// @param _owner owner of the repository
  /// @param implementation initial implementation in the repository
  function initialize(address _owner, address implementation) external initializer {
    __BaseUpgradeablePausable__init(_owner);
    _createLineage(implementation);
    require(currentLineageId != INVALID_LINEAGE_ID);
  }

  /// @notice set data that will be delegate called when a proxy upgrades to the given `implementation`
  /// @dev reverts when caller is not an admin
  /// @dev reverts when the contract is paused
  /// @dev reverts if the given implementation isn't registered
  function setUpgradeDataFor(
    address implementation,
    bytes calldata data
  ) external onlyAdmin whenNotPaused {
    _setUpgradeDataFor(implementation, data);
  }

  /// @notice Create a new lineage of implementations.
  ///
  /// This creates a new "root" of a new lineage
  /// @dev reverts if `implementation` is not a contract
  /// @param implementation implementation that will be the first implementation in the lineage
  /// @return newly created lineage's id
  function createLineage(
    address implementation
  ) external onlyAdmin whenNotPaused returns (uint256) {
    return _createLineage(implementation);
  }

  /// @notice add a new implementation and set it as the current implementation
  /// @dev reverts if the sender is not an owner
  /// @dev reverts if the contract is paused
  /// @dev reverts if `implementation` is not a contract
  /// @param implementation implementation to append
  function append(address implementation) external onlyAdmin whenNotPaused {
    _append(implementation, currentLineageId);
  }

  /// @notice Append an implementation to a specified lineage
  /// @dev reverts if the contract is paused
  /// @dev reverts if the sender is not an owner
  /// @dev reverts if `implementation` is not a contract
  /// @param implementation implementation to append
  /// @param lineageId id of lineage to append to
  function append(address implementation, uint256 lineageId) external onlyAdmin whenNotPaused {
    _append(implementation, lineageId);
  }

  /// @notice Remove an implementation from the chain and "stitch" together its neighbors
  /// @dev If you have a chain of `A -> B -> C` and I call `remove(B, C)` it will result in `A -> C`
  /// @dev reverts if `previos` is not the ancestor of `toRemove`
  /// @dev we need to provide the previous implementation here to be able to successfully "stitch"
  ///       the chain back together. Because this is an admin action, we can source what the previous
  ///       version is from events.
  /// @param toRemove Implementation to remove
  /// @param previous Implementation that currently has `toRemove` as its successor
  function remove(address toRemove, address previous) external onlyAdmin whenNotPaused {
    _remove(toRemove, previous);
  }

  // //////// External view ////////////////////////////////////////////////////////////

  /// @notice Returns `true` if an implementation has a next implementation set
  /// @param implementation implementation to check
  /// @return The implementation following the given implementation
  function hasNext(address implementation) external view returns (bool) {
    return _nextImplementationOf[implementation] != INVALID_IMPL;
  }

  /// @notice Returns `true` if an implementation has already been added
  /// @param implementation Implementation to check existence of
  /// @return `true` if the implementation has already been added
  function has(address implementation) external view returns (bool) {
    return _has(implementation);
  }

  /// @notice Get the next implementation for a given implementation or
  ///           `address(0)` if it doesn't exist
  /// @dev reverts when contract is paused
  /// @param implementation implementation to get the upgraded implementation for
  /// @return Next Implementation
  function nextImplementationOf(
    address implementation
  ) external view whenNotPaused returns (address) {
    return _nextImplementationOf[implementation];
  }

  /// @notice Returns `true` if a given lineageId exists
  function lineageExists(uint256 lineageId) external view returns (bool) {
    return _lineageExists(lineageId);
  }

  /// @notice Return the current implementation of a lineage with the given `lineageId`
  function currentImplementation(uint256 lineageId) external view whenNotPaused returns (address) {
    return _currentImplementation(lineageId);
  }

  /// @notice return current implementaton of the current lineage
  function currentImplementation() external view whenNotPaused returns (address) {
    return _currentImplementation(currentLineageId);
  }

  // //////// Internal ////////////////////////////////////////////////////////////

  function _setUpgradeDataFor(address implementation, bytes memory data) internal {
    require(_has(implementation), "unknown impl");
    upgradeDataFor[implementation] = data;
    emit UpgradeDataSet(implementation, data);
  }

  function _createLineage(address implementation) internal virtual returns (uint256) {
    require(Address.isContract(implementation), "not a contract");
    // NOTE: impractical to overflow
    currentLineageId += 1;

    _currentOfLineage[currentLineageId] = implementation;
    lineageIdOf[implementation] = currentLineageId;

    emit Added(currentLineageId, implementation, address(0));
    return currentLineageId;
  }

  function _currentImplementation(uint256 lineageId) internal view returns (address) {
    return _currentOfLineage[lineageId];
  }

  /// @notice Returns `true` if an implementation has already been added
  /// @param implementation implementation to check for
  /// @return `true` if the implementation has already been added
  function _has(address implementation) internal view virtual returns (bool) {
    return lineageIdOf[implementation] != INVALID_LINEAGE_ID;
  }

  /// @notice Set an implementation to the current implementation
  /// @param implementation implementation to set as current implementation
  /// @param lineageId id of lineage to append to
  function _append(address implementation, uint256 lineageId) internal virtual {
    require(Address.isContract(implementation), "not a contract");
    require(!_has(implementation), "exists");
    require(_lineageExists(lineageId), "invalid lineageId");
    require(_currentOfLineage[lineageId] != INVALID_IMPL, "empty lineage");

    address oldImplementation = _currentOfLineage[lineageId];
    _currentOfLineage[lineageId] = implementation;
    lineageIdOf[implementation] = lineageId;
    _nextImplementationOf[oldImplementation] = implementation;

    emit Added(lineageId, implementation, oldImplementation);
  }

  function _remove(address toRemove, address previous) internal virtual {
    require(toRemove != INVALID_IMPL && previous != INVALID_IMPL, "ZERO");
    require(_nextImplementationOf[previous] == toRemove, "Not prev");

    uint256 lineageId = lineageIdOf[toRemove];

    // need to reset the head pointer to the previous version if we remove the head
    if (toRemove == _currentOfLineage[lineageId]) {
      _currentOfLineage[lineageId] = previous;
    }

    _setUpgradeDataFor(toRemove, ""); // reset upgrade data
    _nextImplementationOf[previous] = _nextImplementationOf[toRemove];
    _nextImplementationOf[toRemove] = INVALID_IMPL;
    lineageIdOf[toRemove] = INVALID_LINEAGE_ID;
    emit Removed(lineageId, toRemove);
  }

  function _lineageExists(uint256 lineageId) internal view returns (bool) {
    return lineageId != INVALID_LINEAGE_ID && lineageId <= currentLineageId;
  }

  // //////// Events //////////////////////////////////////////////////////////////
  event Added(
    uint256 indexed lineageId,
    address indexed newImplementation,
    address indexed oldImplementation
  );
  event Removed(uint256 indexed lineageId, address indexed implementation);
  event UpgradeDataSet(address indexed implementation, bytes data);
}