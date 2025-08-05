#include "tableModel.h"

TableModel::TableModel(QObject *parent)
    : QSqlQueryModel{parent}, id_col{0}, widthLastColumn{0} {}

void TableModel::setColumnsWidth(const QList<int> &columnsWidth) {
  this->columnsWidth = QList<int>(columnsWidth);
  updateWidthLastColumn();
}

void TableModel::setQuery(const QString &query) {
  QSqlQueryModel::setQuery(query);
  emit queryChanged();
  updateWidthLastColumn();
}

void TableModel::updateWidthLastColumn() {
  widthLastColumn = 0;
  for (int i = 0; i < columnCount() - 1; i++)
    widthLastColumn -= columnWidth(i);
}

void TableModel::setDatesColumns(const QList<int> &columns) {
  this->datesColumns = QList<int>(columns);
}

void TableModel::setBoolsColumns(const QList<int> &columns){
  this->boolsColumns = QList<int>(columns);
}

int TableModel::columnWidth(int column) const {
  if (column < columnCount() - 1)
    return column < columnsWidth.count() ? columnsWidth[column] : 100;
  else if (column == columnCount() - 1)  {
    return widthLastColumn;
  }else if (columnsWidth.size() > column-1)
    return columnsWidth[column-1];
  return -1;
}

void TableModel::setIdCol(int idCol) {
  id_col = idCol;
}

QVariant TableModel::data(const QModelIndex &index, int role) const {
  if (datesColumns.contains(index.column()) && role == Qt::DisplayRole)
    return QDateTime::fromSecsSinceEpoch(QSqlQueryModel::data(index, role).toInt()).toString("dd/MM/yyyy");
  if (boolsColumns.contains(index.column()) && role == Qt::DisplayRole)
    return QSqlQueryModel::data(index, role).toInt() == 1 ? "✔" : "✘";
  return QSqlQueryModel::data(index, role);
}

QHash<int, QByteArray> TableModel::roleNames() const {
  return {
    {Qt::DisplayRole, "display"},
    {Qt::UserRole+1, "columnWidth"}};
}

void TableModel::setTableHorizontalHeader(const QList<QString> &horizontalHeader) {
  for (int i = 0; i < horizontalHeader.count(); i++)
    setHeaderData(i, Qt::Horizontal, horizontalHeader[i]);
}

QVariant TableModel::getIdVal(int rowIndex) {
  return data(this->index(rowIndex, id_col), Qt::DisplayRole);
}

QVariant TableModel::getVal(int rowIndex, int colIndex) {
  return data(this->index(rowIndex, colIndex), Qt::DisplayRole);
}

