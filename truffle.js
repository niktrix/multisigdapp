// Allows us to use ES6 in our migrations and tests.
require('babel-register')
var HDWalletProvider = require("truffle-hdwallet-provider");


var mnemonic = "<SEED WORDS>";


module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      gas: 1000000014712388,
      network_id: "*" // Match any network id
    },
    rinkeby: {
      provider: () => {return new HDWalletProvider(mnemonic,"https://rinkeby.infura.io")},
      port: 8545,
      network_id: '*' // Match any network id
    }

  }
};
