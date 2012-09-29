"""a QML GUI module for Panora"""
import glob
import shutil

import sys
import re
import os
from PySide import QtCore, QtOpenGL
import urllib
from PySide.QtCore import *
from PySide.QtGui import *
from PySide.QtDeclarative import *
#from PySide import QtOpenGL
import datetime
import time

import gui
import info

def newlines2brs(text):
  """ QML uses <br> instead of \n for linebreak """
  return re.sub('\n', '<br>', text)

class QMLGUI(gui.GUI):
  def __init__(self, panora, type, size=(854,480)):
    self.panora = panora

    self.activePage = None

    # Create Qt application and the QDeclarative view
    class ModifiedQDeclarativeView(QDeclarativeView):
      def __init__(self, gui):
        QDeclarativeView.__init__(self)
        self.gui = gui
        
      def closeEvent(self, event):
        print "shutting down"
        self.gui.panora.destroy()

    self.app = QApplication(sys.argv)
    self.view = ModifiedQDeclarativeView(self)
    # try OpenGl acceleration
    glw = QtOpenGL.QGLWidget()
    self.view.setViewport(glw)
    self.window = QMainWindow()
    self.window.resize(*size)
    self.window.setCentralWidget(self.view)
    self.view.setResizeMode(QDeclarativeView.SizeRootObjectToView)

    # add image providers
#    self.pageProvider = MangaPageImageProvider(self)
    self.iconProvider = IconImageProvider()
#    self.view.engine().addImageProvider("page",self.pageProvider)
    self.view.engine().addImageProvider("icons",self.iconProvider)
    rc = self.view.rootContext()
    # make the main context accessible from QML
    rc.setContextProperty("panora", Panora(self))
    # make options accessible from QML
    options = Options(self.panora)
    rc.setContextProperty("options", options)
    # make platform module accessible from QML
    platform = Platform(self.panora)
    rc.setContextProperty("platform", platform)

    # activate translation
    translator = QtCore.QTranslator(self.app)
    
    if self.mieru.args.locale is not None:
      localeId = self.mieru.args.locale
    else:
      localeId = locale.getlocale()[0]
    translator.load("gui/qml/i18n/qml_" + localeId)
    self.app.installTranslator(translator)
    
    # Set the QML file and show
    self.view.setSource(QUrl('gui/qml/main.qml'))
    self.view.show()
    self.window.closeEvent = self._qtWindowClosed

    self.rootObject = self.view.rootObject()

    self.toggleFullscreen()

    # check if first start dialog has to be shown
    if self.panora.get("QMLShowFirstStartDialog", True):
      self.rootObject.openFirstStartDialog()

  def getToolkit(self):
    return "QML"

  def toggleFullscreen(self):
    if self.window.isFullScreen():
      self.window.showNormal()
    else:
      self.window.showFullScreen()

  def startMainLoop(self):
    """start the Qt main loop"""
    self.view.showFullScreen()
    self.window.show()
    self.app.exec_()

  def _qtWindowClosed(self, event):
    print('qt window closing down')
    self.panora.destroy()

  def stopMainLoop(self):
    """stop the Qt main loop"""
    # notify QML GUI first
    """NOTE: due to calling Python properties
    from onDestruction handlers causing
    segfault, we need this"""
    self.rootObject.shutdown()

    # quit the application
    self.app.exit()

  def getWindow(self):
    return self.window

  def _notify(self, text, icon=""):
    """trigger a notification using the Qt Quick Components
    InfoBanner notification"""

    # QML uses <br> instead of \n for linebreak

    text = newlines2brs(text)
    self.rootObject.notify(text)

class PhotoProvider(QDeclarativeImageProvider):
  """the MangaPageImageProvider class provides manga pages to the QML layer"""
  def __init__(self, gui):
      QDeclarativeImageProvider.__init__(self, QDeclarativeImageProvider.ImageType.Image)
      self.gui = gui

  def requestImage(self, pathId, size, requestedSize):
    (path,id) = pathId.split('|',1)
    id = int(id) # string -> integer
    (page, id) = self.gui._getPageByPathId(path, id)
    imageFileObject = page.popImage()
    img=QImage()
    img.loadFromData(imageFileObject.read())

    return img

