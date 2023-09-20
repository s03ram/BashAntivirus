#!/bin/bash

############################
#Auteurs : 			724lsms; 728mory; 731etss
#Date : 			15 Septembre 2023
#Nom du fichier : 	antivirus.sh   
#Usage : 			./antivirus.sh [file or directory]
#Description : 		Ce script Shell a pour but de tester un diagnostic d'un fichier donné en argument
#					afin de vérifier qu'il n'est pas menaçant pour la machine, à la manière d'un antivirus.
# Fonctionnement : 	Si l'argument est un dossier, on propose de scanner récursivement. 
#					Scanner : comparer l'empreinte (sha256) des fichiers avec ceux présents dans la bdd
############################


FILE=$1


##########################################################################################################################
##################################################### FONCTIONS ##########################################################

bloqueur() {
    local chemin="$1"
    chmod -x "$chemin"  
    echo "Droits d'exécution retirés du fichier : $chemin"
    while true; do

        # Demande à l'utilisateur s'il souhaite créer un fichier ZIP chiffré avec un mot de passe.
        echo "Souhaitez-vous créer un zip chiffré avec votre mot de passe ? (y/n)"
        read rep

        # Vérifie la réponse de l'utilisateur.
        if [ "$rep" = "y" ] || [ "$rep" = "Y" ] || [ "$rep" = "yes" ] || [ "$rep" = "YES" ]; then

            # Demande à l'utilisateur de saisir un mot de passe (en masquant la saisie).
            read -s -p "Entrez le mot de passe pour chiffrer le fichier : " mot_de_passe

            # Crée un fichier ZIP chiffré en utilisant le mot de passe, en incluant le fichier spécifié.
            zip -j -e -P "$mot_de_passe" "${chemin}.zip" "$chemin"
            echo "Fichier chiffré avec succès : ${chemin}.zip"

            # Supprime le fichier "original"
            rm -f $chemin 
            break  

        # Si l'utilisateur répond "n" ou "N", la fonction affiche un message et ne fait rien d'autre.
        elif [ "$rep" = "n" ] || [ "$rep" = "N" ]|| [ "$rep" = "no" ] || [ "$rep" = "NO" ] || [ "$rep" = "non" ] || [ "$rep" = "NON" ]; then 
            echo "D'accord, nous laissons le fichier en clair, mais les droits d'exécution ont été enlevés."
            break 

        else

            clear
            echo "Réponse invalide, veuillez répondre par 'y' ou 'n'."
            echo "Droits d'exécution retirés du fichier : $chemin"

        fi
    done
}


fingerprint256(){
    sha256sum $1
}

compare_fprint(){
    # $1 = fingerprint to compare with the db of virus
    # return 1 for match, else 0
    fprint=$1
    for line in $2 ; do
        if [[ $fprint -eq $line ]] ; then
            return 1
        fi
    done
    return 0
}

file_analysis(){
    # calcule empreinte du fichier
    fprint=$(fingerprint256 $1)
    # regarde s'il y a un match
    match=$(compare_fprint $fprint $VIRUSES)
    # si le fichier est suspect, renvoyer le chemin et nom du fichier
    [ $match -eq 1 ] && readlink -f $item
}


search_files(){
    #fonction de recherche 
    for item in $1 ; do
        if [[ -f $item]] ; then
            echo $(file_analysis $item)
        fi
    done
}


############# MENU ############




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




##########################################################################################################################
####################################################### SCRIPT ###########################################################


## CHOIX DU MODE ##
clear 

logo

echo "Veuillez selectionné votre mode :"
echo ""
echo "Mode 1 -> Donnez un repertoire et il y aura de la récursivité"
echo ""
echo "Mode 2 -> Donnez un répertoire sans récursivivté"
echo ""
echo "Mode 3 -> Donnez un fichier"
echo ""
echo ""
echo "Choix 1 , 2 , 3 ->"
read choix 
clear 


VIRUSES="6d916ad955d244e2140c1a236f26412c290000e951d134d07cc48b3712f46865"

## MODE 1 ##
if [ $choix -eq 1 ]; then 
    echo "Entrez le chemin complet du répertoire à analyser :"
    chmod -R +r repertoire_a_tester
    if [ ! -d "$repertoire_a_tester" ]; then
        echo "Le répertoire '$repertoire_a_tester' n'existe pas ou vous avez mal écrit son chemin."
        exit 1
    fi

    # On s'ajoute les droit de lire le fichier pour calculer son empreinte
    echo "$repertoire_a_tester"

    search_files "$repertoire_a_tester"
fi

## MODE 2 ##
if [ $choix -eq 2 ]; then
    echo "Entrez le chemin complet du répertoire à analyser sans récursivité :"
    read repertoire_a_tester
    if [ ! -d "$repertoire_a_tester" ]; then
        echo "Le répertoire '$repertoire_a_tester' n'existe pas ou vous avez mal écrit son chemin."
        exit 1
    fi

    # On s'ajoute les droit de lire le fichier pour calculer son empreinte
    chmod +r "$repertoire_a_tester"

    search_files "$repertoire_a_tester"
fi

## MODE 3 ##
if [ "$choix" -eq 3 ]; then
    while true ; do
        echo "Entrez le chemin complet du fichier :"
        read fichier_a_tester
        
        if [ ! -f "$fichier_a_tester" ]; then
            echo ""
            echo "Le fichier $fichier_a_tester n'existe pas ou vous avez mal écrit son chemin."
            echo ""
        else
            # On s'ajoute les droit de lire le fichier pour calculer son empreinte
            chmod +r "$fichier_a_tester"
            sha256sum "$fichier_a_tester"
            break  # Sort de la boucle lorsque le fichier est correct
        fi
        sleep 2
    done
fi

bloqueur "$chemin"