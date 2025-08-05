#include "statistics.h"
#include "core/database.h"

Statistics::Statistics(QObject* parent) : QObject{parent} {
  updateFactureStats();
}

void Statistics::turnover_rate(const QDate &start_date, const QDate &end_date) {
}

void Statistics::updateFactureStats() {
  QSqlQuery query;

  if (!query.exec("CREATE TABLE IF NOT EXISTS facture_stats (date TEXT PRIMARY KEY, quantite INTEGER, total_vente INTEGER)")) {
    qDebug() << "Error creating facture_stats:" << query.lastError().text();
    return;
  }

  QString lastDate = "1970-01-01"; // Default if table is empty
  if (query.exec("SELECT MAX(date) FROM facture_stats")) {
    if (query.next() && !query.value(0).isNull()) {
      lastDate = query.value(0).toString();
    }
  } else {
    qDebug() << "Error fetching last date:" << query.lastError().text();
    return;
  }
  qint64 lastDateTimestamp = QDate::fromString(lastDate, Qt::ISODate).startOfDay().toSecsSinceEpoch();

  QString insertQuery = QString(
    "INSERT OR REPLACE INTO facture_stats (date, quantite, total_vente) "
    "SELECT STRFTIME('%Y-%m-%d', facture.date, 'unixepoch'), SUM(flux.restant), SUM(flux.restant * entres_stock.prix_de_vente) "
    "FROM facture "
    "JOIN flux ON facture.id = flux.id_facture "
    "JOIN entres_stock ON flux.id_entres_stock = entres_stock.id "
    "WHERE facture.date >= '%1' "
    "GROUP BY 1"
  ).arg(lastDateTimestamp);

  if (!query.exec(insertQuery)) {
    qDebug() << "Error inserting into temp table:" << query.lastError().text();
    return;
  }

  qDebug() << "facture_stats updated from last date" << lastDate << "with new or concatenated total_vente values";
}
