#include "painterEngine.h"


PainterEngine::PainterEngine(QObject *parent) : QObject{parent} {
  _font.setFamily("Arial");
  _printer = new QPrinter(QPrinter::HighResolution);
  _printer->setOutputFileName("default.pdf");
  pdi = new QPrintDialog(_printer);
}

void PainterEngine::doPrinting(int numero, const QString &emetteur, const QDateTime &dateTime,
				int total, int paye, int donne, int rendu,
				const QList<Line> &medics) {
  _num = numero;
  _emetteur = emetteur;
  _time = dateTime;
  _total = total;
  _paye= paye;
  _donne = donne;
  _rendu = rendu;
  _medics = medics;
  
  doTest();
}

void PainterEngine::setFontPointSizeF(qreal sz, bool bold)
{_font.setPointSizeF(sz * _fs); _font.setBold(bold); _painter->setFont(_font);}

QRectF PainterEngine::drawText(QRectF rect, QString text, int flags) {
  _painter->drawText(rect,flags | Qt::TextWordWrap, text);
  return _painter->boundingRect(rect, text);
}

void PainterEngine::drawHLine(qreal y)
{ _painter->drawLine(0, y, _pageRect.width(), y); }

void PainterEngine::drawBorders() {
  tableBottom = _pageRect.top();
  auto drawer = [&](qreal x) {
    _painter->drawLine(x, tableTop, x, tableBottom);
  };
  drawer(0);
  drawer(_pageRect.right());
  drawer(_col1.left());
  drawer(_col2.left());
  drawer(_col3.left());
}

void PainterEngine::drawInCell(QRectF rect, QString text, qreal height) {
  QRectF net = rect;
  net.setHeight(height);
  drawText(net, text, Qt::AlignCenter);
}

void PainterEngine::setColsTop(qreal top) {
  _col0.setTop(top); _col1.setTop(top);
  _col2.setTop(top); _col3.setTop(top);
}

void PainterEngine::newPage() {
  drawBorders();
  _pageRect.setTop(_pageRect.bottom() - _h);
  setFontPointSizeF(9);
  drawText(_pageRect, "page " + QString::number(_pages+1) + " / " +
	   QString::number(_totPages), Qt::AlignRight);
  setFontPointSizeF(12);

  _printer->newPage();
  _pages++;
  _pageRect.setTop(0);
  setColsTop(0);
  tableTop = 0;
  _painter->drawLine(0, 0, _pageRect.right(), 0);
}

void PainterEngine::drawContent(QString medicament, int qt, int prU){
  qreal h = _h + _painter->boundingRect(_col0, medicament).height(); // lineeight
  
  if ( (_col0.top() + h) > _pageHeight ) newPage();

  drawInCell(_col0, medicament, h);
  drawInCell(_col1, QString::number(qt), h);
  drawInCell(_col2, QString::number(prU), h);
  drawInCell(_col3, QString::number(qt * prU), h);

  newLine(_pageRect.top() + h);
}

void PainterEngine::newLine(qreal y) {
  _pageRect.setTop(y);
  setColsTop(y);
  drawHLine(y);
}

void PainterEngine::doTest() {
  QString documentDir = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
  _printer->setOutputFileName(documentDir + "/facture-"
                              + QString::number(_num) + ".pdf");
  QPrintDialog pdi(_printer);

  if (!(pdi.exec() == QDialog::Accepted))
    return;

  _painter = new QPainter(_printer);
  _pageRect = _printer->pageRect(QPrinter::DevicePixel);
  _col0 = _pageRect;
  _col1 = _pageRect;
  _col2 = _pageRect;
  _col3 = _pageRect;

  _fs = _pageRect.width() /  9583; // This ratio is to get the font as on a A4 paper
  _h = _painter->boundingRect(_pageRect, "AB").height() * _fs; // margin
  _pages = 0;
  _pageHeight = _pageRect.height() - _h; // Remaining of the page to write infos

  {
    QPen _pen = _painter->pen();
    _pen.setColor(Qt::black);
    _pen.setWidth(2);
    _painter->setPen(_pen);
  }
    
  _painter->beginNativePainting();
  _pageRect.moveTo(0,0);
  _totPages = getPageNumber() + 1;
  makeTitle();
  makeHeader();
  makeContent();
  _painter->end();
}

void PainterEngine::makeTitle() {
  setFontPointSizeF(20, true);
  QString title = _donne > 0 ? "Facture" : "Devis";
  QRectF br = drawText(_pageRect, title, Qt::AlignHCenter | Qt::AlignTop);
  _pageRect.setTop(br.bottom() + br.height() / 2);
}

void PainterEngine::makeHeader() {
  setFontPointSizeF(12);

  auto labeled = [&](QRectF rect, QString lab, QString text) {
    _font.setBold(true);
    _painter->setFont(_font);
    QRectF net = rect;
    net.setLeft(drawText(rect, lab).right());
    _font.setBold(false);
    _painter->setFont(_font);
    rect.setTop(drawText(net, text).bottom());
    return rect;
  };
  
  // This for not show numero for devis:
  QString numLabel = _num > 0 ? "Numero : " : "";
  QString num = _num > 0 ? QString::number(_num) : "";
    
  labeled(labeled(_pageRect, numLabel, num),
	  "Emetteur : ", _emetteur);

  QRectF right = drawText(_pageRect, _time.toString("dd / MM / yyyy") + "\n" + _time.toString("hh:mm:ss"), Qt::AlignRight);

  tableTop = right.bottom() + right.height() / 2;
  newLine(tableTop);
}

