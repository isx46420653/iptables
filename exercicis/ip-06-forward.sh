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

# Activem la NAT per a la xarxa 20
iptables -t nat -A POSTROUTING -s 172.20.0.0/16 -o enp4s0f1 -j MASQUERADE

# Forward
# Denegar l'accés de la xarxa 20 a la 30, però permetre-ho a l'inversa
iptables -A FORWARD -s 172.20.0.0/16 -d 172.30.0.0/16  -j REJECT

# Denegar l'accés de la xarxa 20 al host 2 de la xarxa 30
iptables -A FORWARD -s 172.20.0.0/16 -d 172.30.0.2  -j REJECT

# Denegar l'accés al host 1 de la xarxa 20 cap al host 1 de la xarxa 30
iptables -A FORWARD -s 172.20.0.1 -d 172.30.0.1  -j REJECT

# Denegar l'accés de la xarxa 20 al port 13
iptables -A FORWARD -s 172.20.0.0/16 -p tcp --dport 13 -j REJECT

# Denegar l'accés de la xarxa 20 als ports 2013 de la xarxa 30
iptables -A FORWARD -s 172.20.0.0/16 -d 172.30.0.0/16 -p tcp --dport 2013  -j REJECT

# Permetre a la xarxa 20 només navegar per internet
iptables -A FORWARD -s 172.20.0.0/16 -p tcp -o enp4s0f1 --dport 80 -j ACCEPT
iptables -A FORWARD -d 172.20.0.0/16 -p tcp --sport 80 -i enp4s0f1 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -s 172.20.0.0/16 -p tcp -o enp4s0f1 -j DROP
iptables -A FORWARD -d 172.20.0.0/16 -p tcp -i enp4s0f1 -j DROP

# Permetre que la xarxa 20 pugui accedir al port 2013 de qualsevol xarxa excepte hisx2 (192.168.2.0/24)
iptables -A FORWARD -s 172.20.0.0/16 -d 192.168.1.0/24 -p tcp --dport 2013 -m state --state ESTABLISHED,RELATED -j REJECT
iptables -A FORWARD -s 172.20.0.0/16 -p tcp --dport 2013 -j ACCEPT

# Evitar que sigui falsa l'IP d'origen: SPOOFING
iptables -A FORWARD ! -s 172.20.0.0/16 -i enp4s0f1 -j REJECT

# Mostrem
iptables -L
