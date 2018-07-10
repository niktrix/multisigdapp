<template>

  <div class="dashboard">
    <h1>{{ msg }} Address:  {{this.contractaddress}}</h1>
    <div v-if="isaccepting">
      This Contract is  {{ pseudo }}.
    </div>

    <div v-if="accepting">
      <h1>Contributors</h1>
      {{this.contributors}}

      <input v-model="amount" placeholder="Wei">
      <button  v-on:click="contribute" >Contribute</button>
    </div>

 <div v-if="isSigner">
         You are one of the signer

    <div v-if="accepting">
            <button  v-on:click="endcontribution()">End Contribution Period</button>
    </div>

      <div v-if="!accepting">

         <h1>Proposals</h1>
          {{this.proposals}}

      <input v-model="proposalamount" placeholder="Wei">
      <button  v-on:click="propose" >Contribute</button>


    </div>


 </div>
    <div  >{{signers}} <router-link to="/signup">here</router-link>.</div>
  </div>

</template>



<script>
// import Users from '@/js/users'
import MultiSig from '@/js/multisig'

export default {
  name: 'dashboard',
  data () {
    return {
      msg: 'Multisig Contract',
      accepting: false,
      isSigner: false,
      amount: 0,
      proposalamount: 0,
      signers: [],
      contributors: [],
      contractaddress: 'address',
      proposals: [],

      pseudo: undefined
    }
  },
  computed: {
    isaccepting: function () {
      return (typeof this.pseudo !== 'undefined')
    }
  },
  beforeCreate: function () {
    MultiSig.init().then(() => {
      MultiSig.isInContributionPeriod(window.web3.eth.accounts[0]).then((exists) => {
        this.accepting = exists
        if (exists) {
          this.pseudo = 'Accepting Contribution'
        } else {
          this.pseudo = 'Not Accepting Contribution'
        }
        MultiSig.isSigner(window.web3.eth.accounts[0]).then((signer) => {
          this.isSigner = signer
          console.log('signer', signer)
        })
        // MultiSig.getAllSigners().then((signers) => {
        //   this.signers = signers
        // })
        MultiSig.listenevents()
        this.getContributors()
        this.getContractAddress()
      })
    }).catch(err => {
      console.log('error calling MultiSig.isInContributionPeriod', err)
    })
  },
  created: function () {
  },
  methods: {
    destroyAccount: function (e) {
      e.preventDefault()
      // Users.destroy().then(() => {
      //   this.pseudo = undefined
      // }).catch(err => {
      //   console.log(err)
      // })
    },
    endcontribution: function () {
      console.log('endcontribution')
      MultiSig.endContributionPeriod().then(() => {
        console.log('ended')
      })
    },

    getContributors: function () {
      console.log('endcontribution')
      MultiSig.getContributers().then((cont) => {
        this.contributors = cont
        console.log('ended')
      })
    },

    // getProposals: function () {
    //   console.log('endcontribution')
    //   MultiSig.getContributers().then((cont) => {
    //     this.contributors = cont
    //     console.log('ended')
    //   })
    // },

    getContractAddress: function () {
      console.log('endcontribution')
      MultiSig.getContractAddress().then((cont) => {
        this.contractaddress = cont
        console.log('getContractAddress')
      })
    },

    getProposals: function () {
      console.log('getProposals')
      MultiSig.listOpenProposals().then((cont) => {
        this.proposals = cont
        console.log('listOpenProposals')
      })
    },

    contribute: function (e) {
      e.preventDefault()
      console.log('amount', this.amount)
      MultiSig.contribute(this.amount)
    },

    propose: function (e) {
      e.preventDefault()
      console.log('proposeamount', this.proposalamount)
      MultiSig.submitproposal(this.proposalamount)
    }

  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h1, h2 {
  font-weight: normal;
  display: block;
}

ul {
  list-style-type: none;
  padding: 0;
}

li {
  display: inline-block;
  margin: 0 10px;
}

a {
  color: #42b983;
}
</style>
