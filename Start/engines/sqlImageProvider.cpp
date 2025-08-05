#include "sqlImageProvider.h"

SqlImageProvider::SqlImageProvider() : QQuickImageProvider(QQuickImageProvider::Pixmap) {
    query = new QSqlQuery;
}

QPixmap SqlImageProvider::requestPixmap(const QString &px, QSize *size, const QSize &requestedSize) {
  loadedImage = false;
    loadedFile = false;
    int width = requestedSize.width() > 0 ? requestedSize.width() : 300;
    int height = requestedSize.height() > 0 ? requestedSize.height() : 300;
    if (px.startsWith("file://")) {
        QString imagePath = px.sliced(7);
        if (image.load(imagePath)) {
            *size = QSize(image.size());
            loadedFile = true;
            loadedImage = true;
            return image.scaled(width, height, Qt::KeepAspectRatio);
        }
    } else if (px.startsWith("db://")) {
        // db://table/col/val
        QStringList parts = px.split("/");
        if (parts.count() == 5) {
            QString table = parts[2];
            QString idCol = parts[3];
            QString idVal = parts[4];
            if (loadImageFromDatabase(table, idCol, idVal)) {
              loadedImage = true;
              *size = QSize(image.size());
              return image.scaled(width, height, Qt::KeepAspectRatio);
            }
        }
    }

    QPixmap pixmap(1,1);
    pixmap.fill(Qt::transparent);
    return pixmap;
}

bool SqlImageProvider::loadImageFromDatabase(const QString &tableName, const QString &colId, const QString &idVal) {
    QSqlQuery qry = Database::select(tableName, {"image_data"}, colId, idVal);
    if (qry.next() && qry.value(0).toByteArray().size() > 0) {
        return image.loadFromData(qry.value(0).toByteArray());
    }
    return false;
}

bool SqlImageProvider::save(const QString &tableName, const QString &idCol, const QString &idVal) {
    if (!loadedFile) return false;

    QByteArray bytes;
    QBuffer buffer(&bytes);
    buffer.open(QIODevice::WriteOnly);
    if (!image.save(&buffer, "PNG"))
        return false;

    query->prepare("UPDATE " + tableName + " SET image_data = ? WHERE " + idCol+ " = ?");
    query->addBindValue(bytes);
    query->addBindValue(idVal);
    return query->exec();
}

bool SqlImageProvider::deleteImage(const QString &tableName, const QString &idCol, const QString &idVal) {
    return Database::qrUpdate(tableName, QStringList{"image_data"}, {""}, idCol, idVal);
}
