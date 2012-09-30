"""this is a "abstract" class defining the API for platform modules
   NOTE: this is not just API, some multiplatform implementations are there too
"""

#import gtk
#import paging_dialog
import os

class BasePlatform:
  def __init__(self):
    pass

  def getIDString(self):
    """
    get a unique string identifier for a platform module
    """
    return None

  def hasPagingKeys(self):
    """report if the device has has some buttons usable for paging"""
    return False

  def startChooser(self, type):
    """start a file/folder chooser dialog"""
    pass

  def handleKeyPress(self, keyName):
    """handle a key press event and return True if the key was "consumed" or
    "False" if it wasn't"""
    return False

  def notify(self, message, icon):
    """show a notification, if possible"""
    pass

  def minimize(self):
    """minimize the main window"""
    pass

  def showMinimiseButton(self):
    """
    report if a window minimise button needs to be shown somewhere in the
     application managed UI
    """
    return True

  def showQuitButton(self):
    """
    report if a quit button needs to be shown somewhere in the
     application managed UI
    """
    return True

  def getDefaultFileSelectorPath(self):
    """a fail-safe path for the file/folder selector on its first opening"""
    return '/'

  def getDefaultPhotoStoragePath(self):
    """use the home directory of the current user to store images by default"""
    return os.getenv("HOME")