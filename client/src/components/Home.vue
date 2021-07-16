<template>
    <div id="Home">
        <h1> Hello Anon ! </h1>
        <h2> Welcome to the Decentralized Options Market </h2>
        <h2> Here you can create, sell and buy Call and Put options </h2>
        <h3> Supported options - American-style for tokens on ETH platform</h3>
        <choice-form></choice-form>
    </div>
</template>

<script>
//import uniqueId from 'lodash.uniqueid';
import ChoiceForm from './ChoiceForm.vue';



export default {
  components: {
    ChoiceForm,
  }
}
</script>

<style>
</style>
