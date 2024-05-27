FROM ubuntu:20.04

RUN apt-get update && apt-get install -y \
    iptables \
    squid \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY squid.conf /etc/squid/squid.conf
COPY ip_list.txt /usr/local/bin/ip_list.txt
COPY allowed_ips.txt /etc/squid/allowed_ips.txt
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3128

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
