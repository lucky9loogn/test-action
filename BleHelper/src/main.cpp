#include <QApplication>
#include <QCoreApplication>
#include <QObject>
#include <QProcess>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QStringList>
#include <QStringLiteral>
#include <QUrl>

#include "ApplicationInfo.h"
#include "SettingsManager.h"

#ifdef WIN32
#  include <windows.h>
// 程序崩溃回调函数
LONG WINAPI ExceptionHandler(EXCEPTION_POINTERS *ExceptionInfo)
{
    QStringList arguments;
    arguments << "-crashed=";
    QProcess::startDetached(QGuiApplication::applicationFilePath(), arguments);
    return EXCEPTION_EXECUTE_HANDLER;
}
#endif // WIN32

int main(int argc, char *argv[])
{
#ifdef WIN32
    SetUnhandledExceptionFilter(ExceptionHandler);
    qputenv("QT_QPA_PLATFORM", "windows:darkmode=2");
#endif // WIN32

    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);

    QApplication app(argc, argv);
    QQmlApplicationEngine engine;

    SettingsManager::getInstance()->initTranslator(&engine);
    engine.rootContext()->setContextProperty("ApplicationInfo", ApplicationInfo::getInstance());
    engine.rootContext()->setContextProperty("SettingsManager", SettingsManager::getInstance());

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(
            &engine, &QQmlApplicationEngine::objectCreated, &app,
            [url](QObject *obj, const QUrl &objUrl) {
                if (!obj && url == objUrl)
                    QCoreApplication::exit(-1);
            },
            Qt::QueuedConnection);
    engine.load(url);
    const int exec = QApplication::exec();
    if (exec == 931) {
        QProcess::startDetached(qApp->applicationFilePath(), qApp->arguments());
    }
    return exec;
}
