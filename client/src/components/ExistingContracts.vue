<template>
    <h2> Manage your Portfolio of options here </h2>
    <own-address-input-form @new-own-address-added="addNewOwnAddress"></own-address-input-form>
    <h3 v-if="ownAddresses.length >= 1"> My addresses </h3>
    <ul>
        <li class="own_address" v-for="(item, index) in ownAddresses" :key="index">
            <p> {{item}} </p>
        </li>
    </ul>
    <address-input-form @new-option-address-added="addOptionContract"></address-input-form>
    <div id="ExistingContracts">
        <h3> My Sold Options </h3>
        <ul>
            <li v-for="item in soldOptionItems" :key="item.id">
                <option-contract-item :id="item.id" :optionAddress="item.optionAddress" :optionType="item.optionType"
                :optionQuantity="item.optionQuantity" :optionStrikePrice="item.optionStrikePrice" :optionPurchasePrice="item.optionPurchasePrice"
                :optionExpiryTime="item.optionExpiryTime" :optionWasCollateralized="item.optionWasCollateralized" :optionWasPurchased="item.optionWasPurchased"
                :optionOwner="item.optionOwner" :optionBuyer="item.optionBuyer" :tokenAddress="item.tokenAddress" :buyerSentTokens="item.buyerSentTokens"
                @option-deleted="deleteOptionContractItem" :ref="item.id" @option-mounted="beginUpdating" 
                @collateralize-option="collateralize" @refund-option="refund" @execute-option="execute"
                @transfer-tokens="collateralizeCall"></option-contract-item>
            </li>
        </ul>
        <h3> My Bought Options </h3>
        <ul class="put_option_list">
            <li v-for="item in boughtOptionItems" :key="item.id">
                <option-contract-item :id="item.id" :optionAddress="item.optionAddress" :optionType="item.optionType"
                :optionQuantity="item.optionQuantity" :optionStrikePrice="item.optionStrikePrice" :optionPurchasePrice="item.optionPurchasePrice"
                :optionExpiryTime="item.optionExpiryTime" :optionWasCollateralized="item.optionWasCollateralized" :optionWasPurchased="item.optionWasPurchased"
                :optionOwner="item.optionOwner" :optionBuyer="item.optionBuyer" :tokenAddress="item.tokenAddress" :buyerSentTokens="item.buyerSentTokens"
                @option-deleted="deleteOptionContractItem" :ref="item.id" @option-mounted="beginUpdating"
                @collateralize-option="collateralize" @refund-option="refund" @execute-option="execute"
                @transfer-tokens="collateralizeCall"></option-contract-item>
            </li>
        </ul>
    </div>
</template>

<script>
import OwnAddressInputForm from "./OwnAddressInputForm.vue";
import AddressInputForm from "./AddressInputForm.vue";
import OptionContractItem from "./OptionContractItem.vue";
import uniqueId from 'lodash.uniqueid';
import getWeb3 from "../getWeb3.js";


