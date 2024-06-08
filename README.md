# VMQuickCreate

## Description
VMQuickCreate est un projet visant à simplifier la création de machines virtuelles sous Windows en utilisant un script shell exécuté sous Windows Subsystem for Linux (WSL) et un script PowerShell. Ce projet établit une communication entre un script shell (client) et un script PowerShell (serveur) pour gérer la création de machines virtuelles via Hyper-V. 

Bien que l'idée de créer des machines virtuelles à l'aide de scripts soit simple, elle est puissante et très intéressante pour les grandes entreprises et autres organisations ayant besoin de gérer de nombreuses machines virtuelles de manière efficace.

## Fonctionnalités
- **Automatisation de la création de VM** : Simplifie la configuration et le déploiement de machines virtuelles en utilisant des commandes en ligne.
- **Vérification des ressources** : Avant la création, le script vérifie la disponibilité et la compatibilité des ressources demandées.

## Prérequis
- **Windows 10/11 avec WSL installé**
- **Hyper-V activé**
- **PowerShell 5.1 ou version ultérieure**
- **Bash (via WSL)**

## Installation

1. **Activer WSL** (si ce n'est pas déjà fait) :
   ```powershell
   wsl --install
