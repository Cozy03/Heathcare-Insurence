const MyERC20 = artifacts.require("ERC20");
const Insurence = artifacts.require("Insurence");

module.exports = async function(deployer) {
	// deploy the first
	deployer.deploy(MyERC20);
	
	// get the owner address
	const accounts = await web3.eth.getAccounts();
	const owner = accounts[1];
	// deploy the second, with address parameter
	deployer.deploy(Insurence, owner);
};