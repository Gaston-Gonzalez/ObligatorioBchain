const AnimalToken = artifacts.require("AnimalToken");

module.exports = function(deployer){
    deployer.deploy(AnimalToken);
}