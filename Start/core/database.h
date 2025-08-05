#ifndef DATABASE_H
#define DATABASE_H

#include <QObject>
#include <QDebug>
#include <QtSql>

class Database {
public:
  static void initDatabase();
  
  static void error(QString source, QString message) {
    qWarning() << "ERROR " << source << message;
  }
  
  static QString lastError() { return query->lastError().text(); }

  static QSqlQuery *getQuery() { return query; }

  static QSqlQuery select(const QString &tableName,
                           const QStringList &columns = {"*"},
                           const QStringList &wheres = {},
                           const QList<QVariant> &wheresVals = {}, const QString &supp = "");
  static QSqlQuery select(const QString &tableName,
                           const QStringList &columns,
                           const QString &where,
                           const QVariant &whereVal) {
    return select(tableName, columns, QList({where}),QList({whereVal}));
  }

  static bool qrInsert(const QString &tableName, const QStringList &cols,
                       const QList<QVariant> &vals);

  static bool qrUpdate(const QString &tableName, const QStringList &cols,
                       const QList<QVariant> &vals, const QString &where,
                       const QVariant &whereVal) {
    return qrUpdate(tableName, cols, vals , QList({where}), QList({whereVal}));
  }
  static bool qrUpdate(const QString &tableName, const QString &col,
                       const QVariant &val, const QString &where,
                       const QVariant &whereVal) {
    return qrUpdate(tableName, QList({col}), QList({val}) , where, whereVal);
  }

  static bool qrUpdate(const QString &tableName, const QStringList &cols,
                       const QList<QVariant> &vals,
                       const QStringList &wheres,
                       const QList<QVariant> &wheresVals);

  // This definitions are temporary  should be changed
  static QSqlDatabase* database() {return db;}

private:
  static QSqlQuery *query;
  static QSqlDatabase *db;

  static QHash<QString, QStringList> tables;
  static QHash<QString, QStringList> tablesRestant;
};

#endif
