#!/bin/bash

if ! command -v ldapadd &>/dev/null; then
	echo "Cette action n'est utilisée que sur un serveur LDAP"
	exit 1
fi

if [ $# -ne 12 ]; then
	echo "Usage: ./Ajouter_Utilisateur_LDAP.sh <Login DN> <Mot de passe> <Groupe père/Unité mère> <Nom commun> <Prenom> <Numero GID> <Repertoire personnel> <Nom de famille> <Login shell> <Mot de passe> <Numero UID> <ID utilisateur>"
	exit 1
fi

login=$1
mdp=$2
groupe=$3
nc=$4
pn=$5
gid=$6
reper_perso=$7
nf=$8
login_shell=$9
mdp_utilisateur=${10}
uid=${11}
id_utilisateur=${12}

if [[ $login_shell -ne "/bin/bash" && $login_shell -ne "/bin/sh" && $login_shell -ne "/bin/zsh" && $login_shell -ne "/bin/dash" ]]; then
	echo "Invalide shell. Choisissez entre /bin/bash, /bin/sh, /bin/zsh et /bin/dash"
	exit 1
fi

# Si l'uid n'est pas donné, on lui met une valeur qui est la prochaine de celles deja existantes
if [[ -z $uid ]]
then
	dernier_uid=$(ldapsearch -x -w "$mdp" -D "$login" "(objectclass=posixaccount)" uidnumber|grep -e '^uid'|cut -d':' -f2|sort|tail -1)
	if [[ -z $dernier_uid ]];
	then
		uid="1000"
	else
		let uid=dernier_uid+1
	fi
fi

# Il ne faut pas que l'ID utilisateur existe déjâ
ldapsearch -x -w "$mdp" -D "$login" "(objectclass=posixaccount)" uid|grep -e '^uid'|cut -d':' -f2|grep -Fwq "$id_utilisateur"
if [[ $? -eq "0" ]]; then
	echo "ID utilisateur $id_utilisateur existe deja. Veuillez choisir un autre."
	exit 1
fi

# On crée un fichier ldif pour cet utilisateur
# Le mot de passe dans ce ldif est temporaire
# Il sera changé juste après
dn="cn=$nc,$groupe"
(cat <<FILE
dn: $dn
objectClass: top
objectClass: inetOrgPerson
objectClass: posixAccount
cn: $nc
givenName: $pn
gidNumber: $gid
homeDirectory: $reper_perso
loginShell: $login_shell
sn: $nf
userPassword: !sUp3r_s3cUr1s3_p4sSw0rD!
uidNumber: $uid
uid: $id_utilisateur
FILE
) > /tmp/utilisateur.ldif

# Ajout du nouvel utilisateur
ldapadd -x -D "$login" -w "$mdp" -f /tmp/utilisateur.ldif
ldappasswd -s "$mdp_utilisateur" -D "$login" -w "$mdp" -x "$dn"

rm /tmp/utilisateur.ldif
