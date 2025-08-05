#ifndef SQL_IMAGE_PROVIDER
#define SQL_IMAGE_PROVIDER

#include <QQuickImageProvider>
#include <QSqlQuery>

#include "core/database.h"

class SqlImageProvider : public QQuickImageProvider {
  Q_OBJECT
public:
  SqlImageProvider();
  
  QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize) override;                                                                                            
public slots:
  bool save(const QString &tableName, const QString &idCol, const QString &idVal);
  bool deleteImage(const QString &tableName, const QString &idCol, const QString &idVal);
  bool isImageLoaded() { return loadedImage; }
  
private:
  QSqlQuery* query;
  QPixmap image;
  bool loadedFile;
  bool loadedImage;
  
  bool loadImageFromDatabase(const QString &table, const QString &colId, const QString& idVal);
};

#endif