class IconImageProvider(QDeclarativeImageProvider):
  """the IconImageProvider class provides icon images to the QML layer as
  QML does not seem to handle .. in the url very well"""
  def __init__(self):
      QDeclarativeImageProvider.__init__(self, QDeclarativeImageProvider.ImageType.Image)

  def requestImage(self, iconFilename, size, requestedSize):
    print "IMAGE"
    print iconFilename
    try:
      f = open('icons/%s' % iconFilename,'r')
      img=QImage()
      img.loadFromData(f.read())
      f.close()
      return img
      #return img.scaled(requestedSize)
    except Exception, e:
      print("loading icon failed", e)

class Panora(QObject):
  def __init__(self, gui):
    QObject.__init__(self)
    self.gui = gui
    self.panora = gui.panora
    self.currentFolder = None
    self.oldImageFilename = None

  @QtCore.Slot(result=str)
  def getAboutText(self):
    return newlines2brs(info.getAboutText())

  @QtCore.Slot(result=str)
  def getVersionString(self):
    return newlines2brs(info.getVersionString())

  @QtCore.Slot(result=str)
  def toggleFullscreen(self):
    self.gui.toggleFullscreen()

  @QtCore.Slot(result=int)
  def getEpoch(self):
    return int(time.time())

  @QtCore.Slot(str)
  def fileOpened(self, path):
    # remove the "file:// part of the path"
    path = re.sub('file://', '', path, 1)
    folder = os.path.dirname(path)
    filename = os.path.basename(path)
    self.panora.set('lastChooserFolder', folder)
    #TODO: check if it is an image before saving
    self.panora.set('lastFile', path)
    self.currentFolder = folder
    self.oldImageFilename = filename

  @QtCore.Slot(str)
  def urlOpened(self, url):
    # remove the "file:// part of the path"
    folder = "/home/user/MyDocs/pictures"
    self.currentFolder = folder
    filename = os.path.basename(url)
    self.oldImageFilename = filename
    urllib.urlretrieve(url,os.path.join(folder, filename))

  @QtCore.Slot(result=str)
  def getSavedFileSelectorPath(self):
    defaultPath = self.panora.platform.getDefaultFileSelectorPath()
    lastFolder = self.panora.get('lastChooserFolder', defaultPath)
    return lastFolder

  @QtCore.Slot(str,result=str)
  def storeNewAsOld(self, capturedImagePath):
    """
    store an image captured by Panora
    as if it was a normally loaded "old" image

    * move it from the camera capture file
    * set paths as if it was loaded from a file/url/gallery
    """
    dateString = str(int(time.time()))
    filename = "rp" + dateString + ".jpg"
    self.oldImageFilename = filename
    folder = "/home/user/MyDocs/pictures"
    self.currentFolder = folder

    storagePath = os.path.join(folder,filename)
    shutil.move(capturedImagePath, storagePath)
    self.gui._notify("Saved as:<br><b>%s</b>" % storagePath)
    return storagePath

  @QtCore.Slot(str,result=str)
  def storeImage(self, capturedImagePath):
    today = datetime.date.today()

    # zero padding
    if today.day < 10:
      day = "0%d" % today.day
    else:
      day = "%s" % today.day

    if today.month < 10:
      month = "0%d" % today.month
    else:
      month = "%s" % today.month

    #TODO: zero padding for years




#    dateString = str(today.year) + month + day
    dateString = str(int(time.time()))
    newFilename = "%s_panora_%s.jpg" % (self.oldImageFilename, dateString)

