const AnimalToken = artifacts.require("AnimalToken");

const Accounts = artifcats.require ("Accounts")

    

module.exports = function(deployer){
    deployer.deploy(Accounts)
    .then(() => {return deployer.deploy(AnimalToken, Accounts.address)});

}