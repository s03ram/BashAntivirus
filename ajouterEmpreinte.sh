#!/bin/bash

# ce script est destiné au test de l'antivirus
# il ajoute l'empreinte du fichier passé en argument dans la bdd de virus
# pour simuler un fichier malveillant

sha256sum $1 >> empreintes.txt