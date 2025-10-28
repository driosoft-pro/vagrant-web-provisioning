Vagrant.configure("2") do |config|
  # Usaremos libvirt como provider único
  config.vm.box_check_update = false
  
  # Máquina WEB (Apache + PHP) 
  config.vm.define "web" do |web|
    web.vm.box = "generic/ubuntu2004"
    web.vm.hostname = "web"
    web.vm.network "private_network", ip: "192.168.56.10"
    # Sincronizar 'www' y dejarla lista para copiar a /var/www/html
    web.vm.synced_folder "./www", "/vagrant/www", type: "rsync", create: true
    # Provisionar la máquina web
    web.vm.provision "shell", path: "provision-web.sh"
    # Recursos libvirt
    web.vm.provider :libvirt do |v|
      v.cpus = 1
      v.memory = 1024
    end
  end

  # Máquina DB (reto) (PostgreSQL)
  config.vm.define "db" do |db|
    db.vm.box = "generic/ubuntu2004"
    db.vm.hostname = "db"
    db.vm.network "private_network", ip: "192.168.56.11"
    # Sincroniza el directorio actual (donde está el Vagrantfile)
    db.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: [".git/", "www/"]
    # Provisionar la máquina db
    db.vm.provision "shell", path: "provision-db.sh"
    # Recursos libvirt
    db.vm.provider :libvirt do |v|
      v.cpus = 1
      v.memory = 1024
    end
  end
end
