#!/bin/bash

echo "[$(date)] Starting updating system" >> /var/log/system/updates.log
start_time=$(date +%s)

pacman -Syu

if [[ -d "/var/system/tools/install-arch/" ]]; then
    git -C /var/system/tools/install-arch/ pull
else
    git clone https://github.com/Tiri2/install-arch.git /var/system/tools/install-arch/
fi


cd /var/system/tools/install-arch
cp misc/.zshrc /root

cp misc/.zshrc /home/flex
chown flex:flex /home/flex/.zshrc

end_time=$(date +%s)
duration=$((end_time - start_time))

echo "[$(date)] Successfully updated system" >> /var/log/system/updates.log
echo "[$(date)] Took ${duration}s to updating" >> /var/log/system/updates.log