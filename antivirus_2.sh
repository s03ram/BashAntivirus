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
USAGE="usage : ./antivirus.sh [file or directory]"

##########################################################################################################################
##################################################### FONCTIONS ##########################################################

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


fingerprint256(){
    sha256sum $1 | cut -d " " -f 1
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
	done < empreintes.txt
	return 0
}


chiffreFichier(){
	# chiffre avec gpg le fichier passé en argument
	gpg -c $1
	FICHIER_CHIFFRE="$1".gpg
	echo "Fichier chiffré"
	sudo rm -i $1
}


scanneRepertoire(){
	for fichier in $1/* ; do
		if [[ -f $fichier ]] ; then
			scanneFichier $fichier
		fi
	done
}


scanneRepertoireRecursif(){
	for fichier in $1/* ; do
		if [[ -f $fichier ]] ; then
			scanneFichier $fichier
		elif [[ -d $fichier ]] ; then
			cheminRepertoire=$(realpath $fichier) && scanneRepertoireRecursif $cheminRepertoire
		fi
	done
}


############# MENU ############

menuRepertoire(){
	# partie graphique
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
echo "!!!!!!!!!!!!!!!!!!"
echo "!!!! ANTIVRUS !!!!"
echo "!!!!!!!!!!!!!!!!!!"
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


## CHOIX DU MODE ##
clear 

logo

if [[ -d $FICHIER ]] ; then
	menuRepertoire $FICHIER
elif [[ -f $FICHIER ]] ; then
	scanneFichier $FICHIER
else
	echo $USAGE
fi


exit 0