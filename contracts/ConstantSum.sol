// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ConstantSum {
    // ----- STATE VARIABLES ----- //

    // The two tokens that are being pooled
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;
    // Owner of address
    address public immutable owner;
    // Keep track of the reserves of each token
    uint public reserveA; // reserves of tokenA
    uint public reserveB; // reserves of tokenB
    // Keep track of the total supply of the LP tokens (created or burned)
    uint public totalSupply;
    // keep track of the LP tokens owned by each address
    mapping(address => uint) public balanceOf;

    // ----- CONSTRUCTOR ----- //

    constructor(IERC20 _tokenA, IERC20 _tokenB) {
        owner = msg.sender;
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    // ----- EVENTS ----- //

    event AddedLiquidity(address indexed to, uint amount);
    event RemovedLiquidity(address indexed from, uint amount);
    event Swapped(
        address indexed from,
        address indexed to,
        uint amountReceived,
        uint amountReturned
    );

    // ----- PRIVATE FUNCTIONS ----- //
    function _mint(address _to, uint _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address _from, uint _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    function _update(uint _reserveA, uint _reserveB) private {
        reserveA = _reserveA;
        reserveB = _reserveB;
    }

    // ----- EXTERNAL FUNCTIONS ----- //

    function swap(
        address _tokenReceived,
        uint _amountReceived
    ) external returns (uint amountReturned) {
        // Ensure that the token is in the pair - no other tokens can be swapped using this contract
        require(
            _tokenReceived == address(tokenA) || _tokenReceived == address(tokenB),
            "Token not in pair"
        );
        // Ensure that the amount received is greater than 0, dont want to swap 0 tokens
        require(_amountReceived > 0, "Amount must be greater than 0");
        
        // receive the tokens
        uint amountReceived;
        if (_tokenReceived == address(tokenA)) {
            tokenA.transferFrom(msg.sender, address(this), _amountReceived);
            amountReceived = tokenA.balanceOf(address(this)) - reserveA;
        } else {
            tokenB.transferFrom(msg.sender, address(this), _amountReceived);
            amountReceived = tokenB.balanceOf(address(this)) - reserveB;
        }

        // calculate the amount to return, with standard fee of 0.3%
        // dx = dy
        amountReturned = (amountReceived * 997) / 1000;
        
        // Update reserves and transfer the tokens
        if (_tokenReceived == address(tokenA)) {
            _update(reserveA + amountReceived, reserveB - amountReturned);
            tokenB.transfer(msg.sender, amountReturned);
        } else {
            _update(reserveA - amountReturned, reserveB + amountReceived);
            tokenA.transfer(msg.sender, amountReturned);
        }

        emit Swapped(_tokenReceived, _tokenReceived == address(tokenA) ? address(tokenB) : address(tokenA), amountReceived, amountReturned);
    }

    function addLiquidity() external {}
    function removeLiquidity() external {}
}
