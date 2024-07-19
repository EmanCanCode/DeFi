// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "./ConstantProduct.sol";

contract ContantProductFactory {
    // ----- STATE VARIABLES ----- //

    // owner of contract
    address public owner;
    // fee for creating a new pool
    uint public fee; 
    // mapping of all pools created
    mapping(address => mapping(address => address)) public pools;
    bool public noReentrantLocked;

    // ----- CONSTRUCTOR ----- //

    constructor(uint _fee) {
        fee = _fee;
        owner = msg.sender;
    }

    // ----- EVENTS ----- //

    event PoolCreated(address indexed tokenA, address indexed tokenB, address pool);

    // ----- MODIFIERS ----- //

    modifier noReentrant() {
        require(!noReentrantLocked, "Reentrant call");
        noReentrantLocked = true;
        _;
        noReentrantLocked = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    // ----- EXTERNAL FUNCTIONS ----- //

    function createPool(
        address _tokenA,
        address _tokenB
    ) external payable noReentrant() {
        require(getPool(_tokenA, _tokenB) == address(0), "Pool already exists");
        require(msg.value >= fee, "Insufficient fee");
        // create new pool
        ConstantProduct newPool = new ConstantProduct(IERC20(_tokenA), IERC20(_tokenB));
        address poolAddress = address(newPool);
        require(poolAddress != address(0), "Invalid pool address");

        // set pool address in mapping
        pools[_tokenA][_tokenB] = poolAddress;
        // emit event
        emit PoolCreated(_tokenA, _tokenB, poolAddress);
    }

    // ----- VIEW FUNCTIONS ----- //

    function getPool(address _tokenA, address _tokenB) public view returns (address) {
        // if tokenA/tokenB pool exists, return it, else return tokenB/tokenA pool
        // this will let me find the pool address regardless of the order of the tokens
        return pools[_tokenA][_tokenB] != address(0) ? pools[_tokenA][_tokenB] : pools[_tokenB][_tokenA];
    }

    // ----- OWNER FUNCTIONS ----- //
    
    function setFee(uint _fee) external onlyOwner() {
        fee = _fee;
    }

    function withdrawEth() external onlyOwner() noReentrant() {
        // give owner ethereum balance from this contract
        payable(owner).transfer(address(this).balance);
    }

    function withdrawToken(address _token) external onlyOwner() noReentrant() {
        // give owner token balance from this contract
        IERC20 token = IERC20(_token);
        token.transfer(owner, token.balanceOf(address(this)));
    }
}