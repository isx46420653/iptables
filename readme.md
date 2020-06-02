# MP11UF3-NF1 A05 Tallafocs

Taula del model de iptables. Chains: input, output, forward.

ip-default.sh:

+ fer flush de totes les regles.
+ definir política per defecte accept.
+ obrir al lo i la pròpia ip les connexions locals.
+ llistar les regles

[ip-default.sh](exercicis/ip-default.sh)

ip-01-input.sh: regles bàsiques de input

+ en el host local s’han obert els ports 80 i redirigit a ell els 2080, 3080, 4080, 5080. Tots amb xinetd.
+ port 80 obert a tothom
+ port 2080 tancat a tothom (reject)
+ port 2080 tancat a tothom (drop)
+ port 3080 tancat a tothom però obert al i26
+ port 4080 obert a tohom però tancat a i26
+ port 5080 tancat a tothom, obert a hisx2 (192.168.2.0/24) i tancat a i26.
+ pendent: obert tothom, tancat a hisx2 i obert a i26.

[ip-01-input.sh](exercicis/ip-01-input.sh)

ip-02-output.sh: regles bàsiques de output

+ S'ha engegat el host i26 i i27 (els alumnes només un segon host) on s’hi han engegat els serveis https i xinetd (amb tota la pesca!).
+ accedir a qualsevol host/port extern
+ accedir a qualsevol port extern 13.
+ accedir a qualsevol port 2013 excepte el del i26.
+ denegar l’accés a qualsevol port 3013, però permetent accedir al 3013 de i26.
+ permetre accedir al port 4013 de tot arreu, excepte dels hosts de la xarxa hisx2, però si permetent accedir al port 4013 del host i26.
+ xapar l’accés a qualsevol port 80, 13, 7.
+ no permetre accedir als hosts i26 i i27.
+ no permetre accedir a les xarxes hisx1 i hisx2.
+ no permetre accedir a la xarxa hisx2 excepte per ssh.

[ip-02-output.sh](exercicis/ip-02-output.sh)

ip-03-established.sh: regles tràfic RELATED, ESTABLISHED

+ explicat el concepte de conversa: tràfic d’anada i de tornada.
+ tcp: establiment de la connexió de tres vies, tràfic d’una connexió o conversa.
+ wireshark per monitoritzar el tràfic. Usar follow tcp stream.
+ comcepte de  “navegar per internet” → accedir a qualsevol servidor web extern i permetre la ‘resposta’.
+ configurar que sigui un servei web que accepta peticions i només permet respostes relacionades.

[ip-03-established.sh](exercicis/ip-03-established.sh)

ip-04-icmp.sh:  ICPM (ping request(8) reply(0))

+ No permetre fer pings cap a l'exterior
+ No podem fer pings cap al i26
+ No permetem respondre als pings que ens facin
+ No permetem rebre respostes de ping

[ip-04-icmp.sh](exercicis/ip-04-icmp.sh)

ip-05-nat.sh:  NAT

+ Crear dues xarxes docker (netA i netB). Engegar dos hosts a cada xarxa (fer-los privileged per poder practicar el ping). Verificar que els hosts poden accedir al exterior i(i26 i 8.8.8.8) perquè docker posa les seves regles.
+ Esborra amb ip-default.sh les regles i observar que ara els containers docker NO tenen connectivitat a l’exterior, no es fa NAT.
+ Activar NAT per a les dues xarxes privades locals xarxaA i xarxaB. Verificar que tornen a tenir connectivitat a l’exterior.

[ip-05-nat.sh](exercicis/ip-05-nat.sh)

ip-06-forward.sh:  Forwarding

+ forwarding: Usant el model anterior de nat aplicar regles de tràfic de xarxaA a l’exterior i de xarxaA a xarxaB. Filtrar per pot i per destí.
+ xarxaA no pot accedir xarxab
+ xarxaA no pot accedir a B2.
+ host A1 no pot connectar host B1
+ xarxaA no pot accedir a port 13.
+ xarxaA no pot accedir a ports 2013 de la xarxaB
+ xarxaA permetre navegar per internet però res més a l'exterior
+ xarxaA accedir port 2013 de totes les xarxes d'internet excepte de la xarxa hisx2
+ # evitar que es falsifiqui la ip de origen: SPOOFING

[ip-06-input.sh](exercicis/ip-06-forward.sh)

ip-07-port-forward.sh:  IP/PORT forwarding

