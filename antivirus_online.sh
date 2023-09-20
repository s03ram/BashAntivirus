#!/bin/bash

############################
#Auteurs : 			724lsms; 728mory; 731etss
#Date : 			15 Septembre 2023
#Nom du fichier : 	antivirus.sh   
#Usage : 			./antivirus.sh [file or directory]
#Description : 		Ce script Shell a pour but de tester un diagnostic d'un fichier donné en argument
#					afin de vérifier qu'il n'est pas menaçant pour la machine, à la manière d'un antivirus.
# Fonctionnement : 	Envoie le sha256 à virus total pour qu'il teste dans sa propre base de donnée
# Dépendance :		Curl
# Limitation : 		4 fichiers/minute
############################


demandeExport(){
	# prompte l'utilisateur s'il veut tester ce fichier sur virus total
}


scanneFichier(){
	# vérifie si le fichier est suspect
	nomFichier=$(basename $1)

	[[ $nomFichier =~ "virus" ]] && demandeExport $1
	[[ $nomFichier =~ "malware" ]] && demandeExport $1
	[[ $nomFichier =~ "wicked" ]] && demandeExport $1
	[[ $nomFichier =~ "trojan" ]] && demandeExport $1
}


scanner(){
	for fichier in /* ; do
		if [[ -f $fichier ]] ; then
			scanneFichier $fichier
		elif [[ -d $fichier ]] ; then
			cheminRepertoire=$(realpath $fichier) && scanner $cheminRepertoire
		fi
	done
}



curl --request POST \
     --url https://www.virustotal.com/api/v3/files \
     --header 'accept: application/json' \
     --header 'content-type: multipart/form-data' \
     --header 'x-apikey: 834e98d9b93ca8524976042e632effd87f61eb4b6740573322510ddbd0548608' \
     --form file=@antivirus_2.sh