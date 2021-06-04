#!/bin/bash
if ! command -v ldapmodify &>/dev/null; then
	echo "Cette action n'est utilisée que sur un serveur LDAP"
	exit 1
fi

if [ $# -ne 4 ]; then
	echo "Usage: ./Ajouter_Utilisateur_A_Un_Groupe.sh <Login DN> <Mot de passe> <ID utilisateur à ajouter> <DN complet du groupe ou unité>"
	exit 1
fi

login=$1
mdp=$2
id_utilisateur=$3
groupe=$4

# Il faut que l'ID utilisateur existe
ldapsearch -x -w "$mdp" -D "$login" "(objectclass=posixaccount)" uid|grep -e '^uid'|cut -d':' -f2|grep -Fwq "$id_utilisateur"
if [[ $? -eq "1" ]]; then
	echo "ID utilisateur $id_utilisateur n'existe pas. Veuillez réessayer."
	exit 1
fi

# On crée un fichier ldif pour la modification
(cat <<FILE
dn: $groupe
changetype: modify
add: memberuid
memberuid: $id_utilisateur
FILE
) > /tmp/groupe.ldif

# Puis l'utiliser pour modifier LDAP
ldapmodify -x -D "$login" -w "$mdp" -f /tmp/groupe.ldif

rm /tmp/groupe.ldif

