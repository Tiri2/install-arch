#!/bin/zsh

TMPLogFiles=(/tmp/log/*.log(N))
DATE=`date +"%F-%H%M%S"`

case "$1" in
    reboot)
        for file in $TMPLogFiles
            do
            /usr/bin/zstdmt "$file" --no-progress -o "/var/log/tasks/$(basename ${file} .log)-${DATE}-halt.log.zstd" >/dev/null 2>&1
        done

        # Shutdown Loggen
        echo -e "====================================\nShutdown: $(/usr/bin/date)" >> /var/log/system/boots.log

        /usr/bin/sudo systemctl reboot
    ;;

    shutdown)
        for file in $TMPLogFiles
            do
            /usr/bin/zstdmt "$file" --no-progress -o "/var/log/tasks/$(basename ${file} .log)-${DATE}-halt.log.zstd" >/dev/null 2>&1
        done

        # Shutdown Loggen
        echo -e "====================================\nShutdown: $(/usr/bin/date)" >> /var/log/system/boots.log

        /usr/bin/sudo systemctl poweroff
    ;;

    # Logdateien komprimieren
    copylogs)
        for file in $TMPLogFiles
            do
            /usr/bin/zstdmt "$file" --no-progress -o "/var/log/tasks/$(basename ${file} .log)-${DATE}-save.log.zstd" >/dev/null 2>&1
        done
    ;;
esac
exit 0