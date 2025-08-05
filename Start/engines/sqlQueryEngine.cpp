#include "sqlQueryEngine.h"
#include "core/database.h"

SqlQueryEngine::SqlQueryEngine(QObject *parent) : QObject{parent} {
  userId = -1;
}

void SqlQueryEngine::setUserId(int id) {
  userId = id;
}


QList<QVariantList> SqlQueryEngine::queryExec(const QString &query) {
  QList<QVariantList> result;

  QSqlQuery q;
  if (q.exec(query)) {
    int columnCount = q.record().count();
    while (q.next()) {
      QVariantList row;
      for (int i = 0; i < columnCount; ++i) {
        row.append(q.value(i));
      }
      result.append(row);
    }
  }

  return result;
}

QList<QVariantList> SqlQueryEngine::select(const QString &tableName, const QStringList &columns) {
  QSqlQuery query = Database::select(tableName, columns);
  QList<QVariantList> result;
  while (query.next()) {
    QVariantList rw;
    for (int i = 0; i < columns.count(); i++)
      rw.append(query.value(i));
    result.append(rw);
  }

  return result;
}
QList<QVariantList> SqlQueryEngine::select(const QString &tableName, const QStringList &columns, const QVariant &idCol, const QVariant &idVal, const QString& sup) {
  QSqlQuery query =
    Database::select(tableName, columns, {idCol.toString()}, {idVal}, {sup});

  QList<QVariantList> result;
  while (query.next()) {
    QVariantList rw;
    for (int i = 0; i < columns.count(); i++)
      rw.append(query.value(i));
    result.append(rw);
  }

  return result;
}

bool SqlQueryEngine::insert(const QString &tableName, const QStringList &columns, const QVariantList &values) {
  return Database::qrInsert(tableName, columns, values);
}
bool SqlQueryEngine::update(const QString &tableName, const QStringList &columns, const QVariantList &values, const QString &idCol, const QVariant &idVal) {
  return Database::qrUpdate(tableName, columns, values, idCol, idVal);
}

bool SqlQueryEngine::deleteRow(const QString &tableName, const QString &idcol, const QVariant &idval) {
  QSqlQuery query;
  query.prepare("DELETE FROM " + tableName + " WHERE " + idcol + " = ?");
  query.addBindValue(idval);
  return query.exec();
}

QString SqlQueryEngine::timeFromSec(qint64 sec) {
  return QDateTime::fromSecsSinceEpoch(sec).toString("HH:mm:ss");
}

QString SqlQueryEngine::dateFromSec(qint64 sec) {
  return QDateTime::fromSecsSinceEpoch(sec).toString("dd/MM/yyyy");
}

bool SqlQueryEngine::updateEntresStockIndex(int id) {
  QSqlQuery query = Database::select("entres_stock", {"quantite"}, "id", id);
  if (!query.next()) {
    qDebug() << "Error 40" << query.lastError().text();
    return false;
  }
  int quantite = query.value(0).toInt();

  int gone = 0;
  query = Database::select("flux", {"restant"}, "id_entres_stock", id);
  while (query.next())
    gone += query.value(0).toInt();

  if (gone > quantite) {
    qDebug() << "Error 41" << "Incongruence entres_stock flux";
    return false;
  }
  
  if (!Database::qrUpdate("entres_stock", QStringList{"restant"}, {quantite - gone}, "id", id)) {
    qDebug() << "Error 42" << Database::lastError();
    return false;
  }
  
  return true;
}

bool SqlQueryEngine::updateStockIndex(const QString& cip13) {
  QSqlQuery query = Database::select("stock", {"code_CIP13"}, "code_CIP13", cip13);
  if (!query.next()) {
    qDebug() << "Error 50" << query.lastError().text();
    qDebug() << "  :-" << cip13;
    return false;
  }

  int restant = 0, id = -1;
  query = Database::select("entres_stock", {"id", "restant"},
                           {"code_CIP13"}, {cip13}, "AND restant > 0 AND deleted = 0 ORDER BY ID ASC");
  bool present = false;

  while (query.next()) {
    present = true;
    if (id == -1) id = query.value(0).toInt();
    restant += query.value(1).toInt();
  }

  //  if (present) {
  if (!Database::qrUpdate("stock", {"restant", "id_current"},
                          {restant, id}, "code_CIP13", cip13)) {
    qDebug() << "Error 51 Could not update stock at" << cip13 << ":-:" << Database::lastError();
    return false;
  }
  //}

  return present;
}

