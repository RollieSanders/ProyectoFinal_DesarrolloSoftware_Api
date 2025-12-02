# Usa una imagen base de Python slim, pero que permite instalar dependencias del sistema
FROM python:3.11-slim

# Establece el entorno para evitar problemas de codificación
ENV PYTHONUNBUFFERED 1

# 1. INSTALACIÓN DE DEPENDENCIAS DEL SISTEMA (CRÍTICO)
# Estos paquetes son necesarios para compilar Numpy, Numba, PyODBC, y otras.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        # Herramientas de compilación para C/C++ (necesarias para muchos paquetes binarios como numpy/scipy/cffi)
        build-essential \
        # Headers y archivos de desarrollo para Python
        python3-dev \
        # Librerías para PyODBC
        unixodbc-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. CONFIGURACIÓN DEL DIRECTORIO DE TRABAJO

WORKDIR /app

# 3. INSTALACIÓN DE DEPENDENCIAS DE PYTHON
# Copia el archivo de requisitos e instala las dependencias
COPY requirements-linux.txt .
RUN pip install --no-cache-dir -r requirements-linux.txt

# 4. COPIAR EL CÓDIGO DE LA APLICACIÓN
# Copia el resto del código desde el directorio 'backend'
COPY config config/
COPY main.py .

# 5. CONFIGURACIÓN FINAL
EXPOSE 8000
# Comando de inicio
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]