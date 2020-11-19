const Tracing = artifacts.require("Tracing");

module.exports = function(deployer){
    deployer.deploy(Tracing);
}