QString SqlQueryEngine::ajouterStock(const QString& cip13, int idFournisseur, int quantite,
                                     int achat, int vente, const QString &peremptionString) {


  QDateTime peremption = QDateTime::fromString(peremptionString, "dd/MM/yyyy");

  bool ac = achat <= 0;
  bool vt = vente <= 0;
  bool fr = idFournisseur== 0;
  bool pr = QDate::currentDate().toJulianDay() > peremption.date().toJulianDay();

  if (ac || vt || fr || pr) {
    QString txt = "";
    if (ac)
      txt = "Prix d'achat est de 0.\n";
    if (vt)
      txt += "Prix de vente est de 0.\n";
    if (fr)
      txt += "Aucun fournisseur n'a ete choisi.\n";
    if (pr)
      txt += "La date de peremenption est depasse.\n";

    return txt;
  }

  qint64 _dt = QDateTime::currentSecsSinceEpoch();

  bool ins = Database::qrInsert("entres_stock",
                                {"code_CIP13", "restant", "quantite", "prix_d_achat",
                                 "prix_de_vente", "date_acquisition", "id_fournisseur",
                                 "date_peremption"},
                                {cip13, quantite, quantite, achat,
                                 vente, _dt, idFournisseur,
                                 peremption.toSecsSinceEpoch()});

  QString error;
  if (!ins) {
    error = "Erreur could not insert in entrees stock " + cip13
      + " " + Database::lastError();
    return error;
  }

  auto _id = Database::getQuery()->lastInsertId();
  qDebug() << "Inserted entres_stock at id" << _id;

  if (!updateStockIndex(cip13)) {
    qDebug() << "Don't mind the error 50";

    int category = 1;
    QSqlQuery query = Database::select("produits JOIN presentation_produit ON produits.code_produit = presentation_produit.code_produit", {"category"}, "ean_13", cip13);
    if (query.next()) {
      category = query.value(0).toInt();
    }
    
    if (!Database::qrInsert("stock", {"code_CIP13", "restant",
                                      "id_current", "category"},
        {cip13, quantite, _id, category})) {
      error = "Could not insert in stock "
        + cip13 + " " + QString::number(quantite) + " " + _id.toString()
        + " " + Database::lastError();
      return error;
    } else updateStockIndex(cip13);
  }

  return "";
}

bool SqlQueryEngine::isDateValid(const QString &date) {
  return QDate::fromString(date, "dd/MM/yyyy").toString("dd/MM/yyyy") == date;
}

bool SqlQueryEngine::isTimeValid(const QString &time) {
  return QDateTime::fromString(time, "hh:mm:ss").toString("hh:mm:ss") == time;
}


bool SqlQueryEngine::vendre(QVariantMap produits, int valeur, int donne, int rendu) {
  if (userId == -1) {
    qDebug() << "Error 9";
    return false;
  }

  qint64 date = QDateTime::currentSecsSinceEpoch();
  bool insert = Database::qrInsert("facture",
                                   {"date", "valeur", "paye", "donne", "rendu", "id_user"},
                                   {date, valeur, (donne - rendu), donne, rendu, userId});
  if(!insert) {
    qDebug() << "Error 10" << Database::lastError();
    return false;
  }

  QSqlQuery q = Database::select("facture", {"id"}, "date", date);
  if (q.next()) {
    int idFacture = q.value(0).toInt();
    foreach (const QString &cip13, produits.keys()) {
      if (!insertFlux(idFacture ,cip13, produits[cip13].toInt()))
        return false;
    }


    /*if (ui->imprimer->isChecked()) {
      Facture fact;
      fact.setId(idfacture);
      fact.doPrinting(false);
      }*/
  } else {
    qDebug() << "Error 11" <<"la facture a ete enregistre mais ne peut etre retrouvee.";
    return false;
  }

  return true;
}

