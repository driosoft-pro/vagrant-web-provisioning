#!/usr/bin/env bash
# ===============================================================
# PROVISION-WEB.SH
# Autor: Deyton Riasco Ortiz
# Descripción: Instala Apache + PHP, despliega sitio web desde /vagrant/www
# ===============================================================
set -euo pipefail

# ==== Colores ====
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

# ==== Fix de DNS (en caso de error NAT) ====
echo -e "${YELLOW}[WEB] Fix DNS...${RESET}"
echo 'nameserver 8.8.8.8' | sudo tee /etc/resolv.conf >/dev/null

# ==== Actualizar sistema ====
echo -e "${GREEN}[WEB] Actualizando repos e instalando Apache + PHP...${RESET}"
sudo apt-get update -y || { echo -e "${RED}[WEB] Error al actualizar paquetes.${RESET}"; exit 1; }
sudo apt-get install -y apache2 php libapache2-mod-php php-pgsql rsync curl

# ==== Habilitar Apache ====
echo -e "${GREEN}[WEB] Habilitando y reiniciando Apache...${RESET}"
sudo systemctl enable apache2
sudo systemctl restart apache2

# ==== Desplegar sitio ====
DOCROOT="/var/www/html"
SOURCE="/vagrant/www"

echo -e "${GREEN}[WEB] Desplegando contenido desde ${SOURCE} hacia ${DOCROOT}...${RESET}"
if [ -d "$SOURCE" ]; then
  sudo rsync -a --delete "${SOURCE}/" "${DOCROOT}/"
else
  echo -e "${YELLOW}[WEB][WARN] No existe ${SOURCE}. Nada que copiar.${RESET}"
fi

# ==== Permisos ====
echo -e "${GREEN}[WEB] Ajustando permisos...${RESET}"
sudo chown -R www-data:www-data "${DOCROOT}"
sudo find "${DOCROOT}" -type d -exec chmod 755 {} \;
sudo find "${DOCROOT}" -type f -exec chmod 644 {} \;

# ==== Fin ====
echo -e "${GREEN}[WEB] Listo. Sitio web desplegado correctamente.${RESET}"
