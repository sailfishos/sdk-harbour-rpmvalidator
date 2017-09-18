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

quazip_lib.file = harbour-good-quazip/harbour-good-quazip.pro
quazip_lib.target = quazip-lib

app_src.subdir = src
app_src.target = app-src
app_src.depends = quazip-lib


SUBDIRS = quazip_lib app_src src/dbus


ICONPATH = /usr/share/icons/hicolor

108.png.path = $${ICONPATH}/108x108/apps/
108.png.files += data/108x108/harbour-good.png

128.png.path = $${ICONPATH}/128x128/apps/
128.png.files += data/128x128/harbour-good.png

INSTALLS += 108.png 128.png

OTHER_FILES += data/108x108/harbour-good.png \
               data/128x128/harbour-good.png