bool SqlQueryEngine::enregistrerVente(int idFacture, const QString& cip13, int quantite) {
  int aVendre = quantite;
  bool ch = false;

  while (aVendre > 0) {
    int idCurrent = -3, restant = -3;
    QSqlQuery q = Database::select("stock", {"restant", "id_current"}, "code_CIP13", cip13);

    if (q.next()) {
      restant = q.value(0).toInt();
      idCurrent = q.value(1).toInt();
    } else {
      qDebug() << "Error 1" << q.lastError().text();
      return false;
    }

    if (restant <= 0) {
      qDebug() << "Restant:" << restant << "of" << cip13;
      return false;
    }

    int restant_current = -3;
    q = Database::select("entres_stock", {"restant"}, "id", QString::number(idCurrent));
    if (q.next())
      restant_current = q.value(0).toInt();
    else {
      qDebug() << "Error 2" << q.lastError().text();
      return false;
    }

    int rr;
    if (restant_current > aVendre) {
      rr = restant_current - aVendre;
      restant -= aVendre;
      aVendre = 0;
    } else {
      ch = true;
      rr = 0;
      restant -= restant_current;
      aVendre -= restant_current;
    }

    bool upd = Database::qrUpdate("entres_stock", "restant", rr, "id", idCurrent);
    if (!upd) {
      qDebug() << "Error 3" << Database::lastError();
      return false;
    }

    upd = Database::qrUpdate("stock", "restant", restant, "code_CIP13", cip13);
    if (!upd) {
      qDebug() << "Error 4" << Database::lastError();
      return false;
    }

    if (ch && restant > 0) {
      int id = -3;
      qDebug() << "Retreivent from an other entres_stock" << cip13 << restant;
      q = Database::select("entres_stock", {"id"}, {"code_CIP13"}, {cip13},
                           "AND restant > 0 AND deleted = 0 ORDER BY ID ASC LIMIT 1");
      if (q.next()) {
        id = q.value(0).toInt();
        qDebug() << "New entres_stock id" << id;
      } else {
        qDebug() << "Error 5" << Database::lastError();
        return false;
      }

      upd = Database::qrUpdate("stock", "id_current", id, "code_CIP13", cip13);
      if (!upd) {
        qDebug() << "Error 6" << Database::lastError();
        return false;
      }
    }

    bool ins = Database::qrInsert("flux", {"code_CIP13", "quantite", "id_facture", "id_entres_stock"},
                                  {cip13, quantite - aVendre, idFacture, idCurrent});
    if (!ins) {
      qDebug() << "Error 7" << Database::lastError();
      return false;
    }
  }
  return true;
}

bool SqlQueryEngine::editFacture(int idFacture, QVariantMap produits,
                                 int valeur, int donne, int rendu, bool err) {
  bool ok = update("facture", {"valeur", "paye", "donne", "rendu"},
                   {valeur, donne-rendu, donne, rendu}, "id", idFacture);
  if (!ok)
    return false;

  foreach (const QString &idFlux, produits.keys()) {
    qDebug() << idFlux << produits[idFlux];
    const QString cip13 = produits[idFlux].toList()[0].toString();
    const int qt = produits[idFlux].toList()[1].toInt();
    const int startQt =  produits[idFlux].toList()[2].toInt();

    int delta = qt - startQt;

    if (delta == 0) {
      continue;
    } else if (delta > 0) {
      if (!insertFlux(idFacture, cip13, delta)) return false;
    } else {
      if (!insertRetour(idFlux.toInt(), -delta, qt, err)) return false;
    }
  }

  return true;
}

