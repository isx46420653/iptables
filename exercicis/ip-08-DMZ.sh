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
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT

# Acceptar al localhost les connexions locals
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Acceptar a la nostra IP local les connexions locals
iptables -A INPUT -s 192.168.1.180 -j ACCEPT
iptables -A OUTPUT -d 192.168.1.180 -j ACCEPT

# Activem la NAT per a les xarxes privades dels Dockers
iptables -t nat -A POSTROUTING -s 172.20.0.0/16 -o enp4s0f1 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.30.0.0/16 -o enp4s0f1 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.40.0.0/16 -o enp4s0f1 -j MASQUERADE

# Permetre l'accés de la xarxa 20 als ports 22 i 13
iptables -A FORWARD -s 172.20.0.0/16  -p tcp --dport 22  -j ACCEPT
iptables -A FORWARD -s 172.20.0.0/16  -p tcp --dport 13  -j ACCEPT
iptables -A FORWARD -s 172.20.0.0/16  -p tcp  -j REJECT

# Permetre l'accés exterior només a servidors web, ssh o daytime al port 2013
iptables -A FORWARD -s 172.20.0.0/16 -o enp4s0f1 -p tcp --dport 22  -j ACCEPT
iptables -A FORWARD -s 172.20.0.0/16 -o enp4s0f1 -p tcp --dport 2013  -j ACCEPT
iptables -A FORWARD -d 172.20.0.0/16 -o enp4s0f1 -p tcp --sport 80 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -s 172.20.0.0/16 -o enp4s0f1 -p tcp --dport 80  -j ACCEPT
iptables -A FORWARD -s 172.20.0.0/16 -o enp4s0f1 -p tcp -j DROP

# Permetre a la xarxa 20 accedir al servidor web de la DMZ
iptables -A FORWARD -s 172.20.0.0/16 -d 172.40.0.0/16 -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -s 172.20.0.0/16 -d 172.40.0.0/16 -j DROP

# Redirigim els ports per a que es tingui accés des de fora
iptables -t nat -A PREROUTING -i enp4s0f1 -p tcp --dport 3001 -j DNAT --to 172.20.0.1:80
iptables -t nat -A PREROUTING -i enp4s0f1 -p tcp --dport 3002 -j DNAT --to 172.20.0.2.2013
iptables -t nat -A PREROUTING -i enp4s0f1 -p tcp --dport 3003 -j DNAT --to 172.30.0.1:2080
iptables -t nat -A PREROUTING -i enp4s0f1 -p tcp --dport 3004 -j DNAT --to 172.30.0.2:2007

# Redirigim els ports 4001 en endavant per a tenir accés a ssh a tots els hosts
iptables -t nat -A PREROUTING -i enp4s0f1 -p tcp --dport 4001 -j DNAT --to 172.20.0.1:22
iptables -t nat -A PREROUTING -i enp4s0f1 -p tcp --dport 4002 -j DNAT --to 172.20.0.2.22
iptables -t nat -A PREROUTING -i enp4s0f1 -p tcp --dport 4003 -j DNAT --to 172.30.0.1:22
iptables -t nat -A PREROUTING -i enp4s0f1 -p tcp --dport 4004 -j DNAT --to 172.30.0.2:22

# Redirigim el port 4000 per a tenir accés ssh al router si l'origen és el host i26
iptables -t nat -A PREROUTING -i enp4s0f1 -p tcp --dport 4000 -s i26 -j DNAT --to 192.168.1.180:22

# Denegar l'accés dels hosts de la xarxa 30 a la xarxa 20 (DROP)
iptables -A FORWARD -s 172.30.0.0/16 -d 172.20.0.0/16 -p tcp  -j DROP

# Mostrem
iptables -L
