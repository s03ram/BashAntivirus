#!/bin/bash

############################
#Auteurs : 			724lsms; 728mory; 731etss
#Date : 			15 Septembre 2023
#Nom du fichier : 	antivirus.sh   
#Usage : 			./antivirus.sh [file or directory]
#Description : 		Ce script Shell a pour but de tester un diagnostic d'un fichier donné en argument
#					afin de vérifier qu'il n'est pas menaçant pour la machine, à la manière d'un antivirus.
# Fonctionnement : 	Si l'argument est un dossier, on propose de scanner récursivement. 
#					Scanner : comparer l'empreinte (sha256) des fichiers avec celles présentes dans la bdd
# Dépendance :		GnuPG
############################


##########################################################################################################################
#################################################### CONSTANTES ##########################################################

FICHIER=$(realpath "$1")
VIRUS_BDD=./empreintes.txt


##########################################################################################################################
##################################################### FONCTIONS ##########################################################

############# Options ############

aide(){
   # Affiche l'aide
   echo "Scanne un fichier ou un répertiore de manière récursive ou non"
   echo ""
   echo "Usage: ./antivirus_2 [file|repository]"
   quitter
}


############# Utiles ############

fingerprint256(){
	# calculer l'empreinte sha256 sans le nom de fichier à la fin
    sha256sum $1 | cut -d " " -f 1
}


quitter(){
	read -n 1 _
	clear
	exit 0
}


########### Chiffrement/Déchiffrement ##########

dechiffre(){
	# dechiffre le fichier passé en argument
	gpg $1
	rm -i $1
	echo "Fichier déchiffré."
	quitter
}


########### Chiffrement/Déchiffrement ##########

bloqueur() {
    local chemin="$1"
	echo "$chemin suspect"
	echo "Retrait du droit d'execution..."
    chmod -x "$chemin"  
    
	echo "Chiffrer le fichier ? (Y/n)"
	read reponse
	case $reponse in
		 "N" | "n" | "NO" | "no" ) echo "Fichier clair" ;;
								*) chiffreFichier $chemin ;;
	esac
}


scanneFichier(){
	# si l'empreinte du fichier est dans la base de données, demander quoi faire
	# $1 : chemin du fichier à scanner
	clear
	compareEmpreinte $1
	est_present=$?

	if [[ $est_present -eq 1 ]] ; then
		bloqueur $1
	fi
}


compareEmpreinte(){
    # $1 = fingerprint to compare with the db of virusfp
    # return 1 for match, else 0
    
	empreinteFichier=$(fingerprint256 $1)

	#parcours toutes les empreintes de la bdd
	while read empreinteVirus ; do
		# si l'empreinte en cours correspond à celle à analyser
		empreinteVirusShort=$(echo $empreinteVirus | cut -d" " -f 1)
		[ $empreinteFichier == $empreinteVirusShort ] && return 1
	done < $VIRUS_BDD
	return 0
}


chiffreFichier(){
	# chiffre avec gpg le fichier passé en argument
	gpg -c $1
	FICHIER_CHIFFRE="$1".gpg
	echo "Fichier chiffré"
	rm -i $1
}


scanneRepertoire(){
	for fichier in $1/* ; do
		if [[ -f $fichier ]] ; then
			scanneFichier $fichier
		fi
	done
	echo "Rien (de plus) à déclarer"
}


scanneRepertoireRecursif(){
	for fichier in $1/* ; do
		if [[ -f $fichier ]] ; then
			scanneFichier $fichier
		elif [[ -d $fichier ]] ; then
			cheminRepertoire=$(realpath $fichier) && scanneRepertoireRecursif $cheminRepertoire
		fi
	done
	echo "Rien (de plus) à déclarer"
}


############# MENU ############

menuRepertoire(){
	# partie graphique
	logo
	choixRepertoireRecursif

	read choix

	case $choix in 
		1) scanneRepertoire $1;;
		2) scanneRepertoireRecursif $1;;
		*) quitter ;;
	esac
}


########## GRAPHIQUE ##########

logo(){
echo ""
echo ""
echo "	!!!!!!!!!!!!!!!!!!!"
echo "	!!!! ANTIVIRUS !!!!"
echo "	!!!!!!!!!!!!!!!!!!!"
echo ""
echo ""
}


choixRepertoireRecursif(){
	echo "
	Voulez-vous scanner :
	
	1) Ce répertoire seulement
	2) Récursivement
	*) Quitter
	"
}


##########################################################################################################################
####################################################### SCRIPT ###########################################################

clear


########### Assertions ###########

# ! BDD inexistante
[ ! -f VIRUS_BDD ] && echo "Abscence de la base de données d'empreintes de virus !" &&  quitter
# ! BDD vide
[ ! -s VIRUS_BDD ] && echo "La base de données d'empreintes de virus est vide !" && quitter


########### Conditions de base ###########

if [[ -d $FICHIER ]] ; then
	menuRepertoire $FICHIER
elif [[ -f $FICHIER ]] ; then
	[[ $FICHIER == "*.gpg" ]] ; dechiffre $FICHIER
	scanneFichier $FICHIER
else
	aide
fi


exit 0
