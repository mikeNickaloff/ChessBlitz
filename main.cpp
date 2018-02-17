#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "board.h"
#include "square.h"
#include "piece.h"


#include <QDir>
#include <QQmlEngine>
#include <QQmlFileSelector>
#include <QQuickView>
int main(int argc, char *argv[])
{
#if defined(Q_OleS_WIN)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    qmlRegisterType<Board>("com.chessblitz", 1, 0, "Board");
    qmlRegisterType<Square>("com.chessblitz", 1, 0, "Square");
    qmlRegisterType<Piece>("com.chessblitz", 1, 0, "Piece");
        engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
/*
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc,argv);
    app.setOrganizationName("datafault");
    app.setOrganizationDomain("datafault.net");
    app.setApplicationName(QFileInfo(app.applicationFilePath()).baseName());
    QQuickView view;
    qmlRegisterType<Board>("com.chessblitz", 1, 0, "Board");
    qmlRegisterType<Square>("com.chessblitz", 1, 0, "Square");
    qmlRegisterType<Piece>("com.chessblitz", 1, 0, "Piece");
    if (qgetenv("QT_QUICK_CORE_PROFILE").toInt()) {
        QSurfaceFormat f = view.format();
        f.setProfile(QSurfaceFormat::CoreProfile);
        f.setVersion(4, 4);
        view.setFormat(f);
    }
    if (qgetenv("QT_QUICK_MULTISAMPLE").toInt()) {
        QSurfaceFormat f = view.format();
        f.setSamples(4);
        view.setFormat(f);
    }
    //view.connect(view.engine(), &QQmlEngine::quit, &app, &QCoreApplication::quit);
    new QQmlFileSelector(view.engine(), &view);
    view.setSource(QUrl("qrc:///main.qml"));
    if (view.status() == QQuickView::Error)
        return -1;
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    if (QGuiApplication::platformName() == QLatin1String("qnx") ||
          QGuiApplication::platformName() == QLatin1String("eglfs")) {
        view.showFullScreen();
    } else {
        view.show();
    }
    return app.exec(); */
}




#define DECLARATIVE_EXAMPLE_MAIN(NAME) int main(int argc, char* argv[]) \
{\
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);\
    QGuiApplication app(argc,argv);\
    app.setOrganizationName("datafault");\
    app.setOrganizationDomain("datafault.net");\
    app.setApplicationName(QFileInfo(app.applicationFilePath()).baseName());\
    QQuickView view;\
    qmlRegisterType<Board>("com.chessblitz", 1, 0, "Board");\
    qmlRegisterType<Square>("com.chessblitz", 1, 0, "Square");\
    qmlRegisterType<Piece>("com.chessblitz", 1, 0, "Piece");\
    if (qgetenv("QT_QUICK_CORE_PROFILE").toInt()) {\
        QSurfaceFormat f = view.format();\
        f.setProfile(QSurfaceFormat::CoreProfile);\
        f.setVersion(4, 4);\
        view.setFormat(f);\
    }\
    if (qgetenv("QT_QUICK_MULTISAMPLE").toInt()) {\
        QSurfaceFormat f = view.format();\
        f.setSamples(4);\
        view.setFormat(f);\
    }\
    view.connect(view.engine(), &QQmlEngine::quit, &app, &QCoreApplication::quit);\
    new QQmlFileSelector(view.engine(), &view);\
    view.setSource(QUrl("qrc:///" #NAME ".qml")); \
    if (view.status() == QQuickView::Error)\
        return -1;\
    view.setResizeMode(QQuickView::SizeRootObjectToView);\
    if (QGuiApplication::platformName() == QLatin1String("qnx") || \
          QGuiApplication::platformName() == QLatin1String("eglfs")) {\
        view.showFullScreen();\
    } else {\
        view.show();\
    }\
    return app.exec();\
}


/*DECLARATIVE_EXAMPLE_MAIN(main) */