/* such comments... */
import QtQuick 2.0 /* such comments... */
import Sailfish.Silica 1.0 /* such comments... */
import harbour.good.dbus 1.0 /* such comments... */

import       QtQuick        2.0 /* such comments... */
        import                 QtQuick            2.0   /* such comments... */
import        harbour.good.dbus       1.0 /* such comments... */
        import        harbour.good.dbus       1.0   /* such comments... */


import QtQuick 2.0 as Foo /* such comments... */
import harbour.good.dbus 1.0 as Bar /* such comments... */
import     QtQuick      2.0    as     Foo /* such comments... */
import     harbour.good.dbus    1.0  as     Bar /* such comments... */

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
                title: "004"
            }
            Label {
                x: Theme.paddingLarge
                width: parent.width
                wrapMode: TextEdit.WordWrap
                text: "Hello Sailor, this page has some /* such comments... */..."
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }
        }
    }
}
