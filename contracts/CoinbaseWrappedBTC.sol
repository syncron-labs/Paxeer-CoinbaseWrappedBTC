// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract CoinbaseWrappedBTC is ERC20, ERC20Burnable, Ownable, Pausable {
    mapping(address => bool) public bridgeOperators;
    mapping(address => uint256) public mintingLimits;
    mapping(address => uint256) public mintedAmounts;
    
    event BridgeOperatorAdded(address indexed operator);
    event BridgeOperatorRemoved(address indexed operator);
    event MintingLimitSet(address indexed account, uint256 limit);

    constructor(address initialOwner) ERC20("Coinbase Wrapped BTC", "cbBTC") Ownable(initialOwner) {}

    function decimals() public pure override returns (uint8) {
        return 8;
    }

    function mint(address to, uint256 amount) external {
        require(bridgeOperators[msg.sender] || msg.sender == owner(), "Not authorized");
        
        if (msg.sender != owner() && mintingLimits[msg.sender] > 0) {
            require(mintedAmounts[msg.sender] + amount <= mintingLimits[msg.sender], "Exceeds limit");
            mintedAmounts[msg.sender] += amount;
        }
        
        _mint(to, amount);
    }

    function addBridgeOperator(address operator) external onlyOwner {
        bridgeOperators[operator] = true;
        emit BridgeOperatorAdded(operator);
    }

    function removeBridgeOperator(address operator) external onlyOwner {
        bridgeOperators[operator] = false;
        emit BridgeOperatorRemoved(operator);
    }

    function setMintingLimit(address account, uint256 limit) external onlyOwner {
        mintingLimits[account] = limit;
        emit MintingLimitSet(account, limit);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
