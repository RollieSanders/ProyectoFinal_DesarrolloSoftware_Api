# ----------------------------------------------------
# Single-stage build para Backend (Python/Flask)
# ----------------------------------------------------
FROM python:3.9-slim

# Configuración del entorno
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Directorio de trabajo (es buena práctica usar /usr/src/app)
WORKDIR /usr/src/app

# Instalar las dependencias
# ¡Ahora el path es simple porque el contexto de build es la carpeta 'backend'!
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el código de la aplicación
# Copia todo el contenido del contexto (backend/) al directorio de trabajo
COPY . .

# Exponer puerto (Asegúrate de que coincida con el puerto de tu app Python, ej. 5000)
EXPOSE 5000

# Comando de inicio
CMD ["python", "main.py"]