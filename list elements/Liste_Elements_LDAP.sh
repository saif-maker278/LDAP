#!/bin/bash
if ! command -v ldapadd &>/dev/null; then
	echo "Cette action n'est utilisée que sur un serveur LDAP"
	exit 1
fi

if [ $# -ne 3 ]; then
	echo "Usage: ./Liste_Elements_LDAP.sh <Login DN> <Mot de passe> <Type d'élément>"
	exit 1
fi

login=$1
mdp=$2
type=$3

# Option u pour utilisateur, g pour groupe et o pour unité d'organisation, ou n'importe quoi pour tout
if [[ $type == "u" || $type == "U" ]]; then
	ldapsearch -x -D "$login" -w "$mdp" "(objectclass=posixaccount)"
elif [[ $type == "g" || $type == "G" ]]; then
	ldapsearch -x -D "$login" -w "$mdp" "(objectclass=posixgroup)"
elif [[ $type == "o" || $type == "O" ]]; then
	ldapsearch -x -D "$login" -w "$mdp" "(objectclass=organizationalunit)"
else
	ldapsearch -x -D "$login" -w "$mdp"
fi




