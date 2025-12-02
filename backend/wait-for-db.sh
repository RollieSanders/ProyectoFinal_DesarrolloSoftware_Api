#!/bin/sh
# wait-for-db.sh - intenta conectar al DB_HOST:DB_PORT antes de arrancar la app
: "${DB_HOST?Need to set DB_HOST}"
: "${DB_PORT:=3306}"
RETRIES=12
SLEEP=5
i=0
while [ $i -lt $RETRIES ]; do
  i=$((i+1))
  echo "[wait-for-db] Intento $i/$RETRIES: comprobando ${DB_HOST}:${DB_PORT}..."
  # Intento de conexión TCP usando /dev/tcp (disponible en shell de Debian)
  if (echo > /dev/tcp/${DB_HOST}/${DB_PORT}) >/dev/null 2>&1; then
    echo "[wait-for-db] Conectado a ${DB_HOST}:${DB_PORT}"
    exit 0
  fi
  sleep $SLEEP
done

echo "[wait-for-db] ERROR: No se pudo conectar a ${DB_HOST}:${DB_PORT} después de $RETRIES intentos." >&2
exit 1
