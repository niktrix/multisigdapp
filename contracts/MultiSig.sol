pragma solidity ^0.4.4;
contract Multisig {

  event ReceivedContribution(address indexed _contributor, uint _valueInWei);
  event ProposalSubmitted(address indexed _beneficiary, uint _valueInWei);
  event ProposalApproved(address indexed _approver, address indexed _beneficiary, uint _valueInWei);
  event ProposalRejected(address indexed _approver, address indexed _beneficiary, uint _valueInWei);
  event WithdrawPerformed(address indexed _beneficiary, uint _valueInWei);
  event ContributionPeriodIsrunning();
  event SubmitContribution();


  //events
event BalanceContract(address indexed _beneficiary, uint _valueInWei, uint _calculated10percent);




  //mapping (uint => proposals) public proposals;
  bool public isAccepting = true ;
  mapping (address => bool) public isSigner;
  address[] public signers;
  address public owner;

  address public contractaddress;

   mapping (address => uint) public contributers_balance;
   address[] public contributers;


   mapping (address => Proposal) public allProposals;

   struct Proposal {
        address owner;
        uint value;
         bool executed;
        address[] approved;
        address[] rejected;
        mapping(address=>bool) voted;

     }


     function listOpenBeneficiariesProposals() external view returns (address[]){
       address[]  storage listOpenBeneficiariesProposals;
         for (uint i=0; i<contributers.length; i++) {
             if(allProposals[contributers[i]].approved.length+allProposals[contributers[i]].rejected.length<2){
                 listOpenBeneficiariesProposals.push(allProposals[contributers[i]].owner);
             }
        }

        return listOpenBeneficiariesProposals;
     }



  constructor(address[] _signers) {
      contractaddress = address(this);
      owner = msg.sender;
         for (uint i=0; i<_signers.length; i++) {
            if (isSigner[_signers[i]] || _signers[i] == 0)
                revert();
            isSigner[_signers[i]] = true;
        }
        signers = _signers;
    }

  function endContributionPeriod() external{
     require(isSigner[msg.sender],"need signer to end");
      isAccepting = false;

  }

   modifier isInContributionPeriod() {
        if (isAccepting)
             revert();
        _;
    }

     modifier isNotInContributionPeriod() {
        if (!isAccepting)
             revert();
        _;
    }

      ///  Fallback function allows to deposit ether.
    function() payable
    {
        if(!isAccepting){
            revert();
        }
        if (msg.value > 0){
            //push only if contributer is not already in that array
            if(contributers_balance[msg.sender] == 0)
            {
                contributers.push(msg.sender);

            }

             if(contributers_balance[msg.sender] > 0)
            {
             contributers_balance[msg.sender] = contributers_balance[msg.sender]+msg.value;

            }else{
             contributers_balance[msg.sender] = msg.value;

            }

         emit ReceivedContribution(msg.sender, msg.value);
    }
    }

        function submitProposal(uint _valueInWei) external  {
            // only contributer can send the Proposal
         emit   SubmitContribution();
         //dont allow to add one more proposal
            require(allProposals[msg.sender].value == 0);
            require(contributers_balance[msg.sender]>=_valueInWei);
            // propasal value should be equal or less than 10% of available balance
            uint balanceshouldbelessthan = address(this).balance/10;
            require(_valueInWei<= balanceshouldbelessthan);
             allProposals[msg.sender] = Proposal({
             owner:msg.sender,



        //   withdrawhistory:null;
          approved:new address[](0),
          rejected:new address[](0),



             value: _valueInWei,
             executed: false

        });
  emit ProposalSubmitted(msg.sender,  _valueInWei);
  emit BalanceContract(address(this) ,address(this).balance , balanceshouldbelessthan);

       }


     function listContributors() external view returns (address[]){
          return contributers;
     }

     function getBeneficiaryProposal(address _beneficiary) external view returns (uint){
         return allProposals[_beneficiary].value;
     }

     function getContributorAmount(address _contributor) external view returns (uint){
        return contributers_balance[_contributor];
     }

     function withdraw(uint _valueInWei) external {

         //count votes

         //check if all has given votes
        // require((allProposals[msg.sender].approved.length + allProposals[msg.sender].rejected.length)==3);


         require(allProposals[msg.sender].owner!=0,'No proposal exist of this sender');

         require(allProposals[msg.sender].executed==true,"proposal is still in voting or not approved");
         require(allProposals[msg.sender].value >= _valueInWei ,"this amount is not approved");

         allProposals[msg.sender].executed = true;

         uint newvalue =  allProposals[msg.sender].value -_valueInWei;
         allProposals[msg.sender].value =newvalue;

         msg.sender.call.value(_valueInWei);

        emit WithdrawPerformed(msg.sender,  _valueInWei);



     }



      function approve(address _beneficiary) external  {
            if(isAccepting){
            revert();
        }
          require(isSigner[msg.sender],"need signer to approve");
          //should not be already voted
           require(allProposals[_beneficiary].voted[msg.sender]==false,"already voted") ;
           require(allProposals[_beneficiary].executed==false,"already have maximim vote");
           allProposals[_beneficiary].approved.push(msg.sender);

            //check if all has given votes
         if((allProposals[_beneficiary].approved.length + allProposals[_beneficiary].rejected.length)>=2){

              if(allProposals[_beneficiary].approved.length>allProposals[_beneficiary].rejected.length){
                  allProposals[_beneficiary].executed = true;
              }

              if(allProposals[_beneficiary].approved.length<allProposals[_beneficiary].rejected.length){
                  allProposals[_beneficiary].executed = false;
              }
         }





     emit ProposalApproved(msg.sender, _beneficiary, allProposals[_beneficiary].value);


      }
     function reject(address _beneficiary) external  {
           if(isAccepting){
            revert();
        }

         require(isSigner[msg.sender]);

            require(allProposals[_beneficiary].voted[msg.sender]==false,'already voted') ;
           require(allProposals[_beneficiary].executed==false,"already got maximum votes");
           allProposals[_beneficiary].rejected.push(msg.sender);

            if((allProposals[_beneficiary].approved.length + allProposals[_beneficiary].rejected.length)>=2){

              if(allProposals[_beneficiary].approved.length>allProposals[_beneficiary].rejected.length){
                  allProposals[_beneficiary].executed = true;
              }

              if(allProposals[_beneficiary].approved.length<allProposals[_beneficiary].rejected.length){
                  allProposals[_beneficiary].executed = false;
              }
         }


        emit ProposalRejected(msg.sender, _beneficiary, allProposals[_beneficiary].value);

     }

     }







