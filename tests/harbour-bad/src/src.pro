TEMPLATE = app
TARGET = harbour-bad
CONFIG += sailfishapp
PKGCONFIG += ncurses
LIBS += -lquazip -L../harbour-bad-quazip/

SOURCES += harbour-bad.cpp

OTHER_FILES += qml/*.qml \
               qml/cover/*.qml \
               qml/pages/*.qml \
               qml/pages/qmlmodules/*.qml

RESOURCES += \
    qrc-qml-files.qrc

