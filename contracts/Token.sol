// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is Context, IERC20Metadata, Ownable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private constant _decimals = 18;
    uint256 public constant presaleReserve = 50_000_000 * (10 ** _decimals);
    uint256 public constant stakingReserve = 30_000_000 * (10 ** _decimals);
    uint256 public constant rewardReserve = 10_000_000 * (10 ** _decimals);
    uint256 public constant projectFundReserve =
     10_000_000 * (10 ** _decimals);

    bool private onlyOnceMint = false;
 

    /**
     * @dev Contract constructor.
     */
    constructor() Ownable(msg.sender) {
        _name = "";
        _symbol = "";
       
    }

    function contractTransfer(address presaleAddress, address stakingAddress,address tokenKeeper, address owner) public {
        require(!onlyOnceMint, "Already minted");
        _mint(owner, projectFundReserve);
        _mint(presaleAddress, presaleReserve);
        _mint(stakingAddress, stakingReserve);
        _mint(tokenKeeper, rewardReserve);
        onlyOnceMint = true;
    }

    /**
     * @dev Returns the name of the token.
     * @return The name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token.
     * @return The symbol of the token.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used for token display.
     * @return The number of decimals.
     */
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the total supply of the token.
     * @return The total supply.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the balance of the specified account.
     * @param account The address to check the balance for.
     * @return The balance of the account.
     */
    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev Transfers tokens from the caller to a specified recipient.
     * @param recipient The address to transfer tokens to.
     * @param amount The amount of tokens to transfer.
     * @return A boolean value indicating whether the transfer was successful.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev Returns the amount of tokens that the spender is allowed to spend on behalf of the owner.
     * @param from The address that approves the spending.
     * @param to The address that is allowed to spend.
     * @return The remaining allowance for the spender.
     */
    function allowance(
        address from,
        address to
    ) public view virtual override returns (uint256) {
        return _allowances[from][to];
    }

    /**
     * @dev Approves the specified address to spend the specified amount of tokens on behalf of the caller.
     * @param to The address to approve the spending for.
     * @param amount The amount of tokens to approve.
     * @return A boolean value indicating whether the approval was successful.
     */
    function approve(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        _approve(_msgSender(), to, amount);
        return true;
    }

    /**
     * @dev Transfers tokens from one address to another.
     * @param sender The address to transfer tokens from.
     * @param recipient The address to transfer tokens to.
     * @param amount The amount of tokens to transfer.
     * @return A boolean value indicating whether the transfer was successful.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Increases the allowance of the specified address to spend tokens on behalf of the caller.
     * @param to The address to increase the allowance for.
     * @param addedValue The amount of tokens to increase the allowance by.
     * @return A boolean value indicating whether the increase was successful.
     */
    function increaseAllowance(
        address to,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(_msgSender(), to, _allowances[_msgSender()][to] + addedValue);
        return true;
    }

    /**
     * @dev Decreases the allowance granted by the owner of the tokens to `to` account.
     * @param to The account allowed to spend the tokens.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     * @return A boolean value indicating whether the operation succeeded.
     */
    function decreaseAllowance(
        address to,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][to];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), to, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Transfers `amount` tokens from `sender` to `recipient`.
     * @param sender The account to transfer tokens from.
     * @param recipient The account to transfer tokens to.
     * @param amount The amount of tokens to transfer.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(amount > 0, "ERC20: transfer amount zero");
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `account`.
     * @param account The account to assign the newly created tokens to.
     * @param amount The amount of tokens to create.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the total supply.
     * @param account The account to burn tokens from.
     * @param amount The amount of tokens to burn.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Destroys `amount` tokens from the caller's account, reducing the total supply.
     * @param amount The amount of tokens to burn.
     */
    function burn(uint256 amount) external {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `to` over the caller's tokens.
     * @param from The account granting the allowance.
     * @param to The account allowed to spend the tokens.
     * @param amount The amount of tokens to allow.
     */
    function _approve(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: approve from the zero address");
        require(to != address(0), "ERC20: approve to the zero address");

        _allowances[from][to] = amount;
        emit Approval(from, to, amount);
    }
}
