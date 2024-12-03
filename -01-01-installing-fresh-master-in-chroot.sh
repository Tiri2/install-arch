#!/bin/bash

echo "executing 03-00-root-install.sh"
source 03-00-root-install.sh

echo "executing 04-00-dir-structure.sh"
source 04-00-dir-structure.sh

echo "executing 04-01-init-tasks.sh"
source 04-01-init-tasks.sh

echo "executing 04-02-root-services.sh"
source 04-02-root-services.sh

echo "executing 05-root-finalize.sh"
source 05-root-finalize.sh