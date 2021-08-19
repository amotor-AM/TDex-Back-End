pragma solidity =0.6.6;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LiquidityIncentiveToken is ERC20 {
    address public admin;
    address public liquidator;
    constructor() ERC20("TDex Token", "TDX") public {
        admin = msg.sender;
    }

    function setLiquidator(address _liquidator) external {
        require(msg.sender == admin, "Only Admin Can Call The Liquidator");
        liquidator = _liquidator;
    }

    function mint(address to, uint amount) external {
        require(msg.sender == liquidator, "Only Liquidator Can Mint Tokens");
        _mint(to, amount);
    }
}