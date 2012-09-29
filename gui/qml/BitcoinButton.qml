//BitcoinButton.qml

import QtQuick 1.1
import com.nokia.meego 1.0

Rectangle {
    id : bitcoinButton
    color : bitcoinMA.pressed ? "silver" : "black"
    border.width : showBorder ? 2 : 0
    border.color : "white"
    smooth : true
    radius : 25
    width : 210
    height : 50
    property string url : ""
    property bool showBorder : false


    Label {
        anchors.horizontalCenter : parent.horizontalCenter
        anchors.verticalCenter : parent.verticalCenter
        font.family: "Arial"
        font.pixelSize : 24
        text : "<h3>Bitcoin</h3>"
        color : bitcoinMA.pressed ? "black" : "white"
    }
    MouseArea {
        id : bitcoinMA
        anchors.fill : parent
        onClicked : {
            console.log('Bitcoin button clicked')
            bitcoinDialog.open()
        }
    }
    Dialog {
        id : bitcoinDialog
        width : parent.width - 30
        property Style platformStyle : SelectionDialogStyle {}
        property string titleText : qsTr("Bitcoin address")
        title: Item {
            id: header
            height: bitcoinDialog.platformStyle.titleBarHeight
            anchors.left : parent.left
            anchors.right : parent.right
            anchors.top : parent.top
            anchors.bottom : parent.bottom
            Item {
                id: labelField
                anchors.fill:  parent
                Item {
                    id: labelWrapper
                    anchors.left : parent.left
                    anchors.right : closeButton.left
                    anchors.bottom :  parent.bottom
                    anchors.bottomMargin : bitcoinDialog.platformStyle.titleBarLineMargin
                    height : titleLabel.height
                    Label {
                        id: titleLabel
                        x: bitcoinDialog.platformStyle.titleBarIndent
                        width : parent.width - closeButton.width
                        font : bitcoinDialog.platformStyle.titleBarFont
                        color : bitcoinDialog.platformStyle.commonLabelColor
                        elide : bitcoinDialog.platformStyle.titleElideMode
                        text : bitcoinDialog.titleText
                    }

                }
                Image {
                    id: closeButton
                    anchors.verticalCenter : labelWrapper.verticalCenter
                    anchors.right : labelField.right
                    opacity : closeButtonArea.pressed ? 0.5 : 1.0
                    source : "image://theme/icon-m-common-dialog-close"
                    MouseArea {
                        id : closeButtonArea
                        anchors.fill : parent
                        onClicked : bitcoinDialog.reject()
                    }
                }
            }
            Rectangle {
                id: headerLine
                anchors.left : parent.left
                anchors.right : parent.right
                anchors.bottom :  header.bottom
                height : 1
                color : "#4D4D4D"
            }
        }
        content:Item {
            id: dialogContent
            width : parent.width
            height : bitcoinQrCode.height + urlField.height + 32
            Image {
                id : bitcoinQrCode
                anchors.top : dialogContent.top
                anchors.topMargin : 8
                anchors.horizontalCenter : parent.horizontalCenter
                source : "image://icons/qrcode_bitcoin.png"
            }
            TextField {
                id : urlField
                anchors.top : bitcoinQrCode.bottom
                anchors.topMargin : 8
                anchors.left : parent.left
                anchors.right : parent.right
                //anchors.horizontalCenter : parent.horizontalCenter
                font.pointSize : 20
                height : 48
                text : bitcoinButton.url
            }
            Button {
                anchors.top : urlField.bottom
                anchors.topMargin : 12
                anchors.horizontalCenter : parent.horizontalCenter
                text: qsTr("Copy address")
                iconSource : "image://theme/icon-m-toolbar-cut-paste"
                onClicked: {
                    urlField.selectAll()
                    urlField.copy()
                    rootWindow.notify(qsTr("Bitcoin address copied to clipboard"))
                }
            }
        }
    }
}


