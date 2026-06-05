#!/bin/bash
set -e

########################################

# CONFIGURACIÓN

########################################

USER_NAME="operador"
USER_PASS="CambiarEstaPassword123!"
WINDOWS_VERSION="11"
RAM_SIZE="8G"
CPU_CORES="4"
DISK_SIZE="200G"

########################################

# VALIDAR ROOT

########################################

if [ "$EUID" -ne 0 ]; then
echo "Ejecute este script como root"
exit 1
fi

echo "========================================="
echo " Instalación Docker + Windows + WinApps "
echo "========================================="

########################################

# 1. INSTALAR DOCKER

########################################

echo "=== Instalando dependencias ==="

apt-get update -y
apt-get install -y 
apt-transport-https 
ca-certificates 
curl 
gnupg 
lsb-release 
sudo 
git 
make 
binutils 
freerdp2-x11 
xdotool 
cabextract 
fonts-wine 
winbind 
libpulse0 
pulseaudio-utils 
p7zip-full 
p7zip-rar

if ! command -v docker &>/dev/null; then
echo "=== Instalando Docker ==="
curl -fsSL https://get.docker.com | sh
fi

systemctl enable docker
systemctl start docker

########################################

# 2. CREAR USUARIO

########################################

if ! id "$USER_NAME" &>/dev/null; then
echo "=== Creando usuario $USER_NAME ==="

```
useradd -m -s /bin/bash "$USER_NAME"

echo "$USER_NAME:$USER_PASS" | chpasswd

usermod -aG docker "$USER_NAME"
```

fi

########################################

# 3. KVM Y TUN

########################################

echo "=== Configurando KVM y TUN ==="

groupadd -f docker

chown root:docker /dev/kvm || true
chmod 660 /dev/kvm || true

mkdir -p /dev/net || true

chown root:docker /dev/net/tun || true
chmod 666 /dev/net/tun || true

cat <<EOF >/etc/udev/rules.d/99-kvm.rules
KERNEL=="kvm", MODE="0660", GROUP="docker"
KERNEL=="tun", MODE="0666", GROUP="docker"
EOF

udevadm control --reload-rules
udevadm trigger

########################################

# 4. IP FORWARD

########################################

echo "=== Activando IP Forwarding ==="

sysctl -w net.ipv4.ip_forward=1

if ! grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf; then
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
fi

########################################

# 5. LIMPIAR CONTENEDOR

########################################

echo "=== Eliminando contenedor previo ==="

if docker ps -a --format '{{.Names}}' | grep -q '^windows$'; then
docker stop windows || true
docker rm -f windows || true
fi

########################################

# 6. DOCKER COMPOSE

########################################

echo "=== Generando docker-compose.yml ==="

mkdir -p /home/$USER_NAME/windows
mkdir -p /srv/windows

cat <<EOF >/home/$USER_NAME/docker-compose.yml
version: "3.9"

services:
windows:
image: dockurr/windows
container_name: windows

```
environment:
  VERSION: "$WINDOWS_VERSION"
  RAM_SIZE: "$RAM_SIZE"
  CPU_CORES: "$CPU_CORES"
  DISK_SIZE: "$DISK_SIZE"

devices:
  - /dev/kvm
  - /dev/net/tun

cap_add:
  - NET_ADMIN

ports:
  - 8006:8006
  - 3389:3389/tcp
  - 3389:3389/udp

volumes:
  - /srv/windows:/storage

restart: always
stop_grace_period: 2m
```

EOF

chown -R $USER_NAME:$USER_NAME /home/$USER_NAME

########################################

# 7. LEVANTAR WINDOWS

########################################

echo "=== Iniciando Windows Docker ==="

sudo -u $USER_NAME bash -c "
cd /home/$USER_NAME
docker compose up -d
"

########################################

# 8. WINAPPS

########################################

echo "=== Instalando WinApps ==="

cd /home/$USER_NAME

if [ ! -d "winapps" ]; then
git clone https://github.com/winapps-org/winapps.git
fi

mkdir -p /home/$USER_NAME/.config/winapps

cat <<EOF >/home/$USER_NAME/.config/winapps/winapps.conf
RDP_USER=Administrador
RDP_PASS=CambiarPasswordWindows
RDP_IP=127.0.0.1
RDP_PORT=3389
DEBUG=0
MULTIMON="false"
EOF

chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/winapps
chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/.config

########################################

# 9. ACCESOS DIRECTOS

########################################

echo "=== Generando lanzadores WinApps ==="

sudo -u $USER_NAME bash -c "
cd /home/$USER_NAME/winapps
./install.sh
"

########################################

# FINAL

########################################

echo ""
echo "========================================="
echo " INSTALACIÓN COMPLETADA "
echo "========================================="
echo ""
echo "Usuario Linux: $USER_NAME"
echo "Contraseña Linux: $USER_PASS"
echo ""
echo "RDP Windows:"
echo "127.0.0.1:3389"
echo ""
echo "Web UI:"
echo "http://localhost:8006"
echo ""
echo "IMPORTANTE:"
echo "Cambie las contraseñas antes de producción."
echo ""
