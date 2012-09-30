//ProjectDialog.qml

import QtQuick 1.1
import com.nokia.meego 1.0

HeaderDialog {
    id : projectNameDialog
    titleText : qsTr("Enter project name")
    content : Item {
        id : mLayout
        width : parent.width
        height : nameField.height + pButtonRow.height + 32
        property int usableWidth : width - 16
        TextField {
            id : nameField
            anchors.top : parent.top
            anchors.topMargin : 16
            anchors.left : parent.left
            anchors.right : parent.right
            anchors.leftMargin : 0
            anchors.rightMargin : 0
            font.pointSize : 24
            text : panora.getProjectName()
        }
        Row {
            anchors.top : nameField.bottom
            anchors.topMargin : 16
            id : pButtonRow
            property int usableWidth : mLayout.width - 10
            spacing : 10
            Button {
                id : screenRLock
                text : qsTr("Paste")
                iconSource : "image://theme/icon-m-toolbar-cut-paste"
                width : pButtonRow.usableWidth/2.0

                onClicked: {
                    urlField.paste()
                }
            }

            Button {
                id : imageRotationB
                text : "Done"
                enabled : nameField.text != ""
                iconSource : "image://theme/icon-m-toolbar-done"
                width : pButtonRow.usableWidth/2.0
                onClicked: {
                    // notify the rootWindow
                    rootWindow.newProjectStarted(nameField.text)
                    close()
                    //TODO: select project type
                    rootWindow.pageStack.push(oView)
                }
            }
        }
    }
}