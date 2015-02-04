# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-bad-vendor-none

CONFIG += sailfishapp

SOURCES += src/harbour-bad-vendor-none.cpp

OTHER_FILES += qml/harbour-bad-vendor-none.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/SecondPage.qml \
    rpm/harbour-bad-vendor-none.changes.in \
    rpm/harbour-bad-vendor-none.spec \
    rpm/harbour-bad-vendor-none.yaml \
    translations/*.ts \
    harbour-bad-vendor-none.desktop

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-bad-vendor-none-de.ts

