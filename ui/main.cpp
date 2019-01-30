#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTranslator>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QTranslator translator;
    translator.load(":/en_us.qm");
    app.installTranslator(&translator);
    engine.retranslate();
    engine.load(QUrl(QStringLiteral("qrc:/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
