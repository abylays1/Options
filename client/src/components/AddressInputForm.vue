<template>
  <form class="option_address_form" @submit.prevent="onSubmit">
    <div>
      <label class="edit-address"> Add your Option Contract address </label>
      <input id="newOptionAddressInput" class="input_text" name="newOptionAddressInput" ref="newOptionAddressInput" type="text" autocomplete="off" v-model.lazy.trim="newAddress" />
    </div>
    <div class="btn-group">
      <button type="submit" class="exist_contr_btn">
        Add to my portfolio
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
            this.$emit("new-option-address-added", this.newAddress);
            this.newAddress = "";
        }
    }
}
</script>

<style scoped>

form.option_address_form {
  margin-top: 2rem;
}

</style>