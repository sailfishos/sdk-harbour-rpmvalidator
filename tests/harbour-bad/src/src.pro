TEMPLATE = app
TARGET = harbour-bad
PKGCONFIG += ncurses
LIBS += -lquazip -L../harbour-bad-quazip/

QMAKE_RPATHDIR = /usr/lib/

SOURCES += harbour-bad.cpp

OTHER_FILES += qml/*.qml \
               qml/cover/*.qml \
               qml/pages/*.qml \
               qml/pages/qmlmodules/*.qml

RESOURCES += \
    qrc-qml-files.qrc



# this part is from /usr/share/qt5/mkspecs/features/sailfishapp.prf
# check-out for changes !

QT += quick qml

target.path = /usr/bin

!sailfishapp_no_deploy_qml {
    qml.files = qml
    qml.path = /usr/share/$${TARGET}

    INSTALLS += qml
}

desktop.files = $${TARGET}.desktop
desktop.path = /usr/share/applications

icon.files = $${TARGET}.png
icon.path = /usr/share/icons/hicolor/86x86/apps

INSTALLS += target desktop icon

CONFIG += link_pkgconfig
PKGCONFIG += sailfishapp
INCLUDEPATH += /usr/include/sailfishapp

# we don't want this to be set! this is harbour-bad rpm!
#QMAKE_RPATHDIR += /usr/share/$${TARGET}/lib

OTHER_FILES += $$files(rpm/*)
