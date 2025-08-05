#ifndef FACTURE_PAINTER_H
#define FACTURE_PAINTER_H

#include <QtPrintSupport>
#include <QStandardPaths>
#include "../core/database.h"

struct Line {
  QString medicament;
  int qt;
  int price;
};

class PainterEngine : public QObject
{
  Q_OBJECT
    
public:
  PainterEngine(QObject *parent = nullptr);

  void doPrinting(int numero, const QString &emetteur, const QDateTime &dateTime,
                  int total, int paye, int donne, int rendu,
                  const QList<Line> &medics);
public slots:
  bool printFacture(int numero);

private:
  QPrinter *_printer;
  QPainter *_painter;
  QPrintDialog* pdi;
  
  int _num;
  QString _emetteur;
  QDateTime _time;
  QList<Line> _medics;
  int _total;
  int _paye, _donne, _rendu;
  
  qreal _h;
  
  QRectF _pageRect;
  QFont _font;
  qreal _fs;

  QRectF _col0, _col1, _col2, _col3;

  void setFontPointSizeF(qreal sz, bool bold = false);
  QRectF drawText(QRectF rect, QString text, int flag = Qt::AlignLeft);
  void drawInCell(QRectF rect, QString text, qreal height);
  void drawContent(QString medicament, int qt, int prU);
  
  void setColsTop(qreal top);
  void drawBorders();
  void drawHLine(qreal y);
  void newLine(qreal y);
  void newPage();
  
  void doTest();
  void makeTitle();
  void makeHeader();
  void makeContent();

  qreal _totalHeight;

  int getPageNumber();
    
  qreal tableTop, tableBottom;
  qreal _pageHeight;
  int _pages;
  int _totPages;
};
#endif // PAINTER_H
