#!/bin/bash
if ! command -v ldapadd &>/dev/null; then
	echo "Cette action n'est utilisée que sur un serveur LDAP"
	exit 1
fi

if [ $# -ne 4 ]; then
	echo "Usage: ./Ajouter_Unite_Organisation_LDAP.sh <Login DN> <Mot de passe> <Nom de l'unité> <Groupe père/Unité mère>"
	exit 1
fi

login=$1
mdp=$2
unite=$3
pere=$4

# On crée un fichier ldif pour l'unité
(cat <<FILE
dn: ou=$unite,$pere
objectClass: top
objectClass: organizationalUnit
ou: $unite
FILE
) > /tmp/groupe.ldif

# Puis l'ajoute à LDAP
ldapadd -x -D "$login" -w "$mdp" -f /tmp/groupe.ldif

rm /tmp/groupe.ldif
