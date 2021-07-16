var CleverWizardToken = artifacts.require("./CleverWizardToken");
var Call = artifacts.require("./CallOption");
var Put = artifacts.require("./PutOption");


module.exports = async function(deployer) {
    await deployer.deploy(CleverWizardToken);
    //    await deployer.deploy(Call);
    //    await deployer.deploy(Put);
};