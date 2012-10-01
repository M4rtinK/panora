//MainView.qml
//import Qt 4.7
import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import QtMultimediaKit 1.1

Page {
    id : emptyView
    objectName : "emptyView"
    anchors.fill : parent
    tools : mainViewToolBar

    /** Toolbar **/

    ToolBarLayout {
        id : mainViewToolBar
        visible: false
        ToolIcon {
            iconId: ""
        }
        ToolIcon {
            id : backTI
            iconId: "toolbar-view-menu"
            onClicked: {
                mainViewMenu.open()
            }
        }
    }

    /** Main menu **/

    MainMenu {
        id : mainViewMenu
    }


    /*
    Component.onCompleted : {
        mainViewMenu.open()
    }
    */

    /** No pages loaded label **/

    Label {
        anchors.centerIn : parent
        text : qsTr("<h2>No Project selected</h2>")
        color: "black"
        visible : true
    }
}