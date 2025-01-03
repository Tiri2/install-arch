
# TODO: suche alle subvolumes zusammen und komprimiere sie und füge alle in ein tar oder so zusammen

# Befehl für ein subvolume: btrfs send <volume> | zstd -9 -o <volume>.zst
# Befehl für alle zusammen fügen: "tar -cpf backup-$(date +%Y%m%d)-$(cat /etc/hostname) <volumes.zst>" 