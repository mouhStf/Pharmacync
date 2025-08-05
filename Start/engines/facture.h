#include <QQuickPaintedItem>

class Facture : public QQuickPaintedItem {
  Q_OBJECT

public:
  Facture(QQuickItem *parent = nullptr);
  void paint(QPainter *painter) override;
};

