<template>
    <div id="BuyForm">
        <h2> You can buy options here </h2>
        <form class="form_radio">
            <div>
                <input type="radio" id="choiceCall" v-model="choice" name="optionType" value="choiceCall" checked>
                <label for="choiceCall">Call Option</label>
                
                <input type="radio" id="choicePut" v-model="choice" name="optionType" value="choicePut">
                <label for="choicePut">Put Option</label>
            </div>
        </form>

        <div v-if="this.choice == 'choiceCall'">
            <div>
                <label for="callOptionAddress" class="label_lg" > Enter Call Option contract's address </label>
                <input type="text" id="callOptionAdress" name="callOptionAddress" v-model.lazy.trim="callOptionAddress" class="input_text" @change="changeCallOptionAddress"/>
            </div>
            <button class="buy_form_btn" type="button" @click="getCallOptionDetails"  @unhandledrejection="handleError(event)">Get Details of the Option!</button>
            <div v-if="this.callOptionToPage == true">
                <p> Call Option quantity is : {{this.callOptionQuantity}} tokens </p>
                <p> Call Option Strike Price is : {{web3.utils.fromWei(this.callOptionStrikePrice, 'ether')}} ETH/token</p>
                <p> Call Option Purchase Price is : {{web3.utils.fromWei(this.callOptionPurchasePrice, 'ether')}} ETH</p>
                <p> Call Option Expiry Time is : {{this.callOptionExpiryTime}} </p>
                <p> Call Option is {{this.callOptionWasCollateralized}} collateralized </p>
                <p> Call Option is {{this.callOptionWasPurchased}} purchased </p>            
            </div>
            <button class="buy_form_btn" type="button" @click="buyCallOption" v-if="this.callOptionToPage == true">Buy Call Option!</button>
        </div>

        <div v-if="this.choice == 'choicePut'">
            <div>
                <label for="putOptionAddress" class="label_lg"> Enter Put Option contract's address </label>
                <input type="text" id="putOptionAdress" name="putOptionAddress" v-model.lazy.trim="putOptionAddress" class="input_text" @change="changePutOptionAddress"/>        
            </div>
            <button class="buy_form_btn" type="button" @click="getPutOptionDetails">Get Details of the Option!</button>
            <div v-if="this.putOptionToPage == true">
                <p> Put Option quantity is : {{this.putOptionQuantity}} tokens </p>
                <p> Put Option Strike Price is : {{web3.utils.fromWei(this.putOptionStrikePrice, 'ether')}} ETH/token</p>
                <p> Put Option Purchase Price is : {{web3.utils.fromWei(this.putOptionPurchasePrice)}} ETH</p>
                <p> Put Option Expiry Time is : {{this.putOptionExpiryTime}} </p>
                <p> Put Option is {{this.putOptionWasCollateralized}} collateralized </p>
                <p> Put Option is {{this.putOptionWasPurchased}} purchased </p>            
            </div>
            <button class="buy_form_btn" type="button" @click="buyPutOption" v-if="this.putOptionToPage == true">Buy Put Option!</button>
        </div>
    </div>
</template>


<script>

import getWeb3 from "../getWeb3.js";
import CallOption from "../contracts/CallOption.json";
import PutOption from "../contracts/PutOption.json";

