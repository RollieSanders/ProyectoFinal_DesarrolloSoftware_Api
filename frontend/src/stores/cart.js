import { defineStore } from 'pinia';
import { computed, ref } from 'vue';

export const useCartStore = defineStore('cart', () => {
    const cartItems = ref([]);
    const shippingCost = 5.00;

    const subtotal = computed(() => {
        return cartItems.value.reduce((acc, item) => acc + item.price * item.quantity, 0);
    });

    const total = computed(() => {
        return subtotal.value + shippingCost;
    });

    const isProductInCart = (productId) => {
        return cartItems.value.some(item => item.id === productId);
    };

    const addToCart = (product) => {
        if (!isProductInCart(product.id)) {
            cartItems.value.push({ ...product, quantity: 1 });
        }
    };

    const removeFromCart = (productId) => {
        cartItems.value = cartItems.value.filter(item => item.id !== productId);
    };

    const updateQuantity = (productId, quantityChange) => {
        const item = cartItems.value.find(item => item.id === productId);
        if (item) {
            item.quantity += quantityChange;
            if (item.quantity <= 0) {
                removeFromCart(productId);
            }
        }
    };

    const clearCart = () => {
        cartItems.value = [];
    };

    return {
        cartItems,
        shippingCost,
        subtotal,
        total,
        isProductInCart,
        addToCart,
        removeFromCart,
        updateQuantity,
        clearCart
    };
});