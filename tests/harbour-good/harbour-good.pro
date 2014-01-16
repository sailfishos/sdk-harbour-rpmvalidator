# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed

CONFIG += sailfishapp

OTHER_FILES += rpm/harbour-good.spec \
               harbour-good.desktop \
               TODO

TEMPLATE = subdirs
SUBDIRS = src/dbus src
