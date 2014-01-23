/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


// see: http://qt-project.org/doc/qt-5.0/qtqml/qtqml-syntax-imports.html

// normal imports
import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.good.dbus 1.0
import org.nemomobile.social 1.0

// import "qrc:///../test/home" as FooBar

Page {
    id: page
    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: "UI Template"
            }
            Button {
                text: "Page 001"
                anchors.left: parent.left
                anchors.right: parent.right
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Page_001.qml"))
                }
            }
            Button {
                text: "Page 002"
                anchors.left: parent.left
                anchors.right: parent.right
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Page_002.qml"))
                }
            }
            Button {
                text: "Page 003"
                anchors.left: parent.left
                anchors.right: parent.right
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Page_003.qml"))
                }
            }
            Button {
                text: "Page 004"
                anchors.left: parent.left
                anchors.right: parent.right
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Page_004.qml"))
                }
            }
            Button {
                text: "Page 005"
                anchors.left: parent.left
                anchors.right: parent.right
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Page_005.qml"))
                }
            }
            Button {
                text: "Page 006"
                anchors.left: parent.left
                anchors.right: parent.right
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Page_006.qml"))
                }
            }
            Button {
                text: "Page 007"
                anchors.left: parent.left
                anchors.right: parent.right
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Page_007.qml"))
                }
            }
            Button {
                text: "Page 008"
                anchors.left: parent.left
                anchors.right: parent.right
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Page_008.qml"))
                }
            }
            Button {
                text: "Page 009"
                anchors.left: parent.left
                anchors.right: parent.right
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Page_009.qml"))
                }
            }
            Button {
                text: "Page 010"
                anchors.left: parent.left
                anchors.right: parent.right
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Page_010.qml"))
                }
            }
            Button {
                text: "Page 001 QRC"
                anchors.left: parent.left
                anchors.right: parent.right
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("qrc:///qrc-files/Page_001_qrc.qml"))
                }
            }
        }
    }
}