+ expliocat que és fer un prerouting que el que fem és DNAT, modificar la adreça i/o port destí.
+ SEMPRE despres del prerouting s’aplica el routing de manera que s’aplicaran les regles input o forward a continuació.
+ exemple de fer port forwarding dels ports 5001, 5002 i 5003 al port 13 de hostA1, hostA2 i el pròpi router. Observar que externament accedim al port 13 de cada host.
+ posar ara una regla forwarding reject del port 13 i veiem que l’accés dels ports 5001 i 5002 es rebutja, perquè després del port forwarding hi ha el routing que aplica forward.
+ treiem la regla forward i posem una regla input reject del port 13. ara és el port 5003 el que no funciona, perquè s’aplica input en ser el destí localhost.

[ip-07-port-forward.sh](exercicis/ip-07-port-forward.sh)

ip-08-DMZ.sh:  DMZ

+ Plantejat el model de DMZ, al readme hi ha les ordres per engegar els containers.
+ xarxaA: hostA1 i hostA2. xarxaB hostB1 i hostB2. xarxaDMZ host dmz1(nethost) dmz2(ldapserver), dmz3(kserver), dmz4(samba)
+ aplicar les regles que es descriuen al readme:
```
de la xarxaA només es pot accedir del router/fireall als serveis: ssh i daytime(13)
de la xarxaA només es pot accedir a l'exterior als serveis web, ssh i daytime(2013)
de la xarxaA només es pot accedir serveis que ofereix la DMZ al servei web
redirigir els ports perquè des de l'exterior es tingui accés a: 3001->hostA1:80, 3002->hostA2:2013, 3003->hostB1:2080,3004->hostB2:2007
S'habiliten els ports 4001 en endavant per accedir per ssh als ports ssh de: hostA1, hostA2, hostB1, hostB2.
S'habilita el port 4000 per accedir al port ssh del router/firewal si la ip origen és del host i26.
Els hosts de la xarxaB tenen accés a tot arreu excepte a la xarxaA.
```

[ip-08-DMZ.sh](exercicis/ip-08-DMZ.sh)

ip-09-DMZ2.sh:  DMZ amb servidors nethost, ldap, kerberos i samba

+ (1) des d'un host exterior accedir al servei ldap de la DMZ. Ports 389, 636.
+ (2) des d'un host exterior, engegar un container kclient i obtenir un tiket kerberos del servidor de la DMZ. Ports: 88, 543, 749.
+ (3) des d'un host exterior muntar un recurs samba del servidor de la DMZ.
+ Per engegar:
```
docker network create netA netB netZ

docker run --rm --name hostA1 -h hostA1 --net netA --privileged -d edtasixm11/net18:nethost

docker run --rm --name hostA2 -h hostA2 --net netA --privileged -d edtasixm11/net18:nethost

docker run --rm --name hostB1 -h hostB1 --net netB --privileged -d edtasixm11/net18:nethost

docker run --rm --name hostB2 -h hostB2 --net netB --privileged -d edtasixm11/net18:nethost

docker run --rm --name dmz1 -h dmz1 --net netDMZ --privileged -d edtasixm11/net18:nethost

docker run --rm --name dmz2 -h dmz2 --net netDMZ --privileged -d edtasixm06/ldapserver:18group

docker run --rm --name dmz3 -h dmz3 --net netDMZ --privileged -d edtasixm11/k18:kserver

docker run --rm --name dmz4 -h dmz4 --net netDMZ --privileged -d edtasixm06/samba:18detach

docker run --rm --name dmz5 -h dmz5 --net netDMZ --privileged -d edtasixm11/tls18:ldap
```
+ Per verificar:
```
ldapsearch -x -LLL  -h profen2i -b 'dc=edt,dc=org' dn

ldapsearch -x -LLL  -ZZ -h profen2i -b 'dc=edt,dc=org' dn

    #(falta configurar certificat CA en el client)

ldapsearch -x -LLL  -H  ldaps://profen2i -b 'dc=edt,dc=org' dn  

    #(falta configurar certificat CA en el client


docker run --rm -it edtasixm11/k18:khost

kinit anna


smbclient //profen2i/public
```

[ip-09-DMZ2.sh](exercicis/ip-09-DMZ2.sh)

ip-10-drop.sh:  DROP política drop per defecte

Implementar DROP per defecte a un host de l’aula i que funcioni normalment. Exemple fitxer https://drive.google.com/open?id=1vqjOJfLSt0McfJg7AuIRdqwR_6dbCR_X
A tenir en compte en el DROP:

+ dns 53
+ dhclient (68)
+ ssh (22)
+ rpc 111, 507
+ chronyd 123, 371
+ cups 631
+ xinetd 3411
+ postgresql 5432
+ x11forwarding 6010, 6011
+ avahi 368
+ alpes 462
+ tcpnethaspsrv 475
+ rxe 761
permetre servei local de: echo-stream, daytime-stream, telnet, pop3, imap, tftp
accedir als serveis externs de: echo-stream, ssh, tftp.

[ip-10-drop.sh](exercicis/ip-10-drop.sh)
