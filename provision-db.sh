#!/usr/bin/env bash
# ===============================================================
# PROVISION-DB.SH
# Autor: Deyton Riasco Ortiz
# Descripción: Instala y configura PostgreSQL, crea base de datos
#              y datos de ejemplo para la aplicación
# ===============================================================

# Terminar el script si algún comando falla
set -euo pipefail

# ==========================================
# DEFINICIÓN DE COLORES PARA OUTPUT
# ==========================================
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

# ==========================================
# FIX DE DNS
# Soluciona problemas de resolución DNS en NAT
# ==========================================
echo -e "${YELLOW}[DB] Configurando DNS...${RESET}"
echo 'nameserver 8.8.8.8' | sudo tee /etc/resolv.conf >/dev/null

# ==========================================
# VARIABLES DE CONFIGURACIÓN
# ==========================================
DB_NAME="appdb"
DB_USER="appuser"
DB_PASS="appsecret"
# IMPORTANTE: Cambiar la red a 192.168.122.0/24
NETWORK_CIDR="192.168.122.0/24"

# ==========================================
# INSTALACIÓN DE POSTGRESQL
# ==========================================
echo -e "${GREEN}[DB] Instalando PostgreSQL...${RESET}"
sudo apt-get update -y || { 
  echo -e "${RED}[DB] Error al actualizar paquetes.${RESET}"; 
  exit 1; 
}
sudo apt-get install -y postgresql postgresql-contrib

# ==========================================
# CONFIGURACIÓN DE POSTGRESQL
# Permitir conexiones remotas desde la red privada
# ==========================================
PG_CONF="/etc/postgresql/$(ls /etc/postgresql)/main/postgresql.conf"
PG_HBA="/etc/postgresql/$(ls /etc/postgresql)/main/pg_hba.conf"

echo -e "${GREEN}[DB] Configurando PostgreSQL para conexiones remotas...${RESET}"

# Permitir escuchar en todas las interfaces
sudo sed -i "s/^#\?listen_addresses.*/listen_addresses = '*'/" "$PG_CONF"

# Agregar regla de acceso para la red privada
if ! grep -q "$NETWORK_CIDR" "$PG_HBA"; then
  echo "host    all             all             $NETWORK_CIDR            md5" | sudo tee -a "$PG_HBA" >/dev/null
fi

# Habilitar e iniciar el servicio
sudo systemctl enable postgresql
sudo systemctl restart postgresql

# ==========================================
# CREACIÓN DE BASE DE DATOS Y DATOS DE PRUEBA
# ==========================================
echo -e "${GREEN}[DB] Creando usuario, base de datos y tabla de estudiantes...${RESET}"

sudo -u postgres psql -v ON_ERROR_STOP=1 <<SQL
-- Crear rol (usuario) si no existe
DO
\$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$DB_USER') THEN
      CREATE ROLE $DB_USER LOGIN PASSWORD '$DB_PASS';
   END IF;
END
\$\$;

-- Crear base de datos
SELECT 'CREATE DATABASE $DB_NAME OWNER $DB_USER'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$DB_NAME')\gexec

-- Conectar a la base de datos
\connect $DB_NAME

-- Crear tabla de estudiantes
CREATE TABLE IF NOT EXISTS students (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar datos de ejemplo (ignorar si ya existen)
INSERT INTO students (name, email) VALUES
  ('Ada Lovelace', 'ada@driosoft.net'),
  ('Alan Turing', 'alan@driosoft.net'),
  ('Grace Hopper', 'grace@driosoft.net'),
  ('Linus Torvalds', 'linus@driosoft.net'),
  ('Katherine Johnson', 'katherine@driosoft.net')
ON CONFLICT (email) DO NOTHING;

-- Otorgar permisos al usuario de la aplicación
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DB_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DB_USER;
SQL

# ==========================================
# VERIFICACIÓN
# ==========================================
echo -e "${GREEN}[DB] Verificando instalación...${RESET}"
sudo -u postgres psql -d $DB_NAME -c "SELECT COUNT(*) as total_students FROM students;"

# ==========================================
# FINALIZACIÓN
# ==========================================
echo -e "${GREEN}[DB] ✓ Base de datos PostgreSQL lista y configurada.${RESET}"
echo -e "${GREEN}[DB] ✓ Base de datos: $DB_NAME${RESET}"
echo -e "${GREEN}[DB] ✓ Usuario: $DB_USER${RESET}"
echo -e "${GREEN}[DB] ✓ IP: 192.168.122.11${RESET}"