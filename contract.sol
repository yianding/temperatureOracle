// SPDX-License-Identifier: MIT
pragma solidity >=0.5.17 <0.6.0;

contract TemperatureOracle {
    //post_data include two members ,participantsAddress 
    //is the wallet address of who upload the temperature data
    struct post_data{
        address participantsAddress;
        int16 temperature;
    }
    //Minimum_Participants specifies how many people are required
    // to upload data to be valid. For data below this upload number,
    // you need to wait for other participants to upload data
    uint16 Minimum_Participants;

    //Every voter will consume the voting fee (Ethereum) in the deposit 
    //every time they vote. If the temperature data uploaded by the voter exceeds
    // a valid range, then you are a vote loser, and the vote loser will lose the money.
    // On the contrary, if your voting data is within the valid range, 
    //then you become the winner of this round of voting and will share the money 
    //lost by the loser with other winners.
    uint Vote_Fee;

    //All uploaded data are stored in allData,
    post_data[] public allData;

    //This is a multidimensional array in the format: 
    //post_temperature["202206021402"]["Changsha"] 
    //202206021402 means 14:02 june 2,2022
    //Changsha means changsha city.
    //post_temperature["202206021402"]["Changsha"] return a uint array,
    //every element indicate the index of allData
    mapping(string => mapping(string => uint[]) )public post_temperature;
    
    //Every uploader(voter) need deposit some ETH to ensure they do not upload malicious data
    mapping(address=>uint) public deposit;
   
 
    //When creating a smart contract, 
    //you need to specify a minimum number of participants. 
    //and the cost of each vote.

     constructor(uint16 _mini_Participants,uint _Vote_Fee) public {
        require(_mini_Participants>=3,"Construct Error");
     
        Minimum_Participants = _mini_Participants;
        Vote_Fee=_Vote_Fee;
    } 
    //Every one can join the contract as voter(Participant,uploader),if your deposit balance 
    //less than 1 ETH, you will can not vote(post data) anymore.so need call this function
    //to increate your depoist balance.
    function Deposit() public payable {
       deposit[msg.sender]+=msg.value; 
    }
    //withdraw all cryptocurrency from depoist account.
    function Withdraw() public {
       if(deposit[msg.sender]>0){
        msg.sender.transfer(deposit[msg.sender]);
       }
    }
   
    //setTemperature:
    //argument: 
    // date_time is a string ,indicate the date and time,such as 202206021404 it means 14:04 2 June,2022
    // temperature, 1345 is 13.45 Celsius,-1423 is -14.23 Celsius
    function setTemperature(string memory date_time,string memory place,int16 temperature) public {
        require(deposit[msg.sender]>=1000000000000000000,"Your deposit balance less than 1 ETH");
        require(post_temperature[date_time][place].length<Minimum_Participants,"Participants more than minimum participants");
       
        //Voting fee is deducted from deposit balance
        deposit[msg.sender]-=Vote_Fee;

        //Save the temperature to allData array.
        allData.push(post_data(msg.sender,temperature));
        
        //save the index of allData into post_temperature.
        post_temperature[date_time][place].push(allData.length -1);

        //if post_temperature[][].length equal Minimum_Participants ,
        //This means  this round of voting is over. Profits and 
        //losses for winners and losers need to be calculated.
        if (post_temperature[date_time][place].length==Minimum_Participants){


         //Start to calculate the final temperature value of this round , 
         //remove a highest value and a lowest value,
         // and then take the arithmetic mean as the final temperature value. 
         int  temp=0;
         int16  max=-32768;
         int16  min= 32767;
         for (uint i=0;i<post_temperature[date_time][place].length; i++) {
           if(allData[post_temperature[date_time][place][i]].temperature>max){
               max=allData[post_temperature[date_time][place][i]].temperature;
           }
           if(allData[post_temperature[date_time][place][i]].temperature<min){
               min=allData[post_temperature[date_time][place][i]].temperature;
           }
           temp +=allData[post_temperature[date_time][place][i]].temperature;
         }
      
       int finalTemperature=(temp-max-min)/(Minimum_Participants-2);
     

        //Calculate the number of winners in this round of voting. 
        //If the error between the voting temperature value and the final temperature 
        //value calculated earlier is within 5%, 
        //then you are the winner. Winners can share the vote fee of losers
        uint16  winners=0;
        for (uint i=0;i<post_temperature[date_time][place].length; i++) {
         
             if(allData[post_temperature[date_time][place][i]].temperature*100<finalTemperature*105 
             &&
             allData[post_temperature[date_time][place][i]].temperature*100>finalTemperature*95 ){
             winners++;
             }

        }
        //Increase the balance on the winner's deposit account.
       for (uint i=0;i<post_temperature[date_time][place].length; i++) {
         
             if(allData[post_temperature[date_time][place][i]].temperature*100<finalTemperature*105 
             &&
             allData[post_temperature[date_time][place][i]].temperature*100>finalTemperature*95 ){
            
             address  ParticipantsAddress=allData[post_temperature[date_time][place][i]].participantsAddress;
             deposit[ParticipantsAddress]+=(Minimum_Participants-winners)*Vote_Fee/winners;
             }

        }

     }
      
    }
    
    function getTemperature(string memory date_time,string memory place)  public  view returns(int temperature)
    {   
        require(post_temperature[date_time][place].length==Minimum_Participants,"Participants less than minimum participants ");
         int  tempresult=0;
         int16  max=-32768;
         int16  min= 32767;
         for (uint i=0;i<post_temperature[date_time][place].length; i++) {
           if(allData[post_temperature[date_time][place][i]].temperature>max){
               max=allData[post_temperature[date_time][place][i]].temperature;
           }
           if(allData[post_temperature[date_time][place][i]].temperature<min){
               min=allData[post_temperature[date_time][place][i]].temperature;
           }
           tempresult =  tempresult+ allData[post_temperature[date_time][place][i]].temperature;
         }
         
         return (tempresult-max-min)/(Minimum_Participants-2);
    }
  
}