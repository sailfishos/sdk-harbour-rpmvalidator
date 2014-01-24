/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Andrew den Exter <andrew.den.exter@jollamobile.com>
** All rights reserved.
**
** You may use this file under the terms of the GNU Lesser General
** Public License version 2.1 as published by the Free Software Foundation
** and appearing in the file license.lgpl included in the packaging
** of this file.
**
** This library is free software; you can redistribute it and/or
** modify it under the terms of the GNU Lesser General Public
** License version 2.1 as published by the Free Software Foundation
** and appearing in the file license.lgpl included in the packaging
** of this file.
** 
** This library is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
** Lesser General Public License for more details.
** 
****************************************************************************************/

#ifndef DECLARATIVEDBUSADAPTOR_H
#define DECLARATIVEDBUSADAPTOR_H

#include <QObject>
#if QT_VERSION_5
# include <QtQml>
# include <QQmlParserStatus>
# define QDeclarativeParserStatus QQmlParserStatus
#else
# include <QDeclarativeParserStatus>
#endif

#include <QDBusVirtualObject>

QT_BEGIN_NAMESPACE
class QUrl;
#if QT_VERSION >= QT_VERSION_CHECK(5, 0, 0)
class QJSValue;
#define QScriptValue QJSValue
#define QDeclarativeParserStatus QQmlParserStatus
#else
class QScriptValue;
#endif
QT_END_NAMESPACE

class DeclarativeDBusAdaptor : public QDBusVirtualObject, public QDeclarativeParserStatus
{
    Q_OBJECT
    Q_PROPERTY(QString service READ service WRITE setService NOTIFY serviceChanged)
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)
    Q_PROPERTY(QString iface READ interface WRITE setInterface NOTIFY interfaceChanged)
    Q_PROPERTY(QString xml READ xml WRITE setXml NOTIFY xmlChanged)
    Q_PROPERTY(BusType busType READ busType WRITE setBusType NOTIFY busTypeChanged)

    Q_INTERFACES(QDeclarativeParserStatus)
    Q_ENUMS(BusType)

public:
    DeclarativeDBusAdaptor(QObject *parent = 0);
    ~DeclarativeDBusAdaptor();

    QString service() const;
    void setService(const QString &service);

    QString path() const;
    void setPath(const QString &path);

    QString interface() const;
    void setInterface(const QString &interface);

    QString xml() const;
    void setXml(const QString &xml);

    enum BusType {
        SystemBus,
        SessionBus
    };

    BusType busType() const;
    void setBusType(BusType busType);

    void classBegin();
    void componentComplete();

    QString introspect(const QString &path) const;
    bool handleMessage(const QDBusMessage &message, const QDBusConnection &connection);

    Q_INVOKABLE void emitSignal(const QString &name);
    Q_INVOKABLE void emitSignalWithArguments(const QString &name, const QScriptValue &arguments);

signals:
    void serviceChanged();
    void pathChanged();
    void interfaceChanged();
    void xmlChanged();
    void busTypeChanged();

private:
    QString m_service;
    QString m_path;
    QString m_interface;
    QString m_xml;
    BusType m_busType;
};

#endif
