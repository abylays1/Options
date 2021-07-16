import Vuex from 'vuex'

// Create a new store instance.
let store = new Vuex.Store({
    state() {
        return {
            callTokenAddress: "",
            callTokenQuantity: 0,
            callStrikePrice: 0,
            callPurchasePrice: 0,
            callExpiryDate: "",
            callExpiryTime: "",
            putTokenAddress: "",
            putTokenQuantity: 0,
            putStrikePrice: 0,
            putPurchasePrice: 0,
            putExpiryDate: "",
            putExpiryTime: "",
            callOptionAddress: "",
            putOptionAddress: "",
            soldOptionItems: [],
            boughtOptionItems: [],
            optionAddresses: [],
            ownAddresses: [],
        }
    },
    mutations: {

        initialiseStore(state) {
            if (localStorage.getItem('store')) {
                this.replaceState(
                    Object.assign(state, JSON.parse(localStorage.getItem('store')))
                );
            }
        },

        setCallTokenAddress(state, x) {
            state.callTokenAddress = x
        },
        setCallTokenQuantity(state, x) {
            state.callTokenQuantity = x
        },
        setCallStrikePrice(state, x) {
            state.callStrikePrice = x
        },
        setCallPurchasePrice(state, x) {
            state.callPurchasePrice = x
        },
        setCallExpiryDate(state, x) {
            state.callExpiryDate = x
        },
        setCallExpiryTime(state, x) {
            state.callExpiryTime = x
        },
        setPutTokenAddress(state, x) {
            state.putTokenAddress = x
        },
        setPutTokenQuantity(state, x) {
            state.putTokenQuantity = x
        },
        setPutStrikePrice(state, x) {
            state.putStrikePrice = x
        },
        setPutPurchasePrice(state, x) {
            state.putPurchasePrice = x
        },
        setPutExpiryDate(state, x) {
            state.putExpiryDate = x
        },
        setPutExpiryTime(state, x) {
            state.putExpiryTime = x
        },
        setCallOptionAddress(state, x) {
            state.callOptionAddress = x
        },
        setPutOptionAddress(state, x) {
            state.putOptionAddress = x
        },
        setSoldOptionItems(state, x) {
            state.soldOptionItems = x
        },
        setBoughtOptionItems(state, x) {
            state.boughtOptionItems = x
        },
        setOptionAddresses(state, x) {
            state.optionAddresses = x
        },
        setOwnAddresses(state, x) {
            state.ownAddresses = x
        }

    }
})

store.subscribe((mutation, state) => {
    localStorage.setItem('store', JSON.stringify(state));
});


export default store;