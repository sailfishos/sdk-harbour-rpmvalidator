TEMPLATE = app
TARGET = harbour-good
CONFIG += sailfishapp

SOURCES += harbour-good.cpp

CONFIG(release, debug|release) {
    DEFINES += QT_NO_DEBUG_OUTPUT
}

OTHER_FILES += qml/*.qml \
               qml/cover/*.qml \
               qml/pages/*.qml \
               qml/pages/qmlmodules/*.qml

RESOURCES += \
    qrc-qml-files.qrc
