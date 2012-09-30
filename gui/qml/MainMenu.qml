//MainMenu
import QtQuick 1.1
import com.nokia.meego 1.0

Menu {
    id : mainViewMenu
    MenuLayout {
        MenuItem {
            text : qsTr("Start new project")
            onClicked : {
            rootWindow.pageStack.push(oView)
            }
        }

        /**
        MenuItem {
            text : qsTr("Options")
            onClicked : {
                rootWindow.openFile("OptionsPage.qml")
            }
        }
        **/

        MenuItem {
            text : qsTr("About")
            onClicked : {
                rootWindow.openFile("AboutPage.qml")
            }
        }
    }
}