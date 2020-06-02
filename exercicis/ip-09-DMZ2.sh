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
iptables -t nat -A POSTROUTING -s 172.40.0.0/16 -o enp4s0f1 -j MASQUERADE

# Permetre l'accés des de l'exterior al servidor ldap de la DMZ (172.40.0.0/16)
iptables -t nat -A PREROUTING -i enp4s0f1 -p tcp --dport 389 -j DNAT --to 172.40.0.1:389
iptables -t nat -A PREROUTING -i enp4s0f1 -p tcp --dport 636 -j DNAT --to 172.40.0.1:636

# Permetre l'accés des de l'exterior al client kerberos per obtenir un tiquet del servidor a la DMZ
iptables -t nat -A PREROUTING -i enp4s0f1 -p tcp --dport 88 -j DNAT --to 172.40.0.2:88
iptables -t nat -A PREROUTING -i enp4s0f1 -p tcp --dport 543 -j DNAT --to 172.40.0.2:543
iptables -t nat -A PREROUTING -i enp4s0f1 -p tcp --dport 749 -j DNAT --to 172.40.0.2:749

# Permetre l'accés des de l'exterior al recurs samba del servidor de la DMZ
iptables -t nat -A PREROUTING -i enp4s0f1 -p tcp --dport 139 -j DNAT --to 172.40.0.3:139
iptables -t nat -A PREROUTING -i enp4s0f1 -p tcp --dport 445 -j DNAT --to 172.40.0.3:445
