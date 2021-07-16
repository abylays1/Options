<template>
    <div class="option_contract_item" :id="id">
        <div class="option_contract_item_description">
            <p> Type - {{optionType}} </p>
            <p> Quantity = {{optionQuantity}} tokens </p>  
            <p> Strike price = {{optionStrikePrice}} ETH/token</p>
            <p> Purchase price = {{optionPurchasePrice}} ETH</p>
            <p> Expiry time is {{optionExpiryTime}} </p>
            <p> Option is{{optionWasCollateralized}} collateralized </p>
            <p> Option is{{optionWasPurchased}} purchased </p>
            <p v-if="optionType == 'Put' && optionWasPurchased == ' '"> Tokens were{{buyerSentTokens}} sent before execution </p>                        
        </div>
        <button type="button" class="exist_contr_btn" v-if="optionOwner && optionWasCollateralized == ' not'" @click="collateralize"> Collateralize the option! </button>
        <button type="button" class="exist_contr_btn" v-if="optionOwner && optionWasCollateralized == ' '" @click="refund"> Refund the option! </button>
        <button type="button" class="exist_contr_btn" v-if="optionBuyer" @click="execute"> Execute the option! </button>
        <button type="button" class="exist_contr_btn" v-if="optionBuyer && optionType == 'Put' && buyerSentTokens == ' not'" @click="transferTokens"> 
            Transfer tokens! </button>        
        <button type="button" class="btn_danger" @click="deleteOption"> Delete Option !</button>
    </div>
</template>

<script>


export default {
    async mounted() {
        this.$emit("option-mounted", {xId: this.id, xType: this.optionType, xAddress: this.optionAddress, xOwner: this.optionOwner, xBuyer: this.optionBuyer,
            xTokenAddress: this.tokenAddress, xQuantity: this.optionQuantity});
    },    
    props: {
        id: {required: true, type: String},
        optionAddress:  {required: true, type: String},
        optionType: {required: true, type: String},
        optionQuantity: {required: true, type: String},
        optionStrikePrice: {required: true, type: String},
        optionPurchasePrice: {required: true, type: String},
        optionExpiryTime: {required: true, type: String},
        optionWasCollateralized: {required: true, type: String},
        optionWasPurchased: {required: true, type: String},
        optionOwner: {required: true, type: Boolean},        
        optionBuyer: {required: true, type: Boolean},
        tokenAddress: {required: true, type: String},
        buyerSentTokens: {required: false, type: String}        
    },

    methods: {
        deleteOption() {
            this.$emit('option-deleted', {xId: this.id, xOwner: this.optionOwner, xBuyer: this.optionBuyer, xAddress: this.optionAddress});
        },
        collateralize() {
            this.$emit('collateralize-option', {xId: this.id, xType: this.optionType, xQuantity: this.optionQuantity, xStrikePrice: this.optionStrikePrice, 
            xAddress: this.optionAddress, xTokenAddress: this.tokenAddress });
        },
        refund() {
            this.$emit("refund-option", {xId: this.id, xOwner: this.optionOwner, xBuyer: this.optionBuyer, xAddress: this.optionAddress});
        },
        execute() {
            this.$emit("execute-option", {xId: this.id, xOwner: this.optionOwner, xBuyer: this.optionBuyer, xType: this.optionType, xQuantity: this.optionQuantity, 
            xStrikePrice: this.optionStrikePrice, xAddress: this.optionAddress});                      
        },
        transferTokens() {
            this.$emit("transfer-tokens", {xId: this.id, xType: this.optionType, xQuantity: this.optionQuantity, xStrikePrice: this.optionStrikePrice, 
            xAddress: this.optionAddress, xTokenAddress: this.tokenAddress });
        }
    }
}
</script>

<style>
</style>
