#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "core/database.h"
#include "core/tableModel.h"
#include "engines/loginEngine.h"
#include "engines/sqlQueryEngine.h"
#include "engines/sqlImageProvider.h"
#include "engines/painterEngine.h"
#include "engines/statistics.h"

int main(int argc, char *argv[]) {

  QApplication app(argc, argv);

  Database::initDatabase();
  Statistics stats;

  qmlRegisterType<LoginEngine>("engines", 1, 0, "LoginEngine");
  qmlRegisterType<TableModel>("core", 1, 0, "TableModel");

  QQmlApplicationEngine engine;
  SqlImageProvider *imageProvider = new SqlImageProvider;
  SqlQueryEngine* sqlEngine = new SqlQueryEngine;
  PainterEngine* painterEngine = new PainterEngine(&engine);

  engine.addImageProvider(QLatin1String("imageProvider"), imageProvider);
  engine.rootContext()->setContextProperty("imageProviderObject", imageProvider);
  engine.rootContext()->setContextProperty("sqlEngine", sqlEngine);
  engine.rootContext()->setContextProperty("painterEngine", painterEngine);

  QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                   &app, []() { QCoreApplication::exit(-1);},
                   Qt::QueuedConnection);

  engine.loadFromModule("PharmaCync.Start", "Main");

  return app.exec();
}
