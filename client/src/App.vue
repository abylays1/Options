<template>
  <router-view :key="$route"/>
</template>

<script>

export default {
  name: 'App',
  components: {
  },
  data() {
    return {
      };
  },
  methods: {
  }
}


</script>

<style>

  body {
    margin: 0;
    background-color: #eff0f1;
  }
  #app {
    font-family: Avenir, Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    text-align: center;
    background-color:#F0F0F0;
    box-shadow: 0 2px 4px 0 rgba(0, 0, 0, 0.2), 0 2.5rem 5rem 0 rgba(0, 0, 0, 0.1);
    color: #132237;
    margin: auto;
    margin-top: 10vh;
    padding: 1rem;
    padding-bottom: 4rem;
    position: relative;
    display: block;
    width: 50%;
    align: center;
  }

  .form_radio {
        margin-bottom: 1rem;
  }

  input.input_text {
    display: inline-block;
    margin-top: 0.1rem;
    margin-left: 1rem;
    min-height: 1rem;
    width: 30%;
    padding: 0.4rem 0.8rem;
    border: 0.1rem solid #132237;
    color: #132237;    
  }

  input.input_text:focus {
    outline: none !important;
    box-shadow: 0 0 7px #3C9BED;
    border: 1.5px solid #3C9BED;
  }

  form.form-input div{
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-left: 3%;
  }

  .label_lg {
    vertical-align: center;
  }

  @media (max-width: 1200px) {
      #app {
        width: 90%;
      }
  }

  input::-webkit-outer-spin-button, input::-webkit-inner-spin-button {
    -webkit-appearance: none;
    margin: 0;
  }

  input[type=number] {
    -moz-appearance: textfield;
  }




</style>
