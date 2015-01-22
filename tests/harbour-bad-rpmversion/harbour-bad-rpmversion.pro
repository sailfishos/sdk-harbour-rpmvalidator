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
TARGET = harbour-bad-rpmversion

CONFIG += sailfishapp

SOURCES += src/harbour-bad-rpmversion.cpp

OTHER_FILES += qml/harbour-bad-rpmversion.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/SecondPage.qml \
    rpm/harbour-bad-rpmversion.changes.in \
    rpm/harbour-bad-rpmversion.spec \
    rpm/harbour-bad-rpmversion.yaml \
    translations/*.ts \
    harbour-bad-rpmversion.desktop

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-bad-rpmversion-de.ts

