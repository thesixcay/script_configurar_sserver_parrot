#!/bin/bash

#===================[ CONFIGURACIÓN INICIAL ]===================
# Colores
verde="\e[32m"
rojo="\e[31m"
azul="\e[34m"
amarillo="\e[33m"
normal="\e[0m"

# Log de instalación
LOGFILE="/var/log/setup_empresa.log"

# Función para imprimir y registrar
log() {
    echo -e "$1"
    echo -e "$(date '+%F %T') - ${1//\\e\[*/}" >> "$LOGFILE"
}

#===================[ BANNER ]===================
clear
echo -e "${verde}"
echo "╔════════════════════════════════════════════╗"
echo "║      🛠️ CONFIGURACIÓN DE SERVIDOR LINUX      ║"
echo "║         Optimizado para empresas            ║"
echo "║                ByThesixcay                  ║"
echo "╚════════════════════════════════════════════╝"
echo -e "${normal}"

#===================[ VERIFICACIÓN DE ROOT ]===================
if [[ $EUID -ne 0 ]]; then
  log "${rojo}❌ Debes ejecutar este script como root.${normal}"
  exit 1
fi

#===================[ ACTUALIZACIÓN DEL SISTEMA ]===================
log "${azul}🔄 Actualizando sistema...${normal}"
export DEBIAN_FRONTEND=noninteractive
apt update -y && \
apt upgrade -yq --allow-downgrades --allow-remove-essential --allow-change-held-packages >> "$LOGFILE" 2>&1 || {
    log "${rojo}❌ Error al actualizar el sistema.${normal}"
    exit 1
}

#===================[ INSTALACIÓN DE PAQUETES BÁSICOS ]===================
log "${azul}📦 Instalando servicios necesarios...${normal}"
apt install -y openssh-server apache2 mysql-server php libapache2-mod-php php-mysql \
ufw fail2ban net-tools curl htop git unzip sudo wget >> "$LOGFILE" 2>&1 || {
    log "${rojo}❌ Error al instalar paquetes.${normal}"
    exit 1
}

#===================[ CREACIÓN DE USUARIO ADMIN ]===================
read -p "👤 Ingresa el nombre del nuevo usuario admin: " adminuser
adduser "$adminuser"
usermod -aG sudo "$adminuser"
log "${verde}✅ Usuario $adminuser creado y agregado al grupo sudo.${normal}"

#===================[ CONFIGURACIÓN DE UFW ]===================
log "${azul}🧱 Configurando Firewall UFW...${normal}"
ufw allow OpenSSH
ufw allow 80
ufw allow 443
ufw --force enable
log "${verde}✅ UFW habilitado y configurado.${normal}"

#===================[ SERVICIOS ]===================
log "${azul}⚙️ Habilitando e iniciando servicios...${normal}"
for service in ssh apache2 mysql fail2ban; do
    systemctl enable "$service"
    systemctl start "$service"
done

#===================[ PÁGINA DE PRUEBA ]===================
echo "<?php phpinfo(); ?>" > /var/www/html/info.php
chmod 644 /var/www/html/info.php
log "${verde}✅ Página PHP de prueba creada.${normal}"

#===================[ MOSTRAR IP DEL SERVIDOR ]===================
ip=$(hostname -I | awk '{print $1}')
log "${verde}🌐 Servidor web disponible: http://$ip/info.php${normal}"

#===================[ SEGURIDAD ADICIONAL ]===================
log "${azul}🔐 Reforzando seguridad adicional...${normal}"

# Desactivar root por SSH
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart ssh

# Configuración básica de Fail2Ban
cat <<EOF > /etc/fail2ban/jail.local
[sshd]
enabled = true
port = ssh
logpath = %(sshd_log)s
bantime = 1h
findtime = 10m
maxretry = 4
EOF

systemctl restart fail2ban
log "${verde}✅ Seguridad adicional aplicada.${normal}"

#===================[ RESUMEN FINAL ]===================
echo -e "${verde}"
echo "🚀 CONFIGURACIÓN FINALIZADA:"
echo "   🔹 SSH en puerto 22 (root deshabilitado)"
echo "   🔹 Apache2 + PHP + MySQL instalados"
echo "   🔹 UFW con puertos 22, 80 y 443 habilitados"
echo "   🔹 Fail2Ban activo"
echo "   🔹 Página de prueba: http://$ip/info.php"
echo "   🔹 Usuario admin creado: $adminuser"
echo -e "${normal}"
