# ----------------------------------------------------
# Etapa 1: Build (Usando la imagen oficial de PyTorch, ¡con tag corregido!)
# Nota: La etiqueta más estable y reciente compatible con CPU es a menudo py310.
# ----------------------------------------------------
FROM pytorch/pytorch:2.3.1-cpu-py310 AS builder

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
COPY requirements.txt .
# Ignorar torch, numpy y tiktoken (parte de whisper) si la base los incluye
RUN pip install --no-cache-dir -r requirements.txt --ignore-installed torch numpy

# ----------------------------------------------------
# Etapa 2: Runtime (Imagen limpia)
# Usamos python:3.10-slim para que coincida con el builder
# ----------------------------------------------------
FROM python:3.10-slim

# 1. Instalar librerías de sistema en runtime
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libpq5 \
        odbcinst1debian2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configuración del entorno
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

# 2. Copiar librerías de la Etapa Builder (¡Path ajustado a python3.10!)
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages

# Copiar el código de la aplicación
COPY . /app/

# Exponer puerto
EXPOSE 5000

# Comando de inicio
CMD ["python", "main.py"]