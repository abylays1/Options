import { createRouter, createWebHistory } from 'vue-router'
import Home from './components/Home.vue'
import SellForm from './components/SellForm.vue'
import BuyForm from './components/BuyForm.vue'
import ExistingContracts from './components/ExistingContracts.vue'

const routes = [{
        path: '/',
        name: 'Home',
        component: Home
    },
    {
        path: '/SellForm',
        name: 'SellForm',
        component: SellForm
    },
    {
        path: '/BuyForm',
        name: 'BuyForm',
        component: BuyForm
    },
    {
        path: '/ExistingContracts',
        name: 'ExistingContracts',
        component: ExistingContracts
    }
]

const router = createRouter({
    history: createWebHistory(process.env.BASE_URL),
    routes
})

export default router