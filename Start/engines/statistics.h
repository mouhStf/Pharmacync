#ifndef STASTICS_H
#define STASTICS_H

#include <QObject>

class Statistics : public QObject {
  Q_OBJECT

public:
  Statistics(QObject *parent = nullptr);

public slots:

  void turnover_rate(const QDate &start_date, const QDate &end_date);
  void updateFactureStats();
};

#endif
