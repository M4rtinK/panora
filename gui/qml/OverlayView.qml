//MainView.qml
//import Qt 4.7
import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import QtMultimediaKit 1.1

Page {
    id : oView
    //orientationLock: PageOrientation.LockLandscape
    objectName : "oView"
    anchors.fill : parent
    tools : mainViewToolBar

    property bool shutterVisible : false
    property real overlayOpacity : 0.7
    property int overlayRotation : 0
    property real screenWidth : rootWindow.inPortrait ? rootWindow.height : rootWindow.width

    // timers
    property int timedCaptureCount : 0
    property int timedCaptureInterval : 10
    property int sElapsed : 0
    property bool timersEnabled : false




    Connections {
        target : platformWindow
        onActiveChanged : {
            camera.visible = platformWindow.active
        }
    }

    // workaround for calling python properties causing segfaults
    function shutdown() {
        //console.log("main view shutting down")
    }

    function notify(text) {
        // send notifications
        notification.text = text;
        notification.show();
    }

    function toggleFullscreen() {
        /* handle fullscreen button hiding,
        it should be only visible with no toolbar */
        fullscreenButton.visible = !fullscreenButton.visible
        rootWindow.showToolBar = !rootWindow.showToolBar;
        options.set("QMLToolbarState", rootWindow.showToolBar)
    }

    // restore possible saved rotation lock value
    function restoreRotation() {
        var savedRotation = options.get("QMLMainViewRotation", "auto")
        if ( savedRotation == "auto" ) {
            oView.orientationLock = PageOrientation.Automatic
        } else if ( savedRotation == "portrait" ) {
            oView.orientationLock = PageOrientation.LockPortrait
        } else {
            oView.orientationLock = PageOrientation.LockLandscape
        }
    }

    function startTimedCapture(interval) {
        timedCaptureInterval = interval
        options.set("timedCaptureInterval", interval)
        state = "timedImageCapture"
    }

    function stopTimedCapture() {
        state = "imageCapture"
    }


    Component.onCompleted : {
      restoreRotation()
    }

    state : "noImage"

    states: [
        State {
            name : "noImage"
            StateChangeScript {
                script : {
                    shutterVisible = true
                    camera.visible = true
                    timersEnabled = false
                    timedB.visible = false
                }
            }
        },
        State {
            name : "imageCapture"
            StateChangeScript {
                script : {
                    shutterVisible = true
                    camera.visible = true
                    timersEnabled = false
                    timedB.visible = true
                }
            }
        },
        State {
            name : "timedImageCapture"
            StateChangeScript {
                script : {
                    shutterVisible = false
                    camera.visible = true
                    timersEnabled = true
                    timedB.visible = true
                }
            }
        }
    ]

    onStateChanged : {
        console.log(state)
    }

    Rectangle {
        anchors.fill : parent
        color : "black"
    }

    Camera {
        id: camera
        //x: 0
        y: 0
        rotation: screen.currentOrientation == 1 ? 90 :0
        //anchors.fill:parent
        //captureResolution: "1200x675"
        captureResolution: "1152x648"
        //captureResolution: "1000x480"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        //width: parent.height // - stillControls.buttonsPanelWidth
        //height: parent.width
        focus: visible //to receive focus and capture key events
        whiteBalanceMode: Camera.WhiteBalanceAuto
        exposureCompensation: -1.0
        state: Camera.ActiveState

        //captureResolution : "640x480"

        //flashMode: stillControls.flashMode
        //whiteBalanceMode: stillControls.whiteBalance
        //exposureCompensation: stillControls.exposureCompensation

        onImageCaptured : {
            console.log("image captured")
            lastImage.rotation = screen.currentOrientation == 1 ? 90 :0
            lastImage.source = preview
        }

        onImageSaved : {
            rootWindow.storeImage(capturedImagePath)
            //captureList.append({"path":storagePath})
            console.log("image saved to file")
        }
    }

    /** Image overlay **/

    Image {
        visible : true
        id : lastImage
        rotation : overlayRotation
        anchors.top : camera.top
        anchors.bottom : camera.bottom
        x : -screenWidth/2.0
        fillMode : Image.PreserveAspectFit
        opacity : overlayOpacity
        smooth : true
        sourceSize.width : 854
        sourceSize.height : 480
    }

    // clear lastImage when new project is opened
    Connections {
        target : rootWindow
        onProjectNameChanged : {
            lastImage.source = ""
        }
    }

    /** Toolbar **/

    ToolBarLayout {
        id : mainViewToolBar
        visible: false
        ToolIcon {
            iconId: ""
        }
        ToolIcon {
            iconId : "toolbar-settings"
            onClicked : { overlayMenu.open() }
        }
        ToolIcon {
            id : backTI
            iconId: "toolbar-view-menu"
            onClicked: {
                if (platform.showQuitButton()) {
                    mainViewMenuWithQuit.open()
                } else {
                    mainViewMenu.open()
                }
            }
        }

    }

    /** Main menu **/

    MainMenu {
        id : mainViewMenu
    }

    /** Camera buttons **/
    Button { // landscape shutter
        id : shutterL
        width : 160
        height : 100
        visible : shutterVisible && screen.currentOrientation != 1
        anchors.verticalCenter : parent.verticalCenter
        anchors.right : parent.right
        anchors.rightMargin : 16
        opacity : 0.7
        iconSource : "image://theme/icon-m-content-camera"
        onClicked : {
            console.log("shutter pressed")
            camera.captureImage()
        }
    }

    Button { // portrait shutter
        id : shutterP
        width : 160
        height : 100
        visible : shutterVisible && screen.currentOrientation == 1
        anchors.horizontalCenter : parent.horizontalCenter
        anchors.bottom : parent.bottom
        anchors.bottomMargin : 16

        opacity : 0.7
        iconSource : "image://theme/icon-m-content-camera"
        onClicked : {
            console.log("shutter pressed")
            camera.captureImage()
        }
    }

    Button {
        id : timedB
        width : 80
        height : 80
        anchors.top : parent.top
        anchors.right : parent.right
        anchors.topMargin : 16
        anchors.rightMargin : 32
        opacity : 0.7
        iconSource : "image://theme/icon-m-common-clock"
        checked : timersEnabled
        onClicked : {
            console.log("timed pressed")
            if (checked) {
                stopTimedCapture()
            } else {
                timingMenu.open()
            }
        }
    }

    /** No previous photo label **/

    Label {
        anchors.centerIn : parent
        text : qsTr("<h2>No previous photo</h2>")
        color: "white"
        visible : lastImage.source == ""
    }


    /** Timed capture label **/

    Label {
        anchors.centerIn : parent
        text : sElapsed == 0 && timedCaptureCount>0 ? qsTr("Taking picture") : + (timedCaptureInterval-sElapsed) +qsTr(" s to next capture")
        color: "white"
        visible : timersEnabled
        font.pixelSize : 32
    }

    Label {
        anchors.horizontalCenter : parent.horizontalCenter
        anchors.bottom : parent.bottom
        anchors.bottomMargin : 16
        text : timedCaptureCount==0 ? "" : + timedCaptureCount + " images captured"
        color: "white"
        visible : timersEnabled
        font.pixelSize : 32
    }


    /** Capture paused indicator **/
    Rectangle {
        anchors.fill : parent
        visible : !platformWindow.active
        color : "grey"
        Label {
            text : "<h1>Camera paused</h1>"
            color : "white"
            anchors.centerIn : parent
        }

    }

    Timer {
        // update timed capture status
        id : tickTimer
        interval : 1000
        repeat : true
        running : timersEnabled
        onTriggered : {
            var elapsed = sElapsed + 1
            sElapsed = sElapsed + 1
            if (sElapsed == timedCaptureInterval) {
                sElapsed = 0
                timedCaptureCount = timedCaptureCount + 1
                camera.captureImage()
            } else {
                sElapsed = elapsed
            }
        }
    }

    /*
    Timer {
        // capture image in a given interval
        id : captureTimer
        interval : timedCaptureInterval * 1000
        repeat : true
        running : timersEnabled
        onTriggered : {
            sElapsed = 0
            console.log("captureTimer triggered")
        }
    }*/

}