#!/bin/bash

# Файл со списком разрешенных доменов
ALLOWED_DOMAINS_FILE="/etc/squid/allowed_hosts.txt"
IP_LIST_FILE="/usr/local/bin/ip_list.txt"

# Очистка текущих правил iptables
iptables -F
iptables -X

# Очистка файла ip_list.txt
> "$IP_LIST_FILE"

# Разрешение трафика к указанным доменам
while IFS= read -r DOMAIN
do
    # Пропуск пустых строк и строк, начинающихся с #
    if [[ -n "$DOMAIN" && "$DOMAIN" != \#* ]]; then
        # Получаем IP-адреса для домена
        IPS=$(dig +short "$DOMAIN")

        for IP in $IPS; do
            echo "$IP" >> "$IP_LIST_FILE"
            iptables -A OUTPUT -d "$IP" -j ACCEPT
            iptables -A INPUT -s "$IP" -j ACCEPT
        done
    fi
done < "$ALLOWED_DOMAINS_FILE"

# Отбрасывание всего остального трафика
iptables -A OUTPUT -j DROP
iptables -A INPUT -j DROP

# Запуск Squid proxy
squid -N -f /etc/squid/squid.conf