bool SqlQueryEngine::insertFlux(int idFacture, const QString &cip13,
                                int quantite) {
  int idCurrent;
  QSqlQuery q = Database::select("stock", {"id_current"}, "code_CIP13", cip13);
  if (q.next())
    idCurrent = q.value(0).toInt();
  else {
    qDebug() << "Error 1" << q.lastError().text();
    return false;
  }

  int restant;
  q = Database::select("entres_stock", {"restant"}, "id", idCurrent);
  if (q.next())
    restant = q.value(0).toInt();
  else {
    qDebug() << "Error 2" << q.lastError().text();
    return false;
  }
  
  int delta = restant - quantite;
  int a = std::min(restant, quantite);
  int b = std::max(delta, 0);
  qint64 dtime = QDateTime::currentSecsSinceEpoch();

  if (!Database::qrInsert("flux", {"code_CIP13", "quantite", "restant", "id_facture", "id_entres_stock", "date"}, {cip13, a, a, idFacture, idCurrent, dtime})) {
    qDebug() << "Error 3" << Database::lastError();
    return false;
  }

  if (!Database::qrUpdate("entres_stock", "restant", b, "id", idCurrent)) {
    qDebug() << "Error 4" << Database::lastError();
    return false;
  }
  
  if (!removeFromStock(cip13, a))
    return false;

  if (delta <= 0) {
    int newId;
    qDebug() << "Got here" << delta;

    q = Database::select("entres_stock", {"id"}, {"code_CIP13"}, {cip13},
                         "AND restant > 0 AND deleted = 0 ORDER BY ID ASC LIMIT 1");
    if (q.next())
      newId = q.value(0).toInt();
    else {
      qDebug() << "Error 5" << q.lastError().text();
      return false;
    }
    if (!Database::qrUpdate("stock", "id_current", newId, "code_CIP13", cip13)) {
      qDebug() << "Error 6" << Database::lastError();
      return false;
    }
    if (delta != 0) {
      if (!insertFlux(idFacture, cip13, -delta))
        return false;
    }
  }
  return true;
}

bool SqlQueryEngine::insertRetour(int idFlux, int quantite, int newValue, bool err) {

  if (!Database::qrInsert("retours", {"id_flux", "quantite", "date", "err"},
                          {idFlux, quantite, QDateTime::currentSecsSinceEpoch(),
                           err ? 1 : 0}))
    return false;
  if (!Database::qrUpdate("flux", QStringList{"restant"}, {newValue}, "id", idFlux))
    return false;

  QSqlQuery q = Database::select("flux JOIN entres_stock ON flux.id_entres_stock = entres_stock.id", {"entres_stock.id", "entres_stock.restant", "entres_stock.code_CIP13"}, "flux.id", idFlux);
  if (!q.next()) {
    qDebug() << "Error 30" << q.lastError().text();
    return false;
  }
  int idEntresStock = q.value(0).toInt();
  int restant = q.value(1).toInt();
  QString cip13 = q.value(2).toString();

  if (!Database::qrUpdate("entres_stock", QStringList{"restant"},
                          {restant + quantite}, "id", idEntresStock)) {
    qDebug() << "Error 31" << Database::lastError();
    return false;
  }

  if (!updateStockIndex(cip13)) {
    qDebug() << "Error 32" << "Update Stock Index Failed";
    return false;
  }

  return true;
}

bool SqlQueryEngine::removeFromStock(const QString& cip13, int qt) {
  int restant;
  QSqlQuery q = Database::select("stock", {"restant"}, "code_CIP13", cip13);
  if (q.next())
    restant = q.value(0).toInt();
  else {
    qDebug() << "Error 01" << q.lastError().text();
    return false;
  }

  if (!Database::qrUpdate("stock", "restant", restant - qt, "code_CIP13", cip13)) {
    qDebug() << "Error 02" << Database::lastError();
    return false;
  }

  return true;
}

bool SqlQueryEngine::doRetour(int idFlux, int quantite, bool err) {
  QSqlQuery q = Database::select("flux", {"restant"}, "id", idFlux);
  if (!q.next()) {
    qDebug() << "Error 20" << q.lastError().text();
    return false;
  }

  int restant = q.value(0).toInt();
  int newValue = restant - quantite;
  if (newValue < 0) {
    qDebug() << "Error 21" << q.lastError().text();
    return false;
  }
    
  return insertRetour(idFlux, quantite, newValue, err);
}

qint64 SqlQueryEngine::dateTimeToSecSinceEpoch(const QString &dateTime) {
  qDebug() << dateTime << QDateTime::fromString(dateTime, "dd/MM/yyyy");
  return QDateTime::fromString(dateTime, "dd/MM/yyyy").toSecsSinceEpoch();

}
