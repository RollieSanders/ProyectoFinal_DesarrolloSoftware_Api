<template>
  <div class="container-confirmation">
    <div class="confirmation-section">
      <i class="fas fa-check-circle confirmation-icon"></i>
      <h1>¡Gracias por tu pedido!</h1>
      <p>Tu pedido ha sido recibido y está en preparación.</p>

      <div class="order-details-summary">
        <h3>Resumen del Pedido</h3>
        <p>Número de Pedido: <span>#ORD{{ Math.floor(Math.random() * 1000000) }}</span></p>
        <p>Método de Pago: <span>Tarjeta de Crédito</span></p>
        <p>Total Pagado: <span>S/.{{ cartStore.total.toFixed(2) }}</span></p>
        <p>Tiempo estimado: <span>25-30 minutos</span></p>
      </div>

      <!-- <div class="map-container">
        <img src="https://placehold.co/600x400/cccccc/333333?text=Mapa+de+Seguimiento" alt="Mapa de Seguimiento del Pedido">
      </div> -->

      <a href="#" class="back-to-menu-btn" @click="goToMenu">Volver al Menú</a>
    </div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useCartStore } from '../stores/cart';

const router = useRouter();
const cartStore = useCartStore();

const goToMenu = () => {
    cartStore.clearCart();
    router.push('/');
};

onMounted(() => {
  // Aquí usamos .value para verificar si el array reactivo está vacío
  if (cartStore.cartItems.length === 0) {
    router.push('/');
  }
});
</script>

<!-- <style scoped>
@import '../assets/styles.css';
</style> -->