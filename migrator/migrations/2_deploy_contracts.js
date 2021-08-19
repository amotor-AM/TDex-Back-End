const LiquidityIncentiveToken = artifacts.require("LiquidityIncentiveToken.sol");
const LiquidityMigrator = artifacts.require("LiquidityMigrator.sol");

module.exports = async function(deployer) {
  await deployer.deploy(LiquidityIncentiveToken);
  const token = await LiquidityIncentiveToken.deployed();
  // unsiwap address
  const routerAddress = "";
  const pairAddress = "";
  // smart contract address
  const routerForkAddress = "";
  const pairForkAddress = "";

  await deployer.deploy(
      LiquidityMigrator,
      routerAddress,
      pairAddress,
      routerForkAddress,
      pairForkAddress,
      token.address
  )

  const liquidityMigrator = await LiquidityMigrator.deployed();
  await token.setLiquidator(liquidityMigrator.address);
};
