TEMPLATE = app
TARGET = harbour-bad
CONFIG += sailfishapp
PKGCONFIG += ncurses

SOURCES += harbour-bad.cpp

OTHER_FILES += qml/*.qml \
               qml/cover/*.qml \
               qml/pages/*.qml \
               qml/pages/qmlmodules/*.qml

RESOURCES += \
    qrc-qml-files.qrc

