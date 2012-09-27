"""
Panora Harmattan UI (for Maemo 5@N900)
"""

from base_platform import BasePlatform

class Harmattan(BasePlatform):
  def __init__(self, panora):
    BasePlatform.__init__(self)
    self.panora = panora

  def getIDString(self):
    return "harmattan"

  def notify(self, message, icon=""):
    self.panora.gui._notify(message, icon)

  def getDefaultFileSelectorPath(self):
    """we default to the MyDocs folder as this is where most
    users will store their mangas and comic books"""
    return "/home/user/MyDocs/"

  def showQuitButton(self):
    """Swype handles window closing"""
    return False

  def showMinimiseButton(self):
    """Swype handles window switching"""
    return False