#!/bin/bash
if ! command -v ldapsearch &>/dev/null; then
	echo "Cette action n'est utilisée que sur un serveur LDAP"
	exit 1
fi

if [ $# -ne 4 ]; then
	echo "Usage: ./Rechercher_Element_LDAP.sh <Login DN> <Mot de passe> <DN complet de l'élément> <Option>"
	exit 1
fi

login=$1
mdp=$2
element=$3
option=$4

if [[ $option -eq "sub" ]]; then
	ldapsearch -x -D "$login" -w "$mdp" -b "$element" -s "sub"
else
	ldapsearch -x -D "$login" -w "$mdp" -b "$element" -s "base"
fi
