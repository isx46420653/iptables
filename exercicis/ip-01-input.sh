#!/bin/bash

# Regles Flush: buidar les regles actuals
iptables -F
iptables -X
iptables -Z
iptables -t nat -F

# Establir la politica per defecte (ACCEPT)
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

# Acceptar al localhost les connexions locals
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Acceptar a la nostra IP local les connexions locals
iptables -A INPUT -s 192.168.1.180 -j ACCEPT
iptables -A OUTPUT -d 192.168.1.180 -j ACCEPT

# Acceptem el port 80 del servidor web
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Tanquem el port 2080 (REJECT)
iptables -A INPUT -p tcp --dport 2080 -j REJECT

# Tanquem el port 3080 excepte al host i26 (DROP)
iptables -A INPUT -s i26 -p tcp --dport 3080 -j ACCEPT
iptables -A INPUT -p tcp --dport 3080 -j DROP

# Obrim el port 4080 a tothom excepte al host i26 (DROP)
iptables -A INPUT -s i26 -p tcp --dport 4080 -j DROP
iptables -A INPUT -p tcp --dport 4080 -j ACCEPT

# Tanquem el port 5080 a tothom, l'obrim per a la xarxa 192.168.2.0/24 i el tanquem per al host i26.
iptables -A INPUT -s i26 -p tcp --dport 5080 -j DROP
iptables -A INPUT -s 192.168.2.0/24 -p tcp --dport 5080 -j ACCEPT
iptables -A INPUT -p tcp --dport 5080 -j DROP

# Mostrem
iptables -L

# Pau Martín
