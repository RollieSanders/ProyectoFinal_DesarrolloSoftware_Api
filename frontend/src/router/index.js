import { createRouter, createWebHistory } from 'vue-router';
import ProductMenu from '../views/ProductMenuView.vue';
import OrderConfirmation from '../views/OrderConfirmationView.vue';

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: '/',
            name: 'menu',
            component: ProductMenu
        },
        {
            path: '/confirmation',
            name: 'confirmation',
            component: OrderConfirmation
        }
    ]
});

export default router;