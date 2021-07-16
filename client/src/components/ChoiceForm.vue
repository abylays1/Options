<template>
  <form class="form-small">
    <div class="btn-group">
        <a :href="$router.resolve({name: 'SellForm'}).href">
          <button type="button" class="btn">
            Create and sell new option
          </button>
        </a>
        <a :href="$router.resolve({name: 'BuyForm'}).href">
          <button type="button" class="btn">
            Buy existing option
          </button>
        </a>        
        <a :href="$router.resolve({name: 'ExistingContracts'}).href">
          <button type="button" class="btn">
            Check your options' portfolio
          </button>
        </a>                
    </div>
  </form>
</template>

<script>

export default {
  methods: {
  }
}
</script>

<style scoped>

  .btn-group {
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .btn {
    padding: 0.8rem 1rem 0.7rem;
    border: 0.2rem solid  #132237;
    cursor: pointer;
    text-transform: capitalize;
    width: 100%;
    height: 100%;
    background-color: #D8D8D8;
    border-radius: 1rem;
    color:  #132237;
    font-size: 1.35rem;
  }

  .btn:Hover, .btn:Focus {
    box-shadow: 0 0 7px #3C9BED;
    border: 0.1rem solid #3C9BED;
    background-color: #ecd484;
    color: #1f376a;
  }

  a {
    width: 50%;
    margin-top: 1rem;
  }

  @media (max-width: 600px) {
    a {
        width: 70%;
      }
  }


</style>
