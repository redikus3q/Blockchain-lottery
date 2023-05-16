async function main() {
  const LotteryContract = await ethers.getContractFactory("LotteryContract");

  // Start deployment, returning a promise that resolves to a contract object
  const lottery = await LotteryContract.deploy();
  console.log("Contract deployed to address:", lottery.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
