# ===============================================================
# VAGRANTFILE - Configuración de entorno multi-máquina
# Autor: Deyton Riasco Ortiz
# Descripción: Define 2 VMs (web y db) con red privada
# ===============================================================

Vagrant.configure("2") do |config|
  # Deshabilitar actualización automática de box
  config.vm.box_check_update = false
  
  # ==========================================
  # MÁQUINA WEB (Apache + PHP)
  # ==========================================
  config.vm.define "web" do |web|
    # Box base Ubuntu 20.04
    web.vm.box = "generic/ubuntu2004"
    web.vm.hostname = "web"
    
    # Red privada con IP estática
    web.vm.network "private_network", ip: "192.168.122.10"
    
    # Sincronizar carpeta www con rsync
    web.vm.synced_folder "./www", "/vagrant/www", type: "rsync", create: true
    
    # Script de aprovisionamiento
    web.vm.provision "shell", path: "provision-web.sh"
    
    # Configuración de recursos para libvirt
    web.vm.provider :libvirt do |v|
      v.cpus = 1
      v.memory = 1024
    end
  end

  # ==========================================
  # MÁQUINA DB (PostgreSQL) (reto)
  # ==========================================
  config.vm.define "db" do |db|
    # Box base Ubuntu 20.04
    db.vm.box = "generic/ubuntu2004"
    db.vm.hostname = "db"
    
    # Red privada con IP estática
    db.vm.network "private_network", ip: "192.168.122.11"
    
    # Sincronizar directorio raíz (excluyendo .git y www)
    db.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: [".git/", "www/"]
    
    # Script de aprovisionamiento
    db.vm.provision "shell", path: "provision-db.sh"
    
    # Configuración de recursos para libvirt
    db.vm.provider :libvirt do |v|
      v.cpus = 1
      v.memory = 1024
    end
  end
end