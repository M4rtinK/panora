import Qt 4.7
import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0

PageStackWindow {
    showStatusBar : options.get("QMLShowStatusBar", false)
    showToolBar : true
    id : rootWindow
    anchors.fill : parent
    initialPage : EmptyView {
        id : eView
    }

    property int statusBarHeight : 36

    /* TODO: replace hardcoded value
    with actual status bar height */

    property string projectName
    property int imageCounter : 1

    // ** Open a page and push it in the stack
    function openFile(file) {
        // Create the Qt component based on the file/qml page to load.
        var component = Qt.createComponent(file)
        // If the page is ready to be managed it is pushed onto the stack
        if (component.status == Component.Ready)
            pageStack.push(component);
        else
            console.log("Error loading: " + component.errorString());
    }

    // handle Panora shutdown
    function shutdown() {
        oView.shutdown()
    }

    // open dialog with information about how to use Panora
    function openFirstStartDialog() {
        firstStartDialog.open()
    }

    function openImageFile(path) {
        prepareForNewImage()
        panora.fileOpened(path)
        lastImageURL = path
    }

    function prepareForNewImage() {
        // reset capture list
        lastImageURL=""
        captureList.clear()
        comparisonPage.index = -1
    }

    function newProjectStarted(newProjectName) {
        // should be called every time a new
        // project is started

        //save the new project name
        options.set('projectName', newProjectName)

        projectName = newProjectName
        imageCounter=1
    }

    function storeImage(capturedImageUrl) {
        // save the image to storage
        var storagePath
        storagePath = panora.storeImage(capturedImageUrl, projectName, imageCounter)
        // increment the counter
        imageCounter = imageCounter + 1
        return storagePath
    }

    function openUrl(url) {
        prepareForNewImage()
        // store url downloads in pictures by default
        panora.urlOpened(url)
        lastImageURL = url
    }

    FileSelector {
        id: fileSelector;
        //anchors.fill : rootWindow
        onAccepted: {
            console.log("File selector accepted")
            openImageFile(selectedFile)
        }
    }

    /** Gallery selection dialog **/


    //GalleryPage {
    //    id : galleryPage
    //}

    /** Overlay menu **/
    OverlayMenu {
        id : overlayMenu
    }

    /** Timing menu **/
    TimingMenu {
        id : timingMenu
    }

    ListModel {
        id : captureList
    }


    OverlayView {
        id : oView
    }

    // ** trigger notifications
    function notify(text) {
        notification.text = text;
        notification.show();
    }

    InfoBanner {
        id: notification
        timerShowTime : 5000
        height : rootWindow.height/5.0
        // prevent overlapping with status bar
        y : rootWindow.showStatusBar ? rootWindow.statusBarHeight + 8 : 8
    }

    QueryDialog {
        id : firstStartDialog
        icon : "image://icons/panora.svg"
        titleText : "How to use Panora"
        message : "Select a project name and start taking pictures with the hints provided by Panora.<br>Once you are finished, process the pictures with panorama processing software, such as <b>Hugin</b>."
        acceptButtonText : qsTr("Don't show again")
        rejectButtonText : qsTr("OK")
        onAccepted: {
            options.set("QMLShowFirstStartDialog", false)
        }
    }

    ProjectDialog {
        id : projectDialog
    }
}