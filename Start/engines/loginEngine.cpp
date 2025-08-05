#include "loginEngine.h"

void LoginEngine::checkAccess(QString username, QString password) {
    QSqlQuery query = Database::select("utilisateur", {"pass", "id", "titre", "prenom", "nom", "niveau", "actif"}, "pseudo", username);

    if (query.next()) {
        if (query.value(0).toString() == password) {
            int id = query.value(1).toInt();
            QString titre = query.value(2).toString(); // titre
            QString prenom = query.value(3).toString();
            QString nom = query.value(4).toString();
            int niveau = query.value(5).toInt();
            int actif = query.value(6).toInt();

            if (actif != 0)
                emit connected(id, titre, prenom, nom, niveau);
            else
                emit errorOccured("Utilisateur inactif.");
        }
        else
            emit errorOccured("Mot de passe incorecte.");
    }
    else
        emit errorOccured("Utilisateur inconnu.");

}