void PainterEngine::makeContent() {
  newLine(tableTop);
  setFontPointSizeF(12, true);
  {
    qreal w = _painter->boundingRect(_pageRect, "Prix Unitaire").width();
    _col3.setLeft(_col3.right() - w);
    _col2.setRight(_col3.left());
    _col2.setLeft(_col2.right() - w);
    _col1.setRight(_col2.left());
    _col1.setLeft(_col1.right() - w);
    _col0.setRight(_col1.left());
  }

  qreal h = _painter->boundingRect(_col0, "Medicament").height() * 2;
  drawInCell(_col0, "Medicament", h);
  drawInCell(_col1, "Qt", h);
  drawInCell(_col2, "Prx. Unit", h);
  drawInCell(_col3, "Prx. Tot", h);

  newLine(_pageRect.top() + h);

  setFontPointSizeF(12);

  for (Line l : _medics) 
    drawContent(l.medicament, l.qt, l.price);

  drawBorders();

  _pageRect.setTop(_pageRect.top() + _h);

  if (_pageRect.top() + _painter->boundingRect(_pageRect, "\nPayé : " + QString::number(_paye) + "F CFA (" + QString::number(_donne) + " F CFA donné - " + QString::number(_rendu) + " F CFA rendu)").height() > _pageHeight) newPage();

  if (_donne > 0)
    _painter->drawText(_pageRect, Qt::AlignRight, "\nPayé : " + QString::number(_paye) + "F CFA (" + QString::number(_donne) + " F CFA donné - " + QString::number(_rendu) + " F CFA rendu)");

  qreal ww = _pageRect.width();
  _pageRect.setRight(_pageRect.width() -  drawText(_pageRect, QString::number(_total) + " F CFA", Qt::AlignRight).width() );

  setFontPointSizeF(12, true);
  drawText(_pageRect,  "Total : ", Qt::AlignRight);

  setFontPointSizeF(9);
  _pageRect.setWidth(ww);
  _pageRect.setTop(_pageRect.bottom() - _h);
  if (_totPages > 1)
    drawText(_pageRect, "page " + QString::number(_pages+1) + " / " +
	     QString::number(_totPages), Qt::AlignRight);
}

int PainterEngine::getPageNumber() {
  setFontPointSizeF(20, true);
  _totalHeight = 0;
  QRectF rc = _pageRect;
  rc.setTop(_painter->boundingRect(rc, "Facture").height() * 1.5);
  
  setFontPointSizeF(12);
  auto _rc = _painter->boundingRect(rc, "11\n12");
  rc.setTop(_rc.bottom() + _rc.height() / 2);

  setFontPointSizeF(12, true);
  rc.setWidth(rc.width() - _painter->boundingRect(rc, "Prix Unitaire").width()*3);
  
  qreal h = _painter->boundingRect(rc, "Medicament").height() * 2;
  rc.setTop(rc.top() + h);

  qDebug() << rc;

  int pages = 0;
  setFontPointSizeF(12);
  for (Line l : _medics) {
    qreal hh = _h + _painter->boundingRect(rc, l.medicament).height();

    if ( (rc.top() + hh) > _pageHeight ) {
      pages++;
      rc.setTop(0);
    }
    rc.setTop(rc.top() + hh);
  }

  rc.setTop(rc.top() + _h);
  rc.setWidth(_pageRect.width());

  if (rc.top() + _painter->boundingRect(rc, "\nPayé : " + QString::number(_paye) + "F CFA (" + QString::number(_donne) + " F CFA donné - " + QString::number(_rendu) + " F CFA rendu)").height() > _pageHeight) pages++;

  return pages;
}


bool PainterEngine::printFacture(int numero) {  
  QSqlQuery q = Database::select("facture", {"id_user", "date", "valeur", "paye", "donne", "rendu"}, "id", numero);
  if (!q.next()) {
    qDebug() << "Error 10" << q.lastError().text();
    return false;
  }

  int id_user = q.value(0).toInt();
  QDateTime date =   QDateTime::fromSecsSinceEpoch(q.value(1).toInt());
  int valeur = q.value(2).toInt();
  int paye = q.value(3).toInt();
  int donne = q.value(4).toInt();
  int rendu = q.value(5).toInt();

  q.prepare("SELECT denomination_du_medicament as nom, libelle_de_la_presentation as prenom , flux.restant, entres_stock.prix_de_vente FROM flux JOIN entres_stock ON flux.id_entres_stock = entres_stock.id JOIN presentation on entres_stock.code_CIP13 = presentation.code_CIP13 JOIN specialite ON specialite.code_CIS = presentation.code_CIS WHERE flux.restant > 0 AND flux.id_facture = ? UNION SELECT designation as nom, libelle as prenom , flux.restant, entres_stock.prix_de_vente FROM flux JOIN entres_stock ON flux.id_entres_stock = entres_stock.id JOIN presentation_produit on entres_stock.code_CIP13 = presentation_produit.ean_13 JOIN produits ON produits.code_produit = presentation_produit.code_produit WHERE flux.restant > 0 AND flux.id_facture = ?");
  q.addBindValue(numero);
  q.addBindValue(numero);
  if (!q.exec()) {
    qDebug() << "Error 11" << q.lastError().text();
    return false;
  }
  
  QList<Line> medics;
  while (q.next()) {
    medics.append(Line{
        q.value(0).toString() + " -- " + q.value(1).toString(),
        q.value(2).toInt(),
        q.value(3).toInt()
      });
  }

  q = Database::select("utilisateur",
                       {"titre", "prenom", "nom"},
                       "id", id_user);
  if (!q.next()) {
    qDebug() << "Error 12" << q.lastError().text();
    return false;
  }
  QString emetteur = q.value(0).toString() + " " + q.value(1).toString() + " " + q.value(2).toString();

  doPrinting(numero, emetteur, date, valeur, paye, donne, rendu, medics);

  return true;
}