export default {
    created() {
    },
    async mounted() {
        this.web3 = await getWeb3();
        this.networkId = await this.web3.eth.getChainId();
        this.accounts = await this.web3.eth.getAccounts();
        this.$store.commit('initialiseStore');
        this.soldOptionItems = this.$store.state.soldOptionItems;
        this.boughtOptionItems = this.$store.state.boughtOptionItems;
        this.optionAddresses = this.$store.state.optionAddresses;
        this.ownAddresses = this.$store.state.ownAddresses;        
    },    
    components: {
        AddressInputForm,
        OptionContractItem,
        OwnAddressInputForm
    },
    data() {
        return {
            soldOptionItems: [],
            boughtOptionItems: [],
            optionAddresses: [],
            ownAddresses: [],
        };
    },
    methods: {
        async addOptionContract(address) {
            for (let item of this.optionAddresses){
                if(address == item){
                    alert("This option already exists !");
                    return;
                }
            }
            let error = false;
            let optionOwner = false;
            let optionBuyer = false;
            let ownerFunctionData = this.web3.eth.abi.encodeFunctionSignature('owner()');
            let buyerFunctionData = this.web3.eth.abi.encodeFunctionSignature('getBuyer()');

            await this.web3.eth.call({
                from: this.accounts[0],
                to: address,
                data: ownerFunctionData
                }).then (promise => {
                    try {
                        result = this.web3.eth.abi.decodeParameters(['address'], promise);
                        for (let item of this.ownAddresses){
                            if(result['0'] == item){
                                optionOwner = true;
                            }
                        }
                    } catch (err) {alert("Error! Either no such Option contract exist or other unexpected error."); error = true;}
                })
            
            if(await error == true){
                return;
            }

            await this.web3.eth.call({
                from: this.accounts[0],
                to: address,
                data: buyerFunctionData
                }).then (promise => {
                    try {
                        result = this.web3.eth.abi.decodeParameters(['address'], promise);
                        for (let item of this.ownAddresses){
                            if(result['0'] == item){
                                optionBuyer = true;
                            }
                        }
                    } catch (err) {alert("Error! Either no such Option contract exist or other unexpected error."); return;}
                })
            if(await error == true){
                return;
            }

            if (await optionOwner == false && optionBuyer == false){
                alert("You are not the Seller and not the buyer of the option!");
                return;
            }

            let functionData = await this.web3.eth.abi.encodeFunctionSignature({
                name: 'getOptionConditions',
                type: 'function',
                inputs: []
            });

            let result = "";            
            await this.web3.eth.call({
                from: this.accounts[0],
                to: address,
                data: functionData
            }).then (promise => {
                let error = false;
                try {
                    result = this.web3.eth.abi.decodeParameters(['uint256', 'uint256', 'uint256', 'uint256', 'bool', 'bool', 'bytes32', 'address'], promise)
                } catch (err) {error = true; alert("Error! Either no such Option contract exist or other unexpected error.")}
                if(!error){
                    let collateral = "";
                    let purchase = "";
                    if (result['4'] == false){ collateral = ' not';} else {collateral = ' ';}
                    if (result['5'] == false){purchase = ' not';} else {purchase = ' ';}
                    let ExpiryTime = new Date(result['3']/1);
                    let strikePrice = this.web3.utils.fromWei(result['1'], 'ether') 
                    let purchasePrice = this.web3.utils.fromWei(result['2'], 'ether')
                    let theOptionType = "";
                    if(this.web3.utils.toAscii(result['6']).includes("call")){theOptionType = "Call";} 
                        else if (this.web3.utils.toAscii(result['6']).includes("put")){theOptionType = "Put";}

                    let theOption = {
                            id: uniqueId('option'), 
                            optionAddress: address,
                            optionType: theOptionType,
                            optionQuantity: result['0'],
                            optionStrikePrice: strikePrice,
                            optionPurchasePrice: purchasePrice,
                            optionExpiryTime: ExpiryTime.toString(),
                            optionWasCollateralized: collateral,
                            optionWasPurchased: purchase,
                            optionOwner: optionOwner,
                            optionBuyer: optionBuyer,
                            tokenAddress: result['7'],
                        }
                    if (optionOwner == true){
                        this.soldOptionItems.push(theOption);
                        this.$store.commit('setSoldOptionItems', this.soldOptionItems);
                    }
                    if (optionBuyer == true){
                        this.boughtOptionItems.push(theOption);
                        this.$store.commit('setBoughtOptionItems', this.boughtOptionItems);
                    }
                    this.optionAddresses.push(address);
                    this.$store.commit('setOptionAddresses', this.optionAddresses);
                }       
            })
        },
        deleteOptionContractItem(data) {
            if(data.xOwner == true){
                const itemIndex = this.soldOptionItems.findIndex(item => item.id === data.xId);
                this.soldOptionItems.splice(itemIndex, 1);
                this.$store.commit('setSoldOptionItems', this.soldOptionItems);
            } 
            if (data.xBuyer == true) {
                this.boughtOptionItems.splice(itemIndex, 1);
                const itemIndex = this.boughtOptionItems.findIndex(item => item.id === data.xId);
                this.$store.commit('setBoughtOptionItems', this.boughtOptionItems);
            }
            let itemIndex = this.optionAddresses.findIndex(item => item === data.xAddress);
            this.optionAddresses.splice(itemIndex, 1);
            this.$store.commit('setOptionAddresses', this.optionAddresses);            
        },
        addNewOwnAddress(address){
            for (let item of this.ownAddresses){
                if(address == item){
                    alert("This address already exists !");
                    return;
                }
            }
            this.ownAddresses.push(address);
            this.$store.commit('setOwnAddresses', this.ownAddresses);
        },
        async beginUpdating(data) {
            let check = true;
            while (check == true) {
                await this.updateValues(data);
                await new Promise((resolve) => {
                    setTimeout(resolve, 5000);
                });
            }
        },
        async updateValues(data){
            let collateralBool = "";
            let purchaseBool = '';
            let _this = this;
            let functionData = await this.web3.eth.abi.encodeFunctionSignature({
                name: 'getOptionConditions',
                type: 'function',
                inputs: []
            });
            let result = ""; 
            await this.web3.eth.call({
                from: this.accounts[0],
                to: data.xAddress,
                data: functionData
            }).then(promise => {
                    result = this.web3.eth.abi.decodeParameters(['uint256', 'uint256', 'uint256', 'uint256', 'bool', 'bool', 'bytes32', 'address'], promise)
                    if (result['4'] == false){ collateralBool = ' not';} else {collateralBool = ' ';}
                    if (result['5'] == false){purchaseBool = ' not'; } else {purchaseBool = ' '; }
                })
            let itemIndex;
            if(data.xOwner == true){
                itemIndex = this.soldOptionItems.findIndex(item => item.id === data.xId);
                this.soldOptionItems[itemIndex].optionWasCollateralized = collateralBool;
                this.soldOptionItems[itemIndex].optionWasPurchased = purchaseBool;
            } 
            if (data.xBuyer == true) {
                itemIndex = this.boughtOptionItems.findIndex(item => item.id === data.xId);
                this.boughtOptionItems[itemIndex].optionWasCollateralized = collateralBool;
                this.boughtOptionItems[itemIndex].optionWasPurchased = purchaseBool;
            }

            let buyerSentTokens = "";
            if(purchaseBool == ' ' && data.xType == "Put"){
                let balanceData = await _this.web3.eth.abi.encodeFunctionCall({
                    name: 'balanceOf',
                    type: 'function',
                    inputs: [{type: 'address', name: 'account'}]
                }, [data.xAddress]);
                await _this.web3.eth.call({
                   from: _this.accounts[0],
                    to: data.xTokenAddress,
                    data: balanceData
                }).then (promise => {
                    result = this.web3.eth.abi.decodeParameters(['uint256'], promise);
                    if (result['0'] == data.xQuantity){
                       buyerSentTokens = " "
                    } else {
                        buyerSentTokens = " not"
                    }
                })
                if(data.xOwner == true){
                    _this.soldOptionItems[itemIndex].buyerSentTokens = buyerSentTokens;
                } 
                if(data.xBuyer == true){
                    _this.boughtOptionItems[itemIndex].buyerSentTokens = buyerSentTokens;
                }           
            }

        },
        collateralize(data) {
            if(data.xType == "Call"){
                this.collateralizeCall(data);
            } else if(data.xType == "Put") {
                this.collateralizePut(data);
            }
        },
        async collateralizeCall(data) {
            let functionData = await this.web3.eth.abi.encodeFunctionCall({
                name: 'transfer',
                type: 'function',
                inputs: [{type: 'address', name: 'recipient'},{type:'uint256', name:'amount'}]
                }, [data.xAddress, data.xQuantity]);            

            await this.web3.eth.sendTransaction({
                from: this.accounts[0],
                to: data.xTokenAddress,
                data: functionData
            })
            .on('transactionHash', function(hash){
                alert("Your transaction Hash is " + hash);                
            })
            .on('confirmation', function(confirmationNumber, receipt){ console.log(receipt); })
        },
        async collateralizePut(data) {
            let functionData = await this.web3.eth.abi.encodeFunctionSignature('collateralize()')
            let ethValue = (Number(data.xQuantity)*Number(data.xStrikePrice)).toString();
            ethValue = this.web3.utils.toWei(ethValue, 'ether');
            
            this.web3.eth.sendTransaction({
                from: this.accounts[0],
                to: data.xAddress,
                data: functionData,
                value: ethValue
            })
            .on('transactionHash', function(hash){
                alert(" Your transaction Hash is " + hash);                
            })
            .on('confirmation', function(confirmationNumber, receipt){ console.log(receipt); })

        },
       async refund(data) {
            let functionData = await this.web3.eth.abi.encodeFunctionSignature('refund()');
            let _this = this;
            await this.web3.eth.sendTransaction({
                from: this.accounts[0],
                to: data.xAddress,
                data: functionData
            })
            .on('transactionHash', function(hash){
                alert("Option was successfully destroyed ! Your transaction Hash is " + hash);                
                _this.deleteOptionContractItem(data);
            })
            .on('confirmation', function(confirmationNumber, receipt){ 
                console.log(receipt);
            })
            .on('error', function(error){
                if(error.message.includes("not expired yet")){
                    alert("Option is already purchased and contract has not expired yet!");
                } else {
                    alert("Unexpected Error");
                }
            })                       
        },
        async execute(data) {
            let functionData = this.web3.eth.abi.encodeFunctionSignature('execute()');
            let _this = this;
            if(data.xType == "Call"){
                let ethValue = (Number(data.xQuantity)*Number(data.xStrikePrice)).toString();
                ethValue = this.web3.utils.toWei(ethValue, 'ether');
                this.web3.eth.sendTransaction({
                    from: this.accounts[0],
                    to: data.xAddress,
                    data: functionData,
                    value: ethValue
                })
                .on('transactionHash', function(hash){
                    alert("Option was successfully executed ! Your transaction Hash is " + hash);                
                    _this.deleteOptionContractItem(data);
                })
                .on('confirmation', function(receipt){ 
                    console.log(receipt); 
                })
                .on('error', function(error){
                    if(error.message.includes("is Expired")){
                        alert("Option is Expired!");
                    } else if (error.message.includes("Payment error")){
                        alert("Payment Error!");
                    } else {
                        alert("Unexpected Error");
                    }
                })
            } else if (data.xType == "Put"){
                this.web3.eth.sendTransaction({
                    from: this.accounts[0],
                    to: data.xAddress,
                    data: functionData
                })
                .on('transactionHash', function(hash){
                    alert("Option was successfully executed ! Your transaction Hash is " + hash);                
                    _this.deleteOptionContractItem(data);
                })
                .on('confirmation', function(receipt){ 
                    console.log(receipt);
                    console.log("Wow");
                    })
                .on('error', function(error){
                    if(error.message.includes("is Expired")){
                        alert("Option is Expired!");
                    } else if (error.message.includes("been transferred yet")){
                        alert("Tokens have not been transferred yet!");
                    } else {
                        alert("Unexpected Error");
                    }
                })
            }                       
        }        
         

    },
    computed: {

    }
}
</script>

