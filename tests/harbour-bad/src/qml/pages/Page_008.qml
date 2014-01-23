import QtQuick 2.0
import Sailfish.Silica 1.0

import "qmlmodules"
import "qmlmodules" // some comment
import "qmlmodules" /* some other comment */

import    "qmlmodules"       //        some        comment
import   "qmlmodules"   /*  some  other   comment   */

import "qmlmodules" as Foo
import "qmlmodules" as Bar // some comment
import "qmlmodules" as FooBar /* some other comment */

import    "qmlmodules"  as Fo     //        some        comment
import   "qmlmodules"   as Ba   /*  some  other   comment   */

   import "qmlmodules"
       import "qmlmodules" // some comment
  import "qmlmodules" /* some other comment */

   import    "qmlmodules"       //        some        comment
import   "qmlmodules"   /*  some  other   comment   */

         import "qmlmodules" as Foo
  import "qmlmodules" as Bar // some comment
        import "qmlmodules" as FooBar /* some other comment */

   import    "qmlmodules"  as Fo     //        some        comment
                    import   "qmlmodules"   as Ba   /*  some  other   comment   */


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
                title: "008"
            }
            Label {
                x: Theme.paddingLarge
                width: parent.width
                wrapMode: TextEdit.WordWrap
                text: "Hello Sailor, the rectangle below are from subfolder qmlmodules"
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }
            RedRectangle {}
            Foo.RedRectangle {}
            Bar.RedRectangle {}
            FooBar.RedRectangle  {}
            Fo.RedRectangle {}
            Ba.RedRectangle {}
        }
    }
}
