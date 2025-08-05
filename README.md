# PharmaCync

PharmaCync est une application de bureau pour la gestion de pharmacie, conçue pour simplifier le suivi des stocks, le traitement des ventes, la facturation et la gestion des utilisateurs. L'interface est développée avec QML/Qt et le backend en C++.

## ✨ Fonctionnalités Clés

*   **Authentification :** Système de connexion sécurisé pour les utilisateurs.
*   **Gestion des Stocks :** Suivi des niveaux de stock pour les médicaments et autres produits, avec des options pour ajouter facilement de nouvelles entrées.
*   **Traitement des Ventes :** Interface dédiée pour la création et la gestion des ventes.
*   **Facturation :** Génération et consultation des factures.
*   **Contrôle d'Inventaire :** Outils pour réaliser et gérer les inventaires.
*   **Dictionnaire des Produits :** Maintenir une liste complète des médicaments et autres produits.
*   **Statistiques :** Visualisation des données de ventes et d'inventaire.

## 🛠️ Technologies Utilisées

*   **Backend :** C++
*   **Frontend :** QML (Qt Quick)
*   **Framework :** Qt 6
*   **Base de données :** SQLite
*   **Système de build :** CMake

## 🚀 Démarrage Rapide

### Prérequis

*   Un compilateur C++ (GCC, Clang, MSVC)
*   CMake (version 3.5 ou supérieure)
*   Qt (version 6.x ou supérieure)

### Compiler le Projet

1.  **Clonez le dépôt :**
    ```bash
    git clone https://github.com/mouhStf/Pharmacync.git
    cd Pharmacync/Start
    ```

2.  **Créez un répertoire de build :**
    ```bash
    mkdir build && cd build
    ```

3.  **Exécutez CMake et compilez :**
    ```bash
    cmake ..
    make
    ```
    *(Note : La commande peut varier selon votre système, par exemple `mingw32-make` sur Windows avec MinGW)*

4.  **Lancez l'application :**
    L'exécutable se trouvera dans le répertoire `build`.
    ```bash
    ./pharmacync_start
    ```

## 🗃️ Base de Données

L'application utilise une base de données SQLite (`DataPrimeYo.db`) pour stocker toutes les informations. Le schéma de la base de données est défini dans `dataStructure.sql`.

Un script Python (`python_script/data_simulation.py`) est disponible pour peupler la base de données avec des données de test.

## 📂 Structure du Projet

```
Pharmacync/
└── Start/
    ├── core/         # Logique backend (base de données, modèles)
    ├── engines/      # Moteurs pour la logique métier et l'interaction UI
    ├── Qml/          # Fichiers QML pour l'interface utilisateur
    ├── python_script/ # Scripts pour la simulation de données
    ├── main.cpp      # Point d'entrée principal de l'application
    └── CMakeLists.txt # Configuration de la compilation
```

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une *issue* pour signaler un bug ou proposer une fonctionnalité, ou à soumettre une *pull request*.

## 📄 Licence

Ce projet est sous licence [GNU GPLv3](LICENSE).
