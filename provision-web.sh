#!/usr/bin/env bash
# ===============================================================
# PROVISION-WEB.SH
# Autor: Deyton Riasco Ortiz
# Descripción: Instala Apache + PHP, despliega sitio web desde /vagrant/www
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
echo -e "${YELLOW}[WEB] Configurando DNS...${RESET}"
echo 'nameserver 8.8.8.8' | sudo tee /etc/resolv.conf >/dev/null

# ==========================================
# INSTALACIÓN DE APACHE Y PHP
# ==========================================
echo -e "${GREEN}[WEB] Actualizando repositorios e instalando Apache + PHP...${RESET}"
sudo apt-get update -y || { 
  echo -e "${RED}[WEB] Error al actualizar paquetes.${RESET}"; 
  exit 1; 
}

# Instalar Apache, PHP y extensiones necesarias
sudo apt-get install -y \
  apache2 \
  php \
  libapache2-mod-php \
  php-pgsql \
  rsync \
  curl

# ==========================================
# CONFIGURACIÓN DE APACHE
# ==========================================
echo -e "${GREEN}[WEB] Habilitando y reiniciando Apache...${RESET}"

# Habilitar módulos de Apache
sudo a2enmod php7.4 || sudo a2enmod php

# Habilitar el servicio para iniciar con el sistema
sudo systemctl enable apache2
sudo systemctl restart apache2

# ==========================================
# DESPLIEGUE DEL SITIO WEB
# ==========================================
DOCROOT="/var/www/html"
SOURCE="/vagrant/www"

echo -e "${GREEN}[WEB] Desplegando contenido desde ${SOURCE} hacia ${DOCROOT}...${RESET}"

if [ -d "$SOURCE" ]; then
  # Sincronizar archivos desde la carpeta compartida
  sudo rsync -a --delete "${SOURCE}/" "${DOCROOT}/"
  echo -e "${GREEN}[WEB] ✓ Archivos desplegados correctamente.${RESET}"
else
  echo -e "${YELLOW}[WEB][WARN] No existe ${SOURCE}. Nada que copiar.${RESET}"
  # Crear un index.html básico si no existe contenido
  echo "<h1>Vagrant Web Server</h1><p>Coloca tus archivos en ./www/</p>" | sudo tee "${DOCROOT}/index.html" >/dev/null
fi

# ==========================================
# AJUSTE DE PERMISOS
# Asegurar que Apache pueda leer los archivos
# ==========================================
echo -e "${GREEN}[WEB] Ajustando permisos...${RESET}"

# Cambiar propietario a www-data (usuario de Apache)
sudo chown -R www-data:www-data "${DOCROOT}"

# Permisos: 755 para directorios, 644 para archivos
sudo find "${DOCROOT}" -type d -exec chmod 755 {} \;
sudo find "${DOCROOT}" -type f -exec chmod 644 {} \;

# ==========================================
# VERIFICACIÓN
# ==========================================
echo -e "${GREEN}[WEB] Verificando instalación de PHP...${RESET}"
php -v

# ==========================================
# FINALIZACIÓN
# ==========================================
echo -e "${GREEN}[WEB] ✓ Servidor web Apache + PHP configurado correctamente.${RESET}"
echo -e "${GREEN}[WEB] ✓ Accede desde: http://192.168.122.10${RESET}"