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

# Activem la NAT per a les xarxes privades dels Dockers
iptables -t nat -A POSTROUTING -s 172.20.0.0/16 -o enp4s0f1 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.30.0.0/16 -o enp4s0f1 -j MASQUERADE

# Pau Martín
