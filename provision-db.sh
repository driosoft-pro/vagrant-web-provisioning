#!/usr/bin/env bash
# ===============================================================
# PROVISION-DB.SH
# Autor: Deyton Riasco Ortiz
# Descripción: Instala y configura PostgreSQL, crea base de datos y datos de ejemplo
# ===============================================================
set -euo pipefail

# ==== Colores ====
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

# ==== Fix de DNS ====
echo -e "${YELLOW}[DB] Fix DNS...${RESET}"
echo 'nameserver 8.8.8.8' | sudo tee /etc/resolv.conf >/dev/null

# ==== Variables ====
DB_NAME="appdb"
DB_USER="appuser"
DB_PASS="appsecret"
NETWORK_CIDR="192.168.56.0/24"

# ==== Instalar PostgreSQL ====
echo -e "${GREEN}[DB] Instalando PostgreSQL...${RESET}"
sudo apt-get update -y || { echo -e "${RED}[DB] Error al actualizar paquetes.${RESET}"; exit 1; }
sudo apt-get install -y postgresql postgresql-contrib

# ==== Configurar PostgreSQL ====
PG_CONF="/etc/postgresql/$(ls /etc/postgresql)/main/postgresql.conf"
PG_HBA="/etc/postgresql/$(ls /etc/postgresql)/main/pg_hba.conf"

echo -e "${GREEN}[DB] Configurando PostgreSQL...${RESET}"
sudo sed -i "s/^#\?listen_addresses.*/listen_addresses = '*'/" "$PG_CONF"
if ! grep -q "$NETWORK_CIDR" "$PG_HBA"; then
  echo "host    all             all             $NETWORK_CIDR            md5" | sudo tee -a "$PG_HBA" >/dev/null
fi

sudo systemctl enable postgresql
sudo systemctl restart postgresql

# ==== Crear usuario y base de datos ====
echo -e "${GREEN}[DB] Creando usuario y base de datos...${RESET}"
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
  ('Alan Turing', 'alan@example.com'),
  ('Grace Hopper', 'grace@example.com'),
  ('Linus Torvalds', 'linus@example.com'),
  ('Katherine Johnson', 'katherine@example.com')
ON CONFLICT DO NOTHING;
SQL

# ==== Fin ====
echo -e "${GREEN}[DB] Base de datos creada y lista para conexión.${RESET}"