#    list = glob.glob(os.path.join(self.currentFolder,"%s*" % newFilename))
#    print list
#    if list:
#
#      numericList = map(lambda x: (x.split(newFilename)[1]),list)
#      numericList = map(lambda x: int(x.split(newFilename)[1]),list)
#      print numericList
#      highestNumber = sorted(numericList)[-1]
#      newHighestNumber = highestNumber + 1
#    else:
#      newHighestNumber = 0
#
#    newFilename+= str(newHighestNumber).zfill(3)
#    newFilename+= ".jpg"

    savedImagePath = os.path.join(self.currentFolder, newFilename)


    shutil.move(capturedImagePath, savedImagePath)
    print savedImagePath
    self.gui._notify("Saved as:<br><b>%s</b>" % newFilename)
    return savedImagePath

  @QtCore.Slot(result=str)
  def getSavedFilePath(self):
    defaultPath = ""
    lastFilePath = self.panora.get('lastFile', defaultPath)
    return lastFilePath

  @QtCore.Slot(result=str)
  def getCurrentFileName(self):
    if self.oldImageFilename:
      return self.oldImageFilename
    else:
      return "image name unknown"

  @QtCore.Slot()
  def quit(self):
    """shut down panora"""
    self.gui.panora.destroy()


class Platform(QtCore.QObject):
  """make stats available to QML and integrable as a property"""
  def __init__(self, panora):
    QtCore.QObject.__init__(self)
    self.panora = panora

  @QtCore.Slot()
  def minimise(self):
    return self.panora.platform.minimise()

  @QtCore.Slot(result=bool)
  def showMinimiseButton(self):
    """
    Harmattan handles this by the Swype UI and
    on PC this should be handled by window decorator
    """
    return self.panora.platform.showMinimiseButton()

  @QtCore.Slot(result=bool)
  def showQuitButton(self):
    """
    Harmattan handles this by the Swype UI and
    on PC it is a custom to have the quit action in the main menu
    """
    return self.panora.platform.showQuitButton()

  @QtCore.Slot(result=bool)
  def incompleteTheme(self):
    """
    The theme is incomplete, use fail-safe or local icons.
    Hopefully, this can be removed once the themes are in better shape.
    """
    # the Fremantle theme is incomplete
    return self.panora.platform.getIDString() == "maemo5"

class Options(QtCore.QObject):
  """make options available to QML and integrable as a property"""
  def __init__(self, panora):
      QtCore.QObject.__init__(self)
      self.panora = panora

  """ like this, the function can accept
  and return different types to and from QML
  (basically anything that matches some of the decorators)
  as per PySide developers, there should be no perfromance
  penalty for doing this and the order of the decorators
  doesn't mater"""
  @QtCore.Slot(str, bool, result=bool)
  @QtCore.Slot(str, int, result=int)
  @QtCore.Slot(str, str, result=str)
  @QtCore.Slot(str, float, result=float)
  def get(self, key, default):
    """get a value from Panoras persistent options dictionary"""
    print "GET"
    print key, default, self.panora.get(key, default)
    return self.panora.get(key, default)


  @QtCore.Slot(str, bool)
  @QtCore.Slot(str, int)
  @QtCore.Slot(str, str)
  @QtCore.Slot(str, float)
  def set(self, key, value):
    """set a keys value in Panoras persistent options dictionary"""
    print "SET"
    print key, value
    return self.panora.set(key, value)

  # for old PySide versions that don't support multiple
  # function decorations

  @QtCore.Slot(str, bool, result=bool)
  def getB(self, key, default):
    print "GET"
    print key, default, self.panora.get(key, default)
    return self.panora.get(key, default)

  @QtCore.Slot(str, str, result=str)
  def getS(self, key, default):
    print "GET"
    print key, default, self.panora.get(key, default)
    return self.panora.get(key, default)

  @QtCore.Slot(str, int, result=int)
  def getI(self, key, default):
    print "GET"
    print key, default, self.panora.get(key, default)
    return self.panora.get(key, default)

  @QtCore.Slot(str, float, result=float)
  def getF(self, key, default):
    print "GET"
    print key, default, self.panora.get(key, default)
    return self.panora.get(key, default)

  @QtCore.Slot(str, bool)
  def setB(self, key, value):
    print "SET"
    print key, value
    return self.panora.set(key, value)

  @QtCore.Slot(str, str)
  def setS(self, key, value):
    print "SET"
    print key, value
    return self.panora.set(key, value)

  @QtCore.Slot(str, int)
  def setI(self, key, value):
    print "SET"
    print key, value
    return self.panora.set(key, value)

  @QtCore.Slot(str, float)
  def setF(self, key, value):
    print "SET"
    print key, value
    return self.panora.set(key, value)