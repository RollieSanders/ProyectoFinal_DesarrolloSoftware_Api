# ----------------------------------------------------
# Multi-stage build para Backend (Python/Flask)
# ----------------------------------------------------

# Stage 1: Build
FROM python:3.9-slim AS base

# Configuración del entorno
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Directorio de trabajo
WORKDIR /app

# Instalar las dependencias
COPY backend/requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el código de la aplicación
COPY backend/ /app/

# Exponer puerto (Asegúrate de que coincida con el puerto de tu app Python, ej. 5000)
EXPOSE 5000

# Comando de inicio
CMD ["python", "main.py"]