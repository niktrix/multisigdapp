<template>
  <v-container grid-list-md text-xs-center>
        <v-layout row wrap>


    <h1>{{ msg }} Balance:  {{this.contractbalance}}</h1>

 <v-flex xs6>

    <h1>Contributors</h1>
       <div v-for="item in contributors" >
           <div>{{item}}   </div>
       </div>


          <div v-if="isaccepting" xs6>

      Contract is accepting contributions
      <br>

      <v-text-field xs6 v-model="amount" placeholder="Wei" label="Amount to contribute"></v-text-field>
      <v-btn xs6 color="yellow" v-on:click="contribute" >Contribute</v-btn>
    </div>

  </v-flex>


  <v-flex xs6>

  </v-flex>


  <v-form>

  <div class="dashboard">






      <!-- <div v-if="!accepting"> -->
      <div v-if="!isaccepting">
              Contract is not  accepting contributions

          <h1>Proposals</h1>
          {{this.proposals}}
          <br>

          <v-text-field v-model="proposalamount" placeholder="Wei" label="Proposal amount"></v-text-field>
          <v-btn color="orange"  v-on:click="propose()" >Propose</v-btn>

      </div>

      <div  v-if="isSigner">
        <h1>Signers</h1>
         You are one of the signer
         <br>
            <div v-if="isaccepting">
                  <v-btn  color="red" v-on:click="endcontribution()">End Contribution Period</v-btn>
                  <br>
            </div>

            <div v-if="!isaccepting">
                <v-text-field v-model="acceptaddress" placeholder="address" label="Adress to approve"></v-text-field>
                <v-btn color="blue" v-on:click="accept()" >Approve</v-btn>
                <br>
                <v-text-field v-model="rejectaddress" placeholder="address" label="Adress to Reject"></v-text-field>
                <v-btn color="blue" v-on:click="reject()" >Reject</v-btn>
          </div>

      </div>

      <div v-if="!isaccepting" >
            <h1>Withdraw</h1>
            <v-text-field v-model="withdrawamount" placeholder="withdraw amount in wei"></v-text-field>
            <v-btn color="green"  v-on:click="withdraw()" >Withdraw</v-btn>

      </div>


          <h1>Event Logs</h1>

        <div v-for="item in events" >
              <div>{{item.event}}  {{item.args}} </div>

          <!-- content -->
        </div>


</div>
  </v-form>
      </v-layout>

  </v-container>

</template>



<script>
// import Users from '@/js/users'
import MultiSig from '@/js/multisig'

export default {
  name: 'dashboard',
  data () {
    return {
      msg: 'Multisig Contract',
      accepting: '',
      isSigner: false,
      amount: 0,
      proposalamount: 0,
      signers: [],
      rejectaddress: '',
      acceptaddress: '',
      contractbalance: '',
      contributors: [],
      contractaddress: 'address',
      proposals: [],
      events: [],
      withdrawamount: [],

      pseudo: undefined
    }
  },
  computed: {
    isaccepting: function () {
      return (this.accepting === '0')
    }
  },
  beforeCreate: function () {
    MultiSig.init().then(() => {
      MultiSig.isInContributionPeriod(window.web3.eth.accounts[0]).then((exists) => {
        this.accepting = exists.toString(10)
        console.log('accepting', exists.toString(10))
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
        MultiSig.listenevents(this.event)
        this.reload()
        this.getContributors()
        this.getProposals()
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

    reload: function () {
      this.getContractAddress()
      // this.getContributorAmount()
      // this.getProposals()
      this.getContractBalance()
    },

    endcontribution: function () {
      console.log('endcontribution')
      MultiSig.endContributionPeriod().then(() => {
        console.log('ended')
      })
    },

    getContributors: async function () {
      console.log('endcontribution')
      MultiSig.getContributers().then((cont) => {
        for (var i = 0; i <= cont.length - 1; i++) {
          console.log('add====', cont[i])
          MultiSig.getContributorAmount(cont[i]).then((amt) => {
            var ad = cont[i]
            this.contributors.push({'address': amt.address, 'contribution': amt.amt})
            console.log('cont.Valueof()', ad)
          })
        }
        console.log('ended')
      })
    },

    getContributorAmount: function () {
      var _this = this
      console.log('-----', _this.contributors)
      for (var i = 0; i <= _this.contributors.length - 1; i++) {
        console.log('this.cont', this.contributors)
        MultiSig.getContributorAmount(this.contributors[i].address).then((cont) => {
          console.log('cont.Valueof()', cont.Valueof())
          _this.contributors[i].amount = 90
          console.log('this.cont', this.contributors)
        })
      }
      console.log('getContributorAmount')
    },

    getContractAddress: function () {
      console.log('endcontribution')
      MultiSig.getContractAddress().then((cont) => {
        this.contractaddress = cont
        console.log('getContractAddress')
      })
    },

    getContractBalance: function () {
      console.log('getContractBalance')
      MultiSig.getContractBalance().then((cont) => {
        this.contractbalance = cont
        console.log('getContractBalance')
      })
    },

    getProposals: function () {
      console.log('getProposals')
      var _this = this
      MultiSig.listOpenProposals().then((cont) => {
        // this.proposals = cont
        console.log('listOpenProposals', cont)
        for (var i = 0; i <= cont.length - 1; i++) {
          console.log('this.cont proposals', cont)
          MultiSig.getProposalstruct(cont).then((p) => {
            _this.proposals.unshift({address: p[0], amount: p[1], approve: p[2], reject: p[3]})
            console.log('getProposalstruct', p)
          })
        }
      })
    },

    contribute: function (e) {
      e.preventDefault()
      console.log('amount', this.amount)
      MultiSig.contribute(this.amount)
    },

    propose: function () {
      console.log('proposeamount', this.proposalamount)
      MultiSig.submitproposal(this.proposalamount)
    },

    accept: function () {
      console.log('approve', this.acceptaddress)
      MultiSig.approve(this.acceptaddress)
    },

    event: function (err, ev) {
      console.log(err, ev)
      this.events.unshift(ev)
      //  this.reload()
    },

    reject: function () {
      console.log('reject', this.rejectaddress)
      MultiSig.reject(this.rejectaddress)
    },

    withdraw: function () {
      console.log('withdraw', this.withdrawamount)
      MultiSig.withdraw(this.withdrawamount)
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
