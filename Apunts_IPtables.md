# Teoria
Les regles s’avaluen una a una seqüencialment de la primera cap avall. Si una regla fa
match ​ (coincideix) es deixa d’examinar les regles, s’aplica i surt.

Les regles “​ noves ​ “ es poden afegir a:
Al final de les regles ja existents usant -A de append
A l’inici de les regles ja existents usant -I de insert​

```bash
# Regles Flush: buidar les regles actuals
iptables -F
iptables -X
iptables -Z
iptables -t nat -F

# Establir la política per defecte (ACCEPT o DROP)
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT


# Permetre totes les pròpies connexions via localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Permetre tot el trafic de la pròpia ip(192.168.1.34))
iptables -A INPUT -s 192.168.1.34 -j ACCEPT
iptables -A OUTPUT -d 192.168.1.34 -j ACCEPT

# Mostrar les regles generades
iptables -L -t nat

# Permetre al 231.45.134.23 accedir al postgres (port 5432)
iptables -A INPUT -s 231.45.134.23 -p tcp --dport 5432 -j ACCEPT

# Permetre accedir al FTP (ports 20,21) al host 80.37.45.194
iptables -A INPUT -s 80.37.45.194 -p tcp -dport 20:21 -j ACCEPT

# Permetre l'accés al servidor web (port 80) de la xarxa 80.37.0.0/16
iptables -A INPUT -s 80.37.0.0/16 -p tcp --dport 80 -j ACCEPT

# Tancar aquests serveis a la resta de hosts
iptables -A INPUT -p tcp --dport 20:21 -j DROP
iptables -A INPUT -p tcp --dport 5432 -j DROP
iptables -A INPUT -p tcp --dport 80 -j DROP

# Tancar l’accés extern al servei ssh i daytime del host
iptables -A INPUT -p tcp --dport 22 -j DROP
iptables -A INPUT -p tcp --dport 13 -j DROP

#Desar les regles que s’estan aplicant actualment al kernel a un fitxer (tipus script) que podrà ser carregat a iptables quan es consideri oportú:
iptables-save

# Carregar de nou una configuració iptables basada en una configuració anterior generada per iptables-save:
iptables-restore

# Generar una configuració pròpia, personalitzada del firewall. Escriure un fitxer script (o varis per a cada situació) que estableixin les regles iptables apropiades a cada cas.
iptables-regles01.sh
```

# Scripts

Es poden establir dues polítiques per defecte ACCEPT i DROP. Generalment en l’inici dels
scripts s’estableix quina és la política per defecte que seguirà aquell script, tot permès per
defecte o tot prohibit per defecte.

ACCEPT​ : Tot està permès per defecte excepte allò que explícitament es denegui. En aquest cas les regles del firewall són el llistat de tot allò que explícitament es prohibeix i la resta està tot permès.

```bash
# Establir la política per defecte ACCEPT
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT
```

DROP​ : Tot està prohibit excepte allò que explícitament es permet. En aquest cas l’script del
firewall és el conjunt de regles que permeten tràfic, el que no hi sigui contemplat està
prohibit per defecte.

Generar firewalls amb política per defecte drop és molt més difícil perquè cal assegurar-se
de que no es tanca res que és imprescindible que estigui obert. Però també és més segur,
perquè tot el que no és imprescindible està tancat.

```bash
# Establir la política per defecte DROP
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
iptables -t nat -P PREROUTING DROP
iptables -t nat -P POSTROUTING DROP
```

Sovint es desitja permetre tot tipus de tràfic a una determinada adreça IP local o a un device
local, per exemple al loopback o a la propia adreça IP (una, alguna o tetes elles) per
exemple de eth0.

Per dir a la meva interfície tal del host/firewall li permeto tot el tràfic d’entrada i sortida
s’escriu:

```bash
# Permetre totes les pròpies connexions via localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Permetre tot el trafic de la pròpia adreça ip (192.168.1.34)
iptables -A INPUT -s 192.168.1.34 -j ACCEPT
iptables -A OUTPUT -d 192.168.1.34 -j ACCEPT
```

Política ACCEPT: regles per ’​ tancar​ ‘ serveis

En una configuració iptables amb política per defecte ACCEPT tot està permès i el que cal és afegir regles per tancar el tràfic que no es permet.

El cas més fàcil de provar és en el propi host aplicar una política per defecte ACCEPT i considerar aquests casos:

+ INPUT: tancar serveis que ofereix el propi host/firewall.
+ OUTPUT: tancar serveis externs, és a dir, no permetre que el propi host/firewall es connecti a determinats serveis externs.
+ FORWARD: tancar l’accés a serveis que creuen el firewall.

# Cas 1


.
.
.













.
