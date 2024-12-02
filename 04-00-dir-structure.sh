# Following directory structure will be created
mkdir /var/system
mkdir /var/system/tools
mkdir /var/system/scripts
mkdir /var/system/certs
mkdir /var/system/backup

chmod 775 /var/system
chmod 775 /var/system/*

# Create under directories in srv
mkdir -p /srv/{tasks,http,smb}
chmod 777 /srv/tasks
chmod 775 /srv/http
chmod 777 /srv/smb

# Creating specifc smb folders
mkdir -p /srv/smb/share
mkdir -p /srv/smb/backup

chmod 775 /srv/smb/*

# Creating tasks specifc folders
mkdir /srv/tasks/CORE-2.0.0-SNAPSHOT/
ln -sf /srv/tasks/CORE-2.0.0-SNAPSHOT/ /srv/tasks/CURRENT

mkdir /srv/tasks/CURRENT/{default,libs}
ln -sf /var/system/certs/ /srv/tasks/CURRENT/default/certs
ln -sf /srv/tasks/CURRENT/libs/ /srv/tasks/CURRENT/default/libs

echo "File Structure created"
echo "Next Script will be 04-01-init-tasks.sh"