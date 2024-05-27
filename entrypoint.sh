#!/bin/bash

# Файл со списком разрешенных IP-адресов
IP_LIST_FILE="/usr/local/bin/ip_list.txt"

# Очистка текущих правил iptables
iptables -F
iptables -X

# Разрешение трафика к указанным IP-адресам
while IFS= read -r IP
do
    # Пропуск пустых строк и строк, начинающихся с #
    if [[ -n "$IP" && "$IP" != \#* ]]; then
        iptables -A OUTPUT -d "$IP" -j ACCEPT
        iptables -A INPUT -s "$IP" -j ACCEPT
    fi
done < "$IP_LIST_FILE"

# Отбрасывание всего остального трафика
iptables -A OUTPUT -j DROP
iptables -A INPUT -j DROP

# Запуск Squid proxy
squid -N -f /etc/squid/squid.conf
