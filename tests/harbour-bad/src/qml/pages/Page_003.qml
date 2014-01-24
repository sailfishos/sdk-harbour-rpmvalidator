// have some comments...
import QtQuick 2.0 // some comment
import Sailfish.Silica 1.0 // some comment
import harbour.good.dbus 1.0 // some comment


import       QtQuick        2.0 // some comment
        import                 QtQuick            2.0 // some comment
import        harbour.good.dbus       1.0 // some comment
        import        harbour.good.dbus       1.0 // some comment

import QtQuick 2.0 as Foo // some comment
import harbour.good.dbus 1.0 as Bar // some comment
import     QtQuick      2.0    as     Foo // some comment
import     harbour.good.dbus    1.0  as     Bar // some comment




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
                title: "003"
            }
            Label {
                x: Theme.paddingLarge
                width: parent.width
                wrapMode: TextEdit.WordWrap
                text: "Hello Sailor, this page has // comments in the imports lines..."
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }
        }
    }
}
