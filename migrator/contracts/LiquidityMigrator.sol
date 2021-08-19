pragma solidity =0.6.6;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./IUniswapV2Pair.sol";
import "./LiquidityIncentiveToken.sol";

contract LiquidityMigrator {
    IUniswapV2Router02 public router;
    IUniswapV2Pair public pair;
    IUniswapV2Router02 public routerFork;
    IUniswapV2Pair public pairFork;
    LiquidityIncentiveToken public liquidityIncentiveToken;
    address public admin;
    mapping(address => uint) public unclaimedBalances;
    bool public migrationDone;

    constructor(
        address _router,
        address _pair,
        address _routerFork,
        address _pairFork,
        address _liquidityIncentiveToken
    ) public {
        router = IUniswapV2Router02(_router);
        pair = IUniswapV2Pair(_pair);
        routerFork = IUniswapV2Router02(_routerFork);
        pairFork = IUniswapV2Pair(_pairFork);
        liquidityIncentiveToken = LiquidityIncentiveToken(_liquidityIncentiveToken);
        admin = msg.sender;
    }


    /* We start off by depositing LP Tokens into our smart contract */
    function deposit(uint amount) external {
        require(migrationDone == false, "tokens already migrated");
        pair.transferFrom(msg.sender, address(this), amount);
        liquidityIncentiveToken.mint(msg.sender, amount); // recieve incentive tokens at a 1:1 rate.
        unclaimedBalances[msg.sender] += amount;
    }

    function migrate() external {
        require(msg.sender == admin, "Only Admin Can Migrate");
        require(migrationDone == false, "tokens already migrated");
        IERC20 token0 = IERC20(pair.token0());
        IERC20 token1 = IERC20(pair.token1());
        uint totalBalance = pair.balanceOf(address(this));
        router.removeLiquidity(
            address(token0),
            address(token1),
            totalBalance, // can specify a minimum amount to withdraw or a maximum
            0,
            0,
            address(this), // smart contract
            block.timestamp
        );

        uint token0Balance = token0.balanceOf(address(this));
        uint token1Balance = token1.balanceOf(address(this));
        // approve smart contract to redeem the tokens and add liquidity to exchange
        token0.approve(address(routerFork), token0Balance);
        token1.approve(address(routerFork), token1Balance);
        routerFork.addLiquidity(
            address(token0),
            address(token1),
            token0Balance,
            token1Balance,
            token0Balance,
            token1Balance,
            address(this), // moves tokens to smart contract
            block.timestamp
        );
        migrationDone = true;
    }
    // saves on gas cost. 
    function claimLptokens() external {
        require(unclaimedBalances[msg.sender] > 0, "no unclaimed balance for the specified address");
        require(migrationDone = true, "migration is not completed yet");
        uint amountToSend = unclaimedBalances[msg.sender];
        unclaimedBalances[msg.sender] = 0;
        pairFork.transfer(msg.sender, amountToSend);
    }
}