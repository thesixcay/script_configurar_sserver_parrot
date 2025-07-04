#!/bin/bash

# Colores
verde="\e[32m"
rojo="\e[31m"
azul="\e[34m"
normal="\e[0m"

# Banner
clear
echo -e "${verde}"
echo "╔════════════════════════════════════╗"
echo "║     🖥️ CONFIGURACIÓN DE SERVIDOR    ║"
echo "║       PARA USO EMPRESARIAL         ║"
echo "║         ByThesixcay                ║"
echo "╚════════════════════════════════════╝"
echo -e "${normal}"

# Verificar permisos de root
if [[ $EUID -ne 0 ]]; then
  echo -e "${rojo}❌ Este script debe ejecutarse como root.${normal}"
  exit 1
fi

# Actualizar sistema
echo -e "${azul}🔄 Actualizando sistema...${normal}"
apt update && apt upgrade -y

# Instalar servicios comunes
echo -e "${azul}📦 Instalando servicios básicos...${normal}"
apt install -y openssh-server apache2 mysql-server php libapache2-mod-php php-mysql ufw fail2ban net-tools curl htop git unzip

# Crear usuario de administración
read -p "👤 Ingresa el nombre del nuevo usuario admin: " adminuser
adduser $adminuser
usermod -aG sudo $adminuser

# Configurar firewall
echo -e "${azul}🧱 Configurando UFW...${normal}"
ufw allow OpenSSH
ufw allow 80
ufw allow 443
ufw --force enable

# Habilitar servicios
echo -e "${azul}⚙️ Habilitando servicios en el arranque...${normal}"
systemctl enable ssh
systemctl enable apache2
systemctl enable mysql

# Iniciar servicios
systemctl start ssh
systemctl start apache2
systemctl start mysql

# Crear página web de prueba
echo "<?php phpinfo(); ?>" > /var/www/html/info.php

# Mostrar IP
ip=$(hostname -I | awk '{print $1}')
echo -e "${verde}✅ Servidor web activo: http://$ip/info.php${normal}"

# Configurar Fail2Ban
echo -e "${azul}🔐 Protegiendo con Fail2Ban...${normal}"
systemctl enable fail2ban
systemctl start fail2ban

# Mostrar resumen
echo -e "${verde}"
echo "🚀 CONFIGURACIÓN COMPLETA:"
echo "   - SSH en puerto 22"
echo "   - Apache2 + PHP + MySQL"
echo "   - UFW activado con puertos 22, 80 y 443"
echo "   - Usuario admin: $adminuser"
echo -e "${normal}"