<style>

    .exist_contr_btn {
        border: 0.1rem solid  #132237;
        cursor: pointer;
        text-transform: capitalize;
        width: 20%;
        height: 1.8rem;
        background-color: #D8D8D8;
        border-radius: 1rem;
        color:  #132237;
        font-size: 0.75rem;
        margin-top: 1.2rem;
    }

    .exist_contr_btn:Hover, .sell_form_btn:Focus {
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
    
    ul {
        list-style-type: none;
        margin: 0;
        padding: 0;
    }

    .btn_danger {
        border: 0.1rem solid  #132237;
        cursor: pointer;
        text-transform: capitalize;
        width: 20%;
        height: 1.8rem;
        background-color: red;
        border-radius: 1rem;
        color:  white;
        font-size: 0.75rem;
        margin-top: 1.2rem;
    }

    .btn_danger:Hover, .btn_danger:Focus {
        box-shadow: 0 0 7px darkred;
        border: 0.1rem solid darkred;
        background-color: firebrick;
    }

    .option_contract_item_description {
        display: grid;
        grid-template-columns: 1fr 1fr 1fr;
        font-size: 0.8rem;
        color: white;
    }
    .option_contract_item {
        background-color: #787878;
        border-radius: 2rem;
        margin-bottom: 2rem;
        padding-bottom: 0.5rem;        
    }

    .put_option_list .option_contract_item {
        background-color: #c19d43;
    }

    @media (max-width: 600px) {
        .btn_danger {
            width: 35%;
        }
        .exist_contr_btn {
            width: 35%;
        }
        #newOwnAddressInput, #newOptionAddressInput {
            width: 50%;
            margin-left: 0;
        }
    }


</style>