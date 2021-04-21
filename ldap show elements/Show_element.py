#!/usr/bin/python
import os
import sys
check = os.popen(r'command -v ldapsearch').read()
if check == "":
	print("This action is only used on a LDAP server ")
	exit(1)

if len(sys.argv) != 4:
	print("Usage: ./Afficher_Elements_LDAP.py <Login DN> <Password> <Starting point>")
	exit(1)

login = sys.argv[1]
mdp = sys.argv[2]
base = sys.argv[3]

#If Starting point doesn't exist then show all
if base == "":
	commande = r'ldapsearch -x -w {} -D {} -s "sub" dn|grep "^dn"|cut -d":" -f2'.format(mdp, login)
else:
	commande = r'ldapsearch -x -w {} -D {} -b {} -s "sub" dn|grep "^dn"|cut -d":" -f2'.format(mdp, login, base)

stdout = os.popen(commande)
output = stdout.read()
liste_dn = output.split('\n')

# Element exemple: "cn=Titi,ou=Toto,dc=security,dc=tn"
# Reverse them to get "dc=tn,dc=security,ou=Toto,cn=Titi"
liste_dn_inversee = []
for dn in liste_dn:
	liste_dn_inversee.append(','.join(dn.split(',')[::-1]))
liste_dn_inversee.sort()

print(liste_dn_inversee[1])
for i in range(2, len(liste_dn_inversee)):
	ident = len(liste_dn_inversee[i].split(','))
	print("     "*ident + "-  " + liste_dn_inversee[i].split(',')[0])
