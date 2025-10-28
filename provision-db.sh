#!/usr/bin/env sh
set -euo pipefail

# Variables
DB_NAME="appdb"
DB_USER="appuser"
DB_PASS="appsecret"
NETWORK_CIDR="192.168.56.0/24"

# Actualizar e instalar paquetes
sudo apt-get update -y
sudo apt-get install -y postgresql

# Habilitar y reiniciar PostgreSQL
sudo systemctl enable postgresql
sudo systemctl restart postgresql

# Configuaración de red y conexiones de red
PG_CONF="/etc/postgresql/$(ls /etc/postgresql)/main/postgresql.conf"
PG_HBA="/etc/postgresql/$(ls /etc/postgresql)/main/pg_hba.conf"

# Configuración de PostgreSQL para escuchar en todas las interfaces y permitir conexiones desde la red privada
sudo sed -i "s/^#\?listen_addresses.*/listen_addresses = '*'/" "$PG_CONF"
if ! grep -q "$NETWORK_CIDR" "$PG_HBA"; then
  echo "host    all             all             $NETWORK_CIDR            md5" | sudo tee -a "$PG_HBA" >/dev/null
fi

# Reiniciar PostgreSQL para aplicar cambios
sudo systemctl restart postgresql

# Crear usuario y base de datos
sudo -u postgres psql -v ON_ERROR_STOP=1 <<SQL
DO
\$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$DB_USER') THEN
      CREATE ROLE $DB_USER LOGIN PASSWORD '$DB_PASS';
   END IF;
END
\$\$;

CREATE DATABASE $DB_NAME OWNER $DB_USER TEMPLATE template1;

\connect $DB_NAME

CREATE TABLE IF NOT EXISTS students (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE
);

INSERT INTO students (name, email) VALUES
  ('Ada Lovelace', 'ada@example.com'),
  ('Alan Turing', 'alan@example.com')
ON CONFLICT DO NOTHING;
SQL

echo 'OK: DB provision complete.'
