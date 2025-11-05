# ----------------------------------------------------
# Etapa 1: Build (Usando la imagen oficial de PyTorch)
# ----------------------------------------------------
FROM pytorch/pytorch:2.4.0-cpu-py39 AS builder

# 1. Instalar herramientas de compilación y dependencias de sistema
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        unixodbc-dev \
        libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Directorio de trabajo
WORKDIR /app

# Copiar el archivo de requerimientos y realizar la instalación
# Ya estamos asumiendo que el contexto de build es la carpeta 'backend/' (Opción 2)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ----------------------------------------------------
# Etapa 2: Runtime (Imagen limpia y pequeña para producción)
# ----------------------------------------------------
FROM python:3.9-slim

# 1. Asegurarse de que apt-get no sea interactivo y actualizar la lista de paquetes
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update

# 2. Instalar librerías de sistema (libpq5 y odbcinst1debian2) y limpiar
RUN apt-get install -y --no-install-recommends \
    libpq5 \
    odbcinst1debian2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configuración del entorno
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

# Copiar librerías de la Etapa Builder (PyTorch)
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages

# Copiar el código de la aplicación
COPY . /app/

# Exponer puerto
EXPOSE 5000

# Comando de inicio
CMD ["python", "main.py"]