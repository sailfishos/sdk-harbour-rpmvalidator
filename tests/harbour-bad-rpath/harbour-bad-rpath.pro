CONFIG += sailfishapp

OTHER_FILES += rpm/harbour-bad-rpath.spec \
               harbour-rpath-bad.desktop

TEMPLATE = subdirs

quazip_lib.file = harbour-bad-rpath-quazip/harbour-bad-rpath-quazip.pro
quazip_lib.target = quazip-lib

app_src.subdir = src
app_src.target = app-src
app_src.depends = quazip-lib


SUBDIRS = quazip_lib app_src
