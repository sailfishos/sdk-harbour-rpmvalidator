import QtQuick 2.0
import Sailfish.Silica 1.0

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
                title: "010"
            }
            Label {
                x: Theme.paddingLarge
                width: parent.width
                wrapMode: TextEdit.WordWrap
                text: "Hello Sailor"
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }
        }
    }
}
