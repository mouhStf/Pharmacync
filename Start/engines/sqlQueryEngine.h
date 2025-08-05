#ifndef SQL_QUERY_ENGINE
#define SQL_QUERY_ENGINE

#include <QObject>
#include <QSqlQuery>
#include <QDateTime>
#include "core/database.h"

class SqlQueryEngine : public QObject {
  Q_OBJECT

public:
  SqlQueryEngine(QObject *parent = nullptr);

public slots:
  QList<QVariantList> queryExec(const QString &query);
  QList<QVariantList> select(const QString &tableName, const QStringList &columns);
  QList<QVariantList> select(const QString &tableName, const QStringList &columns, const QVariant &idCol, const QVariant &idVal, const QString& sup = "");
  bool insert(const QString &tableName, const QStringList &columns, const QVariantList &values);
  bool update(const QString &tableName, const QStringList &columns, const QVariantList &values, const QString &idcol, const QVariant &idval);
  bool deleteRow(const QString &tableName, const QString &idcol, const QVariant &idval);
  QString timeFromSec(qint64 sec);
  QString dateFromSec(qint64 sec);

  bool updateStockIndex(const QString& cip13);
  bool updateEntresStockIndex(int id);

  QString ajouterStock(const QString& cip13, int idFournisseur, int quantite, int achat, int vente, const QString &peremption);

  bool isDateValid(const QString &date);
  bool isTimeValid(const QString &time);

  int getUserId() { return userId; }
  void setUserId(int id);
  bool vendre(QVariantMap produits ,int valeur, int donne, int rendu);
  //bool setVente(int idFacture, QVariantMap produits, int valeur, int donne, int rendu, QString date = "", QString time = "");
  bool editFacture(int idFacture, QVariantMap produits, int valeur, int donne, int rendu, bool err);

  bool doRetour(int idFlux, int quantite, bool err);
  qint64 dateTimeToSecSinceEpoch(const QString &dateTime);

private:
  bool enregistrerVente(int idFacture, const QString& cip13, int quantite);

  bool insertFlux(int idFacture, const QString& cip13, int quantite);
  bool insertRetour(int idFlux, int quantite, int newValue, bool err);
  bool removeFromStock(const QString& cip13, int qt);
  
  int userId;
};

#endif
