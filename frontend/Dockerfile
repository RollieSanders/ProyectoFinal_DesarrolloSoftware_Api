# ----------------------------------------------------
# Multi-stage build para Frontend (Vue.js)
# ----------------------------------------------------

# Stage 1: Build la aplicación Vue.js
FROM node:18-alpine AS build

WORKDIR /app
COPY frontend/package.json frontend/package-lock.json ./
RUN npm install

# Si necesitas variables de entorno en el build, deben estar aquí
# COPY .env .
COPY frontend/ .
RUN npm run build 

# Stage 2: Servir con Nginx (imagen ligera)
FROM nginx:stable-alpine

# Eliminar la configuración default de Nginx
RUN rm /etc/nginx/conf.d/default.conf

# Copiar los archivos estáticos de la etapa de build
COPY --from=build /app/dist /usr/share/nginx/html

# Configuración custom de Nginx para Vue.js (manejo de rutas)
COPY frontend/nginx.conf /etc/nginx/conf.d/default.conf

# Exponer el puerto estándar HTTP
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]