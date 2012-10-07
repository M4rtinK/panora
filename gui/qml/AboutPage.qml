//AboutPage.qml
import QtQuick 1.1
import com.nokia.meego 1.0

Page {
    id: aboutPage
        anchors.fill : parent
        anchors.topMargin : 8
        anchors.bottomMargin : 8
        anchors.leftMargin : 8
        anchors.rightMargin : 8

        ScrollDecorator {
             flickableItem : aboutFlickable
        }

        tools: ToolBarLayout {
            ToolIcon {
                iconId: "toolbar-back"
                onClicked: pageStack.pop()
            }
        }

        Flickable {
            id : aboutFlickable
            anchors.fill  : parent
            contentWidth  : aboutPage.width
            contentHeight : aboutColumn.height + 30
            flickableDirection : Flickable.VerticalFlick

            Item {
                //anchors.horizontalCenter : parent.horizontalCenter
                width : aboutPage.width
                height : childrenRect.height
                id : aboutColumn
                Label {
                    id : versionLabel
                    anchors.top : parent.top
                    anchors.horizontalCenter : parent.horizontalCenter
                    text : "<h2>Panora " + panora.getVersionString() + "</h2>"
                }
                Image {
                    id : mieruIcon
                    anchors.top : versionLabel.bottom
                    anchors.topMargin : 5
                    anchors.horizontalCenter : parent.horizontalCenter
                    source : "image://icons/panora.svg"
                }
                Label {
                    id : mieruDescription
                    anchors.top : mieruIcon.bottom
                    anchors.topMargin : 8
                    anchors.horizontalCenter : parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    width : parent.width
                    wrapMode : Text.WordWrap
                    text : qsTr("Panora helps to capture photos for further panorama processing.")
                }
                Label {
                    id : donateLabel
                    anchors.top : mieruDescription.bottom
                    anchors.topMargin : 25
                    anchors.horizontalCenter : parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    width : parent.width
                    wrapMode : Text.WordWrap
                    text : qsTr("<b>Do you like Panora ? Donate !</b>")
                }
                Row {
                    id : ppFlattrRow
                    anchors.top : donateLabel.bottom
                    anchors.horizontalCenter : parent.horizontalCenter
                    anchors.topMargin : 24
                    spacing : 32
                    PayPalButton {
                        id : ppButton
                        anchors.verticalCenter : parent.verticalCenter
                        url : "https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=martin%2ekolman%40gmail%2ecom&lc=GB&item_name=Mieru%20project&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_LG%2egif%3aNonHosted"
                    }

                    FlattrButton {
                        id : flattrButton
                        anchors.verticalCenter : parent.verticalCenter
                        url : "http://flattr.com/thing/830372/Mieru-flexible-manga-and-comic-book-reader"
                    }
                }

                BitcoinButton {
                    id : bitcoinButton
                    anchors.top : ppFlattrRow.bottom
                    anchors.topMargin : 24
                    anchors.horizontalCenter : parent.horizontalCenter
                    url : "1Aajmyd6CgJRwr1xNWhMA4W3UThzvBoMfj"
                }
                Column {
                    anchors.top : bitcoinButton.bottom
                    anchors.topMargin : 25
                    spacing : 5
                    Label {
                        text : "<b>" + qsTr("main developer") + ":</b> Martin Kolman"
                    }
                    Label {
                        text : "<b>" + qsTr("email") + ":</b> <a href='mailto:panora.info@gmail.com'>panora.info@gmail.com</a>"
                        onLinkActivated : Qt.openUrlExternally(link)
                    }
                    Label {
                        text : "<b>" + qsTr("www") + ":</b> <a href='http://m4rtink.github.com/mieru/'>http://m4rtink.github.com/panora/</a>"
                        onLinkActivated : Qt.openUrlExternally(link)
                    }
                    /*
                    Label {
                        width : aboutPage.width
                        text  : "<b>" + qsTr("discussion") + ":</b> " + "<a href='http://forum.meego.com/showthread.php?t=5405'>forum.meego.com</a>"
                        onLinkActivated : Qt.openUrlExternally(link)
                    }
                    */
                }
            }
        }
        ScrollDecorator {
            flickableItem: aboutFlickable
        }
}