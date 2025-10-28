#!/usr/bin/env sh
set -euo pipefail

# Actualizar e instalar paquetes
echo "[WEB] Actualizando repos e instalando Apache + PHP..."
sudo apt-get update -y
sudo apt-get install -y apache2 php libapache2-mod-php php-pgsql rsync

# Habilitar y reiniciar Apache
echo "[WEB] Habilitando y reiniciando Apache..."
sudo systemctl enable apache2
sudo systemctl restart apache2

# Desplegar contenido del sitio web
DOCROOT="/var/www/html"

# Limpiar docroot existente
echo "[WEB] Desplegando contenido desde /vagrant/www hacia ${DOCROOT}..."
if [ -d /vagrant/www ]; then
  sudo rsync -a --delete /vagrant/www/ "${DOCROOT}/"
else
  echo "[WEB][WARN] No existe /vagrant/www (sincronización)."
fi

# Ajustar permisos
echo "[WEB] Ajustando permisos del docroot..."
sudo chown -R www-data:www-data "${DOCROOT}"
sudo find "${DOCROOT}" -type d -exec chmod 755 {} \;
sudo find "${DOCROOT}" -type f -exec chmod 644 {} \;

# Finalizar
echo "[WEB] Listo. Sitio desplegado."