#include "database.h"
#include "qlogging.h"
#include "qsqldatabase.h"
#include "qvariant.h"


// Not fit for parallel computing

QSqlDatabase *Database::db = nullptr;
QSqlQuery *Database::query = nullptr;

QHash<QString, QStringList> Database::tablesRestant = {
  {"stock", {
      "code_CIP7", "restant",
      "id_current", "restant_current"}},
  {"presentation_produit", {
      "ean-13", "code_produit",
      "libelle", "description"
    }}
};
QHash<QString, QStringList> Database::tables = {
  {"specialite", {"code_CIS",
		  "denomination_du_medicament",
		  "forme_pharmaceutique",
		  "voies_dadministration",
		  "statut_administratif_de_lAMM",
		  "type_procedure_dAMM",
		  "etat_de_commercialisation",
		  "date_dAMM",
		  "statutBdm",
		  "numero_de_lautorisation_europeenne",
		  "titulaires",
		  "surveillance_renforcee"}},
  
  {"composition", {"code_CIS",
		   "designation_de_lelement_pharmaceutique",
		   "code_de_la_substance",
		   "denomination_de_la_substance",
		   "dosage_de_la_substance",
		   "referene_de_ce_dosage",
		   "nature_du_composant",
		   "numero_de_liaison_SA_FT"}},
  
  {"presentation", {"code_CIS",
		    "code_CIP7",
		    "libelle_de_la_presentation",
		    "statut_administratif_de_la_presentation",
		    "etat_de_commercialisation",
		    "date_de_la_declaration_de_commercialisation",
		    "code_CIP13",
		    "agrement_aux_collectivite",
		    "taux_de_remboursement",
		    "prix_du_medicament_en_euro",
		    "indications_ouvrant_droit_au_remboursement"}}
};


bool Database::qrInsert(const QString &tableName,
			const QStringList &cols,
			const QList<QVariant> &vals) {

  QString vars;
  for (auto _ : vals) vars += "?,";
  
  vars.chop(1);

  QString qrStr = "INSERT INTO "+tableName+" ("+cols.join(",")+") VALUES ("+vars+")";
  query->prepare(qrStr);

  for (const QVariant &_x : vals)
    query->addBindValue(_x);
  if (!query->exec()) {
    qDebug() << "Error 00" << query->executedQuery()
             << query->boundValues();
    return false;
  }
  return true;
}

bool Database::qrUpdate(const QString &tableName, const QStringList &cols,
                        const QList<QVariant> &vals, const QStringList &wheres,
                        const QList<QVariant> &wheresVals) {
  if (cols.size() != vals.size() || wheres.size() != wheresVals.size()) {
    error(tableName, "Cols size, val size dont match in where or vals");
    return false;
  }
  
  QString str = "UPDATE " + tableName + " SET " + cols.join(" = ?, ") +
                " = ? WHERE " + wheres.join(" = ? AND ") + " = ?";
  query->prepare(str);

  for (const QVariant &i : vals)
    query->addBindValue(i);
  for (const QVariant &i : wheresVals)
    query->addBindValue(i);

  return query->exec();
}


QSqlQuery Database::select(const QString &tableName,
			    const QStringList &columns,
			    const QStringList &wheres,
			    const QList<QVariant> &wheresVals, const QString &supp) {

  QSqlQuery q(*db);
  if (wheres.length() > 0 && wheres.length() != wheresVals.length())
    {qDebug() << "Error 01"; return q; }

  QList<QString> stat;
  for (const QString &i : wheres) stat.append(i + " = ?");

  QString str("SELECT " + columns.join(",") + " FROM " + tableName +
              (wheres.length() > 0 ? " WHERE " + stat.join(" AND ") : ""));
  //qDebug() << str+" "+supp;

  q.prepare(str+" "+supp);
  for (const QVariant &_x : wheresVals) q.addBindValue(_x);

  if (!q.exec()) {
      qDebug() << "Error 02" << q.lastError();
      return q;
  }

  return q;
}

void Database::initDatabase() {
  if (db == nullptr) {
    db = new QSqlDatabase(QSqlDatabase::addDatabase("QSQLITE"));
    query = new QSqlQuery(*db);
    db->setDatabaseName("DataPrimeYo.db");
  }
  qDebug() << "[::] Database open ?:" << db->open();
  if (!db->isOpen())
    qDebug() << "[!!] Database could not open: " << db->lastError();
}
