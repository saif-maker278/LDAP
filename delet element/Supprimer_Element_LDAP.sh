#!/bin/bash
if ! command -v ldapdelete &>/dev/null; then
	echo "Cette action n'est utilisée que sur un serveur LDAP"
	exit 1
fi

if [ $# -ne 3 ]; then
	echo "Usage: ./Supprimer_Element_LDAP.sh <Login DN> <Mot de passe> <DN de l'élément à supprimer>"
	exit 1
fi

login=$1
mdp=$2
element=$3

ldapdelete -x -D "$login" -w "$mdp" "$element" -r

