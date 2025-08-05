#ifndef LOGIN_ENGINE
#define LOGIN_ENGINE

#include <QObject>
#include <QSqlQuery>
#include "core/database.h"

class LoginEngine : public QObject {
    Q_OBJECT

public slots:
    void checkAccess(QString username, QString password);

signals:
    void connected(int id, QString titre, QString prenom, QString nom, int niveau);
    void errorOccured(QString message);
};

#endif
