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

# Permetre l'accés a qualsevol port 13 extern
iptables -A OUTPUT -p tcp --dport 13 -j ACCEPT

# Permetre accés a qualsevol port 2013 extern excepte el del i26 (DROP)
iptables -A OUTPUT -d i26 -p tcp --dport 2013 -j DROP
iptables -A OUTPUT -p tcp --dport 2013 -j ACCEPT

# Negar l'accés a qualsevol port 2013, excepte al del host i26 (DROP)
iptables -A OUTPUT -d i26 -p tcp --dport 3013 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 3013 -j DROP

# Permetre accés a qualsevol port 4013 extern i al del host i26
# Denegar l'accés a qualsevol port 4013 dels hosts de la xarxa hisx2 (192.168.2.0/24) (DROP)
iptables -A OUTPUT -d i26 -p tcp --dport 4013 -j ACCEPT
iptables -A OUTPUT -d 192.168.2.0/24 -p tcp --dport 4013 -j DROP
iptables -A OUTPUT -p tcp --dport 4013 -j ACCEPT

# Denegar l’accés a qualsevol port 80, 13, 7 (REJECT)
iptables -A OUTPUT -p tcp --dport 80 -j REJECT
iptables -A OUTPUT -p tcp --dport 13 -j REJECT
iptables -A OUTPUT -p tcp --dport 7 -j REJECT

# Denegar l'accés als hosts i26 i i27 (DROP)
iptables -A OUTPUT -d i26 -j DROP
iptables -A OUTPUT -d i27 -j DROP

# Denegar l'accés a les xarxes hisx1 (192.168.1.0/24) i hisx2 (192.168.2.0/24) (DROP)
iptables -A OUTPUT -d 192.168.1.0/24 -j DROP
iptables -A OUTPUT -d 192.168.2.0/24 -j DROP

# Denegar l'accés a la xarxa hisx2 a no ser que sigui per SSH (DROP)
iptables -A OUTPUT -d 192.168.2.0/24 -p tcp --dport 22 -j DROP

# Mostrem
iptables -L
