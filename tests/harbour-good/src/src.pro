TEMPLATE = app
TARGET = harbour-good
CONFIG += sailfishapp
LIBS += -ldl -lquazip -L../harbour-good-quazip/
SOURCES += harbour-good.cpp

QMAKE_LFLAGS += -Wl,-rpath,\\$${LITERAL_DOLLAR}$${LITERAL_DOLLAR}ORIGIN/../share/harbour-good/lib

CONFIG(release, debug|release) {
    DEFINES += QT_NO_DEBUG_OUTPUT
}

OTHER_FILES += qml/*.qml \
               qml/cover/*.qml \
               qml/pages/*.qml \
               qml/pages/qmlmodules/*.qml

RESOURCES += \
    qrc-qml-files.qrc

QMAKE_RESOURCE_FLAGS += -threshold 0 -compress 9
