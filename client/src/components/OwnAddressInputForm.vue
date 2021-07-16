<template>
  <form class="stack-small" @submit.prevent="onSubmit">
    <div>
      <label class="edit-address"> Add your ETH account address that owns option </label>
      <input id="newOwnAddressInput" class="input_text" name="newOptionAddressInput" ref="newOptionAddressInput" type="text" autocomplete="off" v-model.lazy.trim="newAddress" />
    </div>
    <div class="btn-group">
      <button type="submit" class="exist_contr_btn">
        Add my Address !
      </button>
    </div>
  </form>
</template>
<script>
export default {
    data() {
        return {
        newAddress: ""
        };
    },
    methods: {
        onSubmit() {
            if (this.newAddress == ""){
                return;
            } 
            this.$emit("new-own-address-added", this.newAddress);
            this.newAddress = "";
        }
    }
}
</script>

<style scoped>

</style>