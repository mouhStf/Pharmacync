#include <QSqlQueryModel>
#include <QDateTime>
#include <qsqlquerymodel.h>
#include <qtmetamacros.h>

class TableModel : public QSqlQueryModel
{
  Q_OBJECT
  Q_PROPERTY(QString query WRITE setQuery NOTIFY queryChanged)
  Q_PROPERTY(QList<int> columnsWidth WRITE setColumnsWidth)
  Q_PROPERTY(QList<QString> horizontalHeader WRITE setTableHorizontalHeader)
  Q_PROPERTY(QList<int> datesColumns WRITE setDatesColumns)
  Q_PROPERTY(QList<int> boolsColumns WRITE setBoolsColumns)
  Q_PROPERTY(int idCol WRITE setIdCol)
  
public:
  
  TableModel(QObject* parent = nullptr);
  
  void setColumnsWidth(const QList<int> &columnsWidth);
  void setDatesColumns(const QList<int> &columns);
  void setBoolsColumns(const QList<int> &columns);
  void setIdCol(int idCol);

  void setQuery(const QString &query);;
  
  QVariant data(const QModelIndex &index, int role) const override;
  QHash<int, QByteArray> roleNames() const override;
  
  void setTableHorizontalHeader(const QList<QString> &horizontalHeader);

signals:
  void queryChanged();
                                                                       
public slots:
  QVariant getIdVal(int rowIndex);
  QVariant getVal(int rowIndex, int colIndex);
  int columnWidth(int column) const;
  void refresh() { QSqlQueryModel::refresh(); }

private slots:
  void updateWidthLastColumn();
  
private:
  QList<int> columnsWidth;
  QList<int> datesColumns;
  QList<int> boolsColumns;
  int id_col;
  int widthLastColumn;
};
