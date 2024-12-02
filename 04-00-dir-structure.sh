# Following directory structure will be created
mkdir -p /var/system/{tools,scripts,certs,backup}

# Create under directories in srv
mkdir -p /srv/{tasks,http,smb}

# Creating specifc smb folders
mkdir -p /srv/smb/share
mkdir -p /srv/smb/backup

# Creating tasks specifc folders
mkdir -p /srv/tasks/CORE-2.0.0-SNAPSHOT
ln -sf /srv/tasks/CORE-2.0.0/ /srv/tasks/CURRENT

mkdir -p /srv/tasks/CURRENT/{default,libs}
ln -sf /var/system/certs/ /srv/tasks/CURRENT/default/certs
ln -sf /srv/tasks/CURRENT/libs/ /srv/tasks/CURRENT/default/libs

echo "File Structure created"
echo "Next Script will be 04-01-init-tasks.sh"