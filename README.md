# 🖥️ Configuración de Servidor Empresarial - Parrot OS

Este script automatiza la instalación y configuración de un servidor base para compañías pequeñas o medianas sobre Parrot OS.

## 🔧 Funciones que configura

- Servidor web (Apache2 + PHP)
- Base de datos MySQL
- Servidor SSH
- Firewall UFW con puertos esenciales
- Seguridad básica con Fail2Ban
- Usuario administrador con permisos sudo

## 📦 Requisitos

- Parrot OS (o Kali basado en Debian)
- Usuario root

## 🚀 Uso

```bash
chmod +x configurar_servidor.sh
sudo ./configurar_servidor.sh
```

## 📁 Resultado

- Acceso remoto por SSH
- Página web de prueba: http://[tu_ip]/info.php
- Base sólida para servicios empresariales internos

---

Creado por **ByThesixcay**
