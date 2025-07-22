#!/bin/zsh
psql -U postgres -d Database -c 'CALL erp.create_partitions()'
