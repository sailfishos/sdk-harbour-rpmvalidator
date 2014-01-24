// import 'as'
import QtQuick 2.0 as Foo
import harbour.good.dbus 1.0 as Bar

import     QtQuick      2.0    as     FooBar
import     harbour.good.dbus    1.0  as     BarFoo

import QtQuick 2.0
import Sailfish.Silica 1.0


// with tabs be careful when saved with Qt Creator
    import 	QtQuick 2.0		 as	 Foo
import 			harbour.good.dbus		 1.0 	  as  	 	Bar

import		QtQuick  	 	 	  2.0 			   as 			    FooBar
  import  	   harbour.good.dbus	1.0	as     BarFoo

		import QtQuick 2.0
  import Sailfish.Silica		 1.0				// some comment

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
                title: "002"
            }
            Label {
                x: Theme.paddingLarge
                width: parent.width
                wrapMode: TextEdit.WordWrap
                text: "Hello Sailor, this has some 'as Foo' imports"
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }
        }
    }
}
