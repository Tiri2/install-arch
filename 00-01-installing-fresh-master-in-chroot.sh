#!/bin/bash

# Get files from git
mkdir -p /var/system/tools/
cd /var/system/tools

if [[ -d "/var/system/tools/install-arch/" ]]; then
    git -C /var/system/tools/install-arch/ pull &> /dev/null
else
    git clone https://github.com/Tiri2/install-arch.git /var/system/tools/install-arch/ &> /dev/null
fi

cd /var/system/tools/install-arch/

echo "executing 03-00-root-install.sh"
source ./03-00-root-install.sh

echo "executing 04-00-dir-structure.sh"
source ./04-00-dir-structure.sh

echo "executing 04-01-init-tasks.sh"
source ./04-01-init-tasks.sh

echo "executing 04-02-root-services.sh"
source ./04-02-root-services.sh

echo "executing 04-03-permissions.sh"
source ./04-03-permissions.sh

echo "executing 05-root-finalize.sh"
source ./05-root-finalize.sh