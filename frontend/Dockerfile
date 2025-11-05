# ----------------------------------------------------
# Multi-stage build para Frontend (Vue.js)
# ----------------------------------------------------
# Stage 1: Build la aplicación Vue.js
FROM node:20-alpine AS build

WORKDIR /app

# 1. Instalar herramientas de build del SO (Para dependencias nativas)
RUN apk add --no-cache python3 make g++

# 2. Copiar archivos de dependencia
COPY package*.json ./

# 3. Instalación Limpia y Consistente
RUN npm install

# 4. Corregir permisos de ejecución (Solución al "Permission denied")
# CAMBIO CLAVE: Asegura que todos los scripts en node_modules/.bin sean ejecutables.
RUN chmod +x ./node_modules/.bin/*

# 5. Copiar el resto del código fuente
COPY . . 

# 6. Ejecutar el build
RUN npm run build

# Stage 2: Servir con Nginx (imagen ligera)
FROM nginx:stable-alpine

# 1. Crear un directorio específico para archivos de configuración
# Este paso no es necesario si solo reemplazas default.conf, pero es una buena práctica.

# 2. Eliminar la configuración default de Nginx
# Esto es correcto.
RUN rm /etc/nginx/conf.d/default.conf

# 3. Copiar los archivos estáticos de la etapa de build
# Esto es correcto y eficiente.
COPY --from=build /app/dist /usr/share/nginx/html

# 4. Configuración custom de Nginx para Vue.js (manejo de rutas)
# Asegúrate de que tu nginx.conf incluya 'try_files $uri $uri/ /index.html;'
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 5. Exponer el puerto estándar HTTP
# EXPOSE 80 está bien, ya que Nginx por defecto escucha en este puerto.
EXPOSE 80

# 6. Comando de inicio (CMD)
# Esto es correcto para mantener Nginx en primer plano.
CMD ["nginx", "-g", "daemon off;"]