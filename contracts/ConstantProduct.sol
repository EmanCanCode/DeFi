// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract ConstantProduct {
    // ----- STATE VARIABLES ----- //

    // The two tokens that are being pooled
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;
    // Keep track of the reserves of each token
    uint public reserveA;  // reserves of tokenA
    uint public reserveB;  // reserves of tokenB
    // Keep track of the total supply of the LP tokens (created or burned)
    uint public totalSupply;  
    // keep track of the LP tokens owned by each address
    mapping(address => uint) public balanceOf;  


    // ----- CONSTRUCTOR ----- //

    // The constructor sets the two tokens that are being pooled
    constructor(
        IERC20 _tokenA, 
        IERC20 _tokenB
    ) {  // underscore is used to differentiate between the state variable and the local variable
        tokenA = _tokenA;
        tokenB = _tokenB;
    }


    // ----- PRIVATE FUNCTIONS ----- //

    /// @notice Adds liquidity to the pool, minting @param _amount of LP tokens and assigning them to the @param _to address
    function _mint(address _to, uint _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    /// @notice Removes liquidity to the pool, burning @param _amount of LP tokens and removing them from the @param _from address
    function _burn(address _from, uint _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

}