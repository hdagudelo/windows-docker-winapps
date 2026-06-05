# Windows Docker + WinApps Installer

Automatiza la instalación de:

* Docker
* Windows 11 en contenedor usando Dockurr
* WinApps
* Configuración KVM
* Acceso RDP
* Integración Linux ↔ Windows

Compatible con:

* Debian
* Ubuntu
* Proxmox VE
* VPS con virtualización habilitada

---

# Características

* Instalación automática de Docker
* Despliegue de Windows 11 en contenedor
* Configuración automática de `/dev/kvm`
* Soporte WinApps
* Integración con escritorio Linux
* RDP habilitado
* Docker Compose automático

---

# Requisitos

## Virtualización habilitada

Verifique:

```bash
egrep -c '(vmx|svm)' /proc/cpuinfo
```

Debe devolver un valor mayor a `0`.

---

# Instalación

## 1. Clonar repositorio

```bash
git clone https://github.com/TU_USUARIO/windows-docker-winapps.git
cd windows-docker-winapps
```

## 2. Dar permisos

```bash
chmod +x install.sh
```

## 3. Ejecutar

```bash
sudo ./install.sh
```

---

# Accesos

## Windows Web UI

```text
http://localhost:8006
```

## RDP

```text
127.0.0.1:3389
```

---

# Configuración WinApps

Archivo:

```bash
~/.config/winapps/winapps.conf
```

Ejemplo:

```ini
RDP_USER=Administrador
RDP_PASS=TuPassword
RDP_IP=127.0.0.1
RDP_PORT=3389
```

---

# Docker Compose

El script genera automáticamente:

```bash
/home/operador/docker-compose.yml
```

---

# Seguridad

⚠️ Cambie las contraseñas antes de usar en producción.

⚠️ No exponga RDP directamente a Internet.

⚠️ Use firewall y VPN.

---

# Screenshots

Agregue imágenes en:

```text
screenshots/
```

---

# Créditos

Basado en:

* Dockurr Windows
* WinApps
* Docker

---

# Licencia

MIT
