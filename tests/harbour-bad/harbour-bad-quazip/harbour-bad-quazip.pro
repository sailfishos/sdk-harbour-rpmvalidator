TEMPLATE = lib
CONFIG += qt warn_on
QT -= gui
TARGET = quazip

DEFINES += QUAZIP_BUILD
CONFIG(staticlib): DEFINES += QUAZIP_STATIC

# Input
include($$PWD/../../quazip-0.6.2/quazip/quazip.pri)

target.path=/usr/share/harbour-bad/lib
INSTALLS += target
