#!/bin/bash

# Adresse IP de la machine Windows
windows_ip="10.10.1.30"
# Port sur lequel se connecter
port=12345

# Fonction pour gérer la connexion
function handle_connection {
    # Connexion au serveur Windows
    exec 3<>/dev/tcp/$windows_ip/$port
    while true; do
        # Lire le message du serveur
        read -r response <&3
        if [ -z "$response" ]; then
            break
        fi
        echo "Message du serveur : $response"
        # Envoyer une réponse au serveur
        read -p "Entrez votre message (ou 'exit' pour quitter) : " message
        if [ "$message" == "exit" ]; then
            echo "$message" >&3
            break
        fi
        echo "$message" >&3
    done
    echo "Déconnecté du serveur"
    exit
}

# Se connecter au serveur Windows en boucle
while true; do
    echo "Tentative de connexion au serveur Windows sur le port $port..."
    handle_connection
    sleep 1
done