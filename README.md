# Taller: Vagrant Web + DB (Provisionamiento con Shell)

¡Bienvenido! En este taller vas a levantar **dos máquinas virtuales** con Vagrant y QEMU/libvirt:
- **web**: con Apache + PHP para servir una página sencilla.
- **db**: con PostgreSQL para guardar datos y consultarlos desde PHP.

La idea es que puedas verlo funcionando rápido, sin enredos.

---

## ¿Qué vas a construir?
Una página web simple que se despliega en la VM **web** y una segunda página (`info.php`) que:
1) comprueba que PHP funciona y  
2) **lee datos** de una tabla en **PostgreSQL** que vive en la VM **db**.

---

## Requisitos
- **Vagrant** instalado.
- **QEMU/KVM + libvirt** (en NixOS u otra distro Linux).
- **Plugin de Vagrant para libvirt**:
  ```bash
  vagrant plugin install vagrant-libvirt
  ```

> Usamos una red privada con IPs por defecto: **web = 192.168.122.10**, **db = 192.168.122.11**.  
> Si cambiaste estas IPs en tu `Vagrantfile`, usa las tuyas al probar.

---

## Pasos rápidos
1. Clona tu fork del repositorio y entra a la carpeta.
2. Asegúrate de tener la carpeta `www/` con `index.html` e `info.php` (ya vienen listos).
3. Levanta las máquinas (recomendado en Linux/NixOS):
   ```bash
   export VAGRANT_DEFAULT_PROVIDER=libvirt
   vagrant up
   ```
4. Abre en tu navegador:
   - Sitio: **http://192.168.122.10**
   - PHP + BD: **http://192.168.122.10/info.php**

Si ves una tabla con dos filas (Ada Lovelace y Alan Turing), ¡todo quedó OK! 🎉

---

## Estructura básica del proyecto
```
Vagrantfile
provision-web.sh
provision-db.sh
www/
  ├─ index.html
  └─ info.php
```

- `provision-web.sh`: instala **Apache + PHP** y publica `www/` en `/var/www/html`.
- `provision-db.sh`: instala **PostgreSQL**, permite conexiones desde la red privada y crea la base, la tabla y datos de ejemplo.

---

## Reto (lo que te piden)
1. **Provisiona la base de datos**: ya está automatizado en `provision-db.sh` (crea BD, tabla y datos).
2. **Conecta PHP a PostgreSQL**: ya lo hace `www/info.php` (lee y muestra datos).
3. **Cambia tu página**: edita `www/index.html` con tu nombre o estilo.
4. **Documenta**: agrega **capturas de pantalla** del sitio y de la tabla (puedes guardarlas en `docs/` y enlazarlas aquí).

Sugerencia de capturas:
- `docs/web-home.png` (pantalla principal)  
- `docs/web-info-php.png` (tabla con datos)

---

## Comandos útiles
```bash
vagrant status          # ver estado
vagrant ssh web         # entrar a la VM web
vagrant ssh db          # entrar a la VM db
vagrant provision web   # re-provisionar la VM web
vagrant reload web      # reiniciar la VM web
vagrant halt            # apagar
vagrant destroy -f      # destruir todo
```

---

## Problemas comunes (rápidas soluciones)
- **No abre la web**: espera 1–2 minutos luego de `vagrant up` y recarga.  
- **No aparece la tabla**: reinicia la web o reprovisiona (`vagrant provision web`).  
- **Cambié las IPs**: revisa que `info.php` apunte a la IP real de la DB.  
- **Carpeta `www/` vacía**: asegúrate de tener `index.html` e `info.php` dentro de `www/`.

---

## ✍️ Créditos
- Fork: **https://github.com/jmaquin0/vagrant-web-provisioning.git** 
- Modifico: **Deyton Riasco Ortiz**  
- Email: **driosoftpro@gmail.com**  
- Sitio web: **driosoft-pro.gitlab.io**
