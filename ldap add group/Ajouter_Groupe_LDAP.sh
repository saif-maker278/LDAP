#!/bin/bash
if ! command -v ldapadd &>/dev/null; then
	echo "Cette action n'est utilisée que sur un serveur LDAP"
	exit 1
fi

if [ $# -ne 5 ]; then
	echo "Usage: ./Ajouter_Groupe_LDAP <Login DN> <Mot de passe> <Nom du nouveau groupe> <Groupe père/Unité mère> <gid>"
	exit 1
fi

login=$1
mdp=$2
groupe=$3
pere=$4
gid=$5

# Si le gid n'est pas donné, on lui attribue la valeur prochaine disponible 
if [[ -z $gid ]];
then
	dernier_gid=$(ldapsearch -x -w "$mdp" -D "$login" "(objectclass=posixgroup)" gidnumber|grep -e '^gid'|cut -d':' -f2|sort|tail -1)
	if [[ -z $dernier_gid ]];
	then
		gid="500"
	else
		let gid=dernier_gid+1
	fi
fi

# On crée un fichier ldif pour le groupe
(cat <<FILE
dn: cn=$groupe,$pere
objectClass: top
objectClass: posixGroup
gidNumber: $gid
FILE
) > /tmp/groupe.ldif

# Puis l'ajouter à LDAP
ldapadd -x -D "$login" -w "$mdp" -f /tmp/groupe.ldif

rm /tmp/groupe.ldif

