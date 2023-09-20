#!/bin/bash


fingerprint256(){
    sha256sum $1 | cut -d " " -f 1
}

compare_empreinte(){
    # $1 = fingerprint to compare with the db of virus
    # return 1 for match, else 0
    
	empreinteFichier=$(fingerprint256 $1)

	#parcours toutes les empreintes de la bdd
	while read empreinteVirus ; do
		# si l'empreinte en cours correspond à celle à analyser
		[ $empreinteFichier == $empreinteVirus ] && return 1 
	done < empreintes.txt
	return 0
}

compare_empreinte ./antivirus.sh

echo $?