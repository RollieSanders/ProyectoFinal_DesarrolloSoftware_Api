<template>
  <div class="container">
    <div class="menu-section">
      <div class="search-bar">
        <i class="fas fa-search"></i>
        <input type="text" placeholder="Buscar productos...">
        <i class="fas fa-map-marker-alt location-icon"></i>
      </div>
      
      <div class="product-grid">
        <div v-for="product in products" :key="product.id" class="product-card">
          <img :src="product.image_url" :alt="product.name">
          <div class="product-info">
            <h3>{{ product.name }}</h3>
            <p>S/.{{ product.price.toFixed(2) }}</p>
          </div>
          <button
            :class="{ 'add-to-cart-btn': !cartStore.isProductInCart(product.id), 'added-to-cart-btn': cartStore.isProductInCart(product.id) }"
            @click="cartStore.addToCart(product)"
            :disabled="cartStore.isProductInCart(product.id)"
          >
            {{ cartStore.isProductInCart(product.id) ? 'Agregado' : 'Agregar' }}
          </button>
        </div>
      </div>
    </div>

    <div class="cart-section">
      <h2>Carrito de Compras</h2>
      <div class="cart-items-list">
        <div v-for="item in cartStore.cartItems" :key="item.id" class="cart-item">
          <img :src="item.image_url" :alt="item.name">
          <div class="item-details">
            <h4>{{ item.name }}</h4>
            <p>S/.{{ item.price.toFixed(2) }}</p>
          </div>
          <div class="item-controls">
            <button class="quantity-btn" @click="cartStore.updateQuantity(item.id, -1)">-</button>
            <span>{{ item.quantity }}</span>
            <button class="quantity-btn" @click="cartStore.updateQuantity(item.id, 1)">+</button>
          </div>
          <button class="remove-item-btn" @click="cartStore.removeFromCart(item.id)">
            <i class="fas fa-trash-alt"></i>
          </button>
        </div>
        <p v-if="cartStore.cartItems.length === 0">El carrito está vacío.</p>
      </div>

      <div class="order-summary" v-if="cartStore.cartItems.length > 0">
        <p>Subtotal: <span>S/.{{ cartStore.subtotal.toFixed(2) }}</span></p>
        <p>Envío: <span>S/.{{ cartStore.shippingCost.toFixed(2) }}</span></p>
        <h3>Total: <span>S/.{{ cartStore.total.toFixed(2) }}</span></h3>
      </div>
      <button class="checkout-btn" @click="goToCheckout" :disabled="cartStore.cartItems.length === 0">
        Proceder al Pago
      </button>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue';
import { useRouter } from 'vue-router';
import { useCartStore } from '../stores/cart';
import axios from 'axios';

const router = useRouter();
const cartStore = useCartStore();
const products = ref([]);

const fetchProducts = async () => {
  try {

    // const response = await axios.get('https://rollie-api-3f994ccce3f7.herokuapp.com/products');
    const response = await axios.get('http://127.0.0.1:8000/products');
    products.value = response.data;
  } catch (error) {
    console.error('Error fetching products:', error);
  }
};

const goToCheckout = () => {
  router.push('/confirmation');
};

onMounted(() => {
  fetchProducts();
});
</script>

<!-- <style scoped>
@import '../assets/styles.css';
</style> -->