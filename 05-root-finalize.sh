#!/bin/bash

echo "Is this script running after installation or current installation?"
read -p "a (after) / c (current): " WHEN_RUNNING

if [[ $WHEN_RUNNING == "c" ]]; then 
    echo "Please run this script after installation to finalize this process."
    exit 1
fi

# Creating a snapshot for each entries
snapper -c root create -d "Root finalize"
snapper -c home create -d "Root finalize"
snapper -c srv create -d "Root finalize"

# Setting up firewalld
echo "setting up firewalld"

echo "starting and enabling firewalld"
systemctl enable --now firewalld

firewall-cmd --list-all
# allowing ssh port
firewall-cmd --permanent --add-service=ssh --zone=public
firewall-cmd --permanent --add-service=postgresql --zone=public
firewall-cmd --permanent --add-service=http --zone=public
firewall-cmd --permanent --add-service=https --zone=public
# allowing smb port
firewall-cmd --permanent --add-port=445/tcp --zone=public
# allowing netbios ports
firewall-cmd --permanent --add-port=139/tcp --zone=public
firewall-cmd --permanent --add-port=137/udp --zone=public
firewall-cmd --permanent --add-port=138/udp --zone=public
firewall-cmd --permanent --add-port=8150/tcp --zone=public

# Reloading firewall
echo "ports opened - reloading firewall..."
firewall-cmd --reload

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
cd $SCRIPT_DIR


USER=whoami

if [[ $USER == "root" ]]; then
    loginctl enable-linger flex
fi

echo "Installing missing packages"
pacman -Sy --noconfirm htop btop ripgrep less curl iputils net-tools bind rsync tcpdump wget zstd jq polkit 7zip

echo "Setting up postgres"
# Setting up postgres
sudo -iu postgres initdb -D /var/lib/postgres/data
systemctl enable --now postgresql
cp /var/lib/postgres/data/postgresql.conf /var/lib/postgres/data/postgresql.conf.old
cp /var/lib/postgres/data/pg_hba.conf /var/lib/postgres/data/pg_hba.conf.old
cat configs/postgres/postgresql.txt > /var/lib/postgres/data/postgresql.conf
cat configs/postgres/pg_hba.txt > /var/lib/postgres/data/pg_hba.conf

# Variablen
DB_NAME="Database"
DB_USER="flex"
DB_PASSWORD="your_secure_password"
SCHEMAS=("public" "erp" "specific")

# Datenbank und Benutzer erstellen
sudo -u postgres psql <<EOF
-- Datenbank erstellen
CREATE DATABASE "$DB_NAME";

-- Benutzer erstellen und Passwort setzen
CREATE USER "$DB_USER" WITH PASSWORD '$DB_PASSWORD';

-- Rechte zuweisen
GRANT ALL PRIVILEGES ON DATABASE "$DB_NAME" TO "$DB_USER";

\c "$DB_NAME"

-- Schemas erstellen
$(for schema in "${SCHEMAS[@]}"; do echo "CREATE SCHEMA IF NOT EXISTS $schema AUTHORIZATION $DB_USER;"; done)

-- Rechte für Benutzer auf die Schemas zuweisen
$(for schema in "${SCHEMAS[@]}"; do echo "GRANT ALL PRIVILEGES ON SCHEMA $schema TO $DB_USER;"; done)
EOF

echo "Datenbank $DB_NAME mit Benutzer $DB_USER wurde erfolgreich erstellt und für externe Zugriffe konfiguriert."


systemctl restart postgresql

# Creating boots log file
mkdir -p "/var/log/system/"
touch /var/log/system/boot.log

chmod 600 /etc/modprobe.d/*

# SMB User
echo "Please enter the password for the smb connection - user: flex"
sudo smbpasswd -a flex

echo "finished"
