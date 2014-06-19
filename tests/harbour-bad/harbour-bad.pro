# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
CONFIG += sailfishapp

OTHER_FILES += rpm/harbour-bad.spec \
               harbour-bad.desktop

TEMPLATE = subdirs

quazip_lib.file = harbour-bad-quazip/harbour-bad-quazip.pro
quazip_lib.target = quazip-lib

app_src.subdir = src
app_src.target = app-src
app_src.depends = quazip-lib


SUBDIRS = quazip_lib app_src src/dbus
