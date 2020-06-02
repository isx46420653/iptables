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

# Fem port forwading dels ports 5001, 5002 i 5003 al port 13 del host 1 de la xarxa 20
iptables -t nat -A PREROUTING -i enp4s0f1 -p tcp --dport 5001 -j DNAT --to 172.20.0.1:13
iptables -t nat -A PREROUTING -i enp4s0f1 -p tcp --dport 5002 -j DNAT --to 172.20.0.1:13
iptables -t nat -A PREROUTING -i enp4s0f1 -p tcp --dport 5003 -j DNAT --to 172.20.0.1:13

# Denegar l'accés al port 13 per a que el forward dels ports 5001 i 5002 no funcionin
iptables -A FORWARD  -p tcp --dport 13 -j REJECT

# Esborrem la regla forward
iptables -D FORWARD 1

# Denegar l'accés al port 13, ara el port 5003 deixa de funcionar.
iptables -A INPUT  -p tcp --dport 13 -j REJECT

# Mostrem
iptables -L