export default {

    created() {
        this.$store.commit('initialiseStore');
        this.callOptionAddress = this.$store.state.callOptionAddress;
        this.putOptionAddress = this.$store.state.putOptionAddress;
    },
    async mounted() {
        this.web3 = await getWeb3();
        this.networkId = await this.web3.eth.getChainId();
        this.accounts = await this.web3.eth.getAccounts();
        this.callOption = await new this.web3.eth.Contract(
            CallOption.abi,
            CallOption.networks[this.networkId] && CallOption.networks[this.networkId].address,
        );
        this.putOption = await new this.web3.eth.Contract(
            PutOption.abi,
            PutOption.networks[this.networkId] && PutOption.networks[this.networkId].address,
        );
    },
    data() {
        return {
            choice: "choiceCall",
            callOptionAddress: "",
            putOptionAddress: "",
            callOptionQuantity: "",
            callOptionStrikePrice: "",
            callOptionPurchasePrice: "",
            callOptionExpiryTime: "",
            callOptionWasCollateralized: "not",
            callOptionWasPurchased: "not",
            putOptionQuantity: "",
            putOptionStrikePrice: "",
            putOptionPurchasePrice: "",
            putOptionExpiryTime: "",
            putOptionWasCollateralized: "not",
            putOptionWasPurchased: "not",
            callOptionToPage: false,
            putOptionToPage: false,
        };
    },
    methods: {
        changeCallOptionAddress() {
            this.$store.commit('setCallOptionAddress', this.callOptionAddress);
        },
        changePutOptionAddress() {
            this.$store.commit('setPutOptionAddress', this.putOptionAddress);
        },
        getCallOptionDetails() {
            let functionData = this.web3.eth.abi.encodeFunctionSignature({
                name: 'getOptionConditions',
                type: 'function',
                inputs: []
            });

            let result = "";            
            this.web3.eth.call({
                from: this.accounts[0],
                to: this.callOptionAddress,
                data: functionData
            }).then (promise => {
                let error = false;
                try {
                    result = this.web3.eth.abi.decodeParameters(['uint256', 'uint256', 'uint256', 'uint256', 'bool', 'bool', 'bytes32'], promise)
                } catch (err) {error = true; alert("Error! Either no such Option contract exist or other unexpected error.")}
                if(this.web3.utils.toAscii(result['6']).includes("call") && !error){
                    this.showCallOptionDetails(result);
                    this.callOptionToPage = true;
                } else if(!this.web3.utils.toAscii(result['6']).includes("call")){
                    alert("This is not a call option!");
                }                 
            })
        },
        showCallOptionDetails(result){
            this.callOptionQuantity = result['0'];
            this.callOptionStrikePrice = result['1'];
            this.callOptionPurchasePrice = result['2'];
            let ExpiryTime = new Date(result['3']/1);
            this.callOptionExpiryTime = ExpiryTime.toString();
            if (result['4'] == false){
                this.callOptionWasCollateralized = 'not';
            } else {
                this.callOptionWasCollateralized = '';
            }
            if (result['5'] == false){
                this.callOptionWasPurchased = 'not';
            } else {
                this.callOptionWasPurchased = '';
            }
        },

        getPutOptionDetails() {
            let functionData = this.web3.eth.abi.encodeFunctionSignature({
                name: 'getOptionConditions',
                type: 'function',
                inputs: []
            });
            let result = "";            
            this.web3.eth.call({
                from: this.accounts[0],
                to: this.putOptionAddress,
                data: functionData
                }).then (promise => {
                    let error = false;
                    try {
                        result = this.web3.eth.abi.decodeParameters(['uint256', 'uint256', 'uint256', 'uint256', 'bool', 'bool', 'bytes32'], promise)
                    } catch (err) {error = true; alert("Error! Either no such Option contract exist or other unexpected error.")}
                    if(this.web3.utils.toAscii(result['6']).includes("put") && !error){
                        this.showPutOptionDetails(result);
                        this.putOptionToPage = true;
                    } else if(!this.web3.utils.toAscii(result['6']).includes("put")){
                        alert("This is not a put option!");
                    }                            
                })
        },
        showPutOptionDetails(result){
            this.putOptionQuantity = result['0'];
            this.putOptionStrikePrice = result['1'];
            this.putOptionPurchasePrice = result['2'];
            let ExpiryTime = new Date(result['3']/1);
            this.putOptionExpiryTime = ExpiryTime.toString();
            if (result['4'] == false){
                this.putOptionWasCollateralized = 'not';
            } else {
                this.putOptionWasCollateralized = '';
            }
            if (result['5'] == false){
                this.putOptionWasPurchased = 'not';
            } else {
                this.putOptionWasPurchased = '';
            }
        },
        buyCallOption(){
            let transactionHash = "";
            let functionData = this.web3.eth.abi.encodeFunctionSignature({
                name: 'purchase',
                type: 'function',
                inputs: []
            });            
            this.web3.eth.sendTransaction({
                from: this.accounts[0],
                to: this.callOptionAddress,
                value: this.callOptionPurchasePrice,
                data: functionData
            })
            .on('transactionHash', function(hash){
                transactionHash = hash;
                alert(transactionHash);                
            })
            .on('confirmation', function(confirmationNumber, receipt){ console.log(receipt); })
            .on('error', function(error){
                if(error.message.includes("already purchased")){
                    alert("Option is already purchased!");
                } else if (error.message.includes("not collateralized yet")){
                    alert("Option is not collateralized yet!");
                } else if (error.message.includes("purchase price")){
                    alert("Incorrect purchase price!");
                } else {
                    alert("Unexpected Error");
                }
            });
            this.showCallCollateralButton = true;      
        },
        buyPutOption(){
            let transactionHash = "";
            let functionData = this.web3.eth.abi.encodeFunctionSignature({
                name: 'purchase',
                type: 'function',
                inputs: []
            });            
            this.web3.eth.sendTransaction({
                from: this.accounts[0],
                to: this.putOptionAddress,
                value: this.putOptionPurchasePrice,
                data: functionData
            })
            .on('transactionHash', function(hash){
                transactionHash = hash;
                alert("Your transaction Hash is " + transactionHash);                
            })
            .on('confirmation', function(confirmationNumber, receipt){ console.log(receipt); })
            .on('error', function(error){
                if(error.message.includes("already purchased")){
                    alert("Option is already purchased!");
                } else if (error.message.includes("not collateralized yet")){
                    alert("Option is not collateralized yet!");
                } else if (error.message.includes("purchase price")){
                    alert("Incorrect purchase price!");
                } else {
                    alert("Unexpected Error");
                }
            });        
        },        
    }
}
</script>

<style>

    .buy_form_btn {
        border: 0.2rem solid  #132237;
        cursor: pointer;
        text-transform: capitalize;
        width: 35%;
        height: 1.8rem;
        background-color: #D8D8D8;
        border-radius: 1rem;
        color:  #132237;
        font-size: 0.9rem;
        margin-top: 1.2rem;
    }

    .buy_form_btn:Hover, .sell_form_btn:Focus {
        box-shadow: 0 0 7px #3C9BED;
        border: 0.1rem solid #3C9BED;
        background-color: #ecd484;
        color: #1f376a;
    }

    @media (max-width: 600px) {
        .buy_form_btn {
            width: 60%;
        }
    }

</style>
