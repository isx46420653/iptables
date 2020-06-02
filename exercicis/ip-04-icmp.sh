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

#  Denegar els pings a l'exterior (DROP)
iptables -A OUTPUT -p icmp --icmp-type 8 -j DROP

# Denegar els pings al host i26 (DROP)
iptables -A OUTPUT -d i26 -p icmp --icmp-type 8 -j DROP

# Denegar la resposta als pings que ens facin (DROP)
iptables -A INPUT -p icmp --icmp-type 8 -j DROP

# Denegar les respostes als nostres ping (DROP)
iptables -A INPUT -p icmp --icmp-type 0 -j DROP

# Mostrem
iptables -L 
