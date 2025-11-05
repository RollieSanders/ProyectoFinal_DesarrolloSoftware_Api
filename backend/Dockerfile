# ----------------------------------------------------
# Etapa 1: Build (Instalación de dependencias complejas)
# Usamos una imagen base completa, o directamente la imagen de pytorch si es viable.
# Para este ejemplo, volvemos a una base completa y añadimos herramientas de compilación.
# ----------------------------------------------------
FROM python:3.9 AS builder

# 1. Instalar herramientas de compilación y dependencias de sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    unixodbc-dev \
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

# Instalar librerías de sistema que SÍ son necesarias en runtime
# La corrección está en la gestión del 'apt-get update' y la eliminación de la caché.
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

# Copiar librerías de la Etapa Builder (PyTorch)
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages

# Copiar el código de la aplicación
COPY . /app/

# Exponer puerto
EXPOSE 5000

# Comando de inicio
CMD ["python", "main.py"]