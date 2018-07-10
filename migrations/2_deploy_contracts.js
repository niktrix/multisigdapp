var Multisig = artifacts.require("./MultiSig.sol");


module.exports = function(deployer) {
  // deployer.deploy(Multisig,["0xC25Fb8E6AA8E5888fdDBca1AA9B48bCccb4ce324"]);
  deployer.deploy(Multisig);

};
