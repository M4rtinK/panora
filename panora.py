#!/usr/bin/env python
from __future__ import with_statement # for python 2.5
import subprocess
from gui import gui

import timer
import time
from threading import RLock

# Panora modules import
startTs = timer.start()
import options
import startup

timer.elapsed(startTs, "All modules combined")

# set current directory to the directory
# of this file
# like this, Panora can be run from absolute path
# eq.: ./opt/panora/panora.py -p harmattan -u harmattan
import os

abspath = os.path.abspath(__file__)
dName = os.path.dirname(abspath)
os.chdir(dName)

# append the platform modules folder to path
import sys

sys.path.append('platforms')

class Panora:
  def destroy(self):
    self.options.save()
    print("%s quiting" % self.getPrettyName() )
    self.gui.stopMainLoop()

  def __init__(self):
    # log start
    initTs = time.clock()
    self.startupTimeStamp = time.time()

    # parse startup arguments
    start = startup.Startup()
    args = start.args
    self.args = args

    # restore the persistent options dictionary
    self.d = {}
    self.options = options.Options(self)
    # options value watching
    self.maxWatchId = 0
    self.watches = {}

    initialSize = (854, 480)

    # get the platform module
    self.platform = None
    # get the platform ID string
    platformId = "harmattan" # safe fallback
    if args.p is None:
      import platform_detection
      # platform detection
      result = platform_detection.getBestPlatformModuleId()
      if result:
        platformId = result
    else: # use the CLI provided value
      platformId = args.p

    if platformId == "harmattan":
      import harmattan

      self.platform = harmattan.Harmattan(self)
    else:
      print("can't start: current platform unknown")
      sys.exit(1)

    # create the GUI
    startTs1 = timer.start()

    # Panora currently has only a single QML based GUI module
    self.gui = gui.getGui(self, 'QML', accel=True, size=initialSize)

    timer.elapsed(startTs1, "GUI module import")
    timer.elapsed(initTs, "Init")
    timer.elapsed(startTs, "Complete startup")

    # start the main loop
    self.gui.startMainLoop()

  def getWindow(self):
    return self.window

  def getName(self):
    return "panora"

  def getPrettyName(self):
    return "Panora"

  def getProfileFolderName(self):
    return ".%s" % self.getName()

  def notify(self, message, icon=""):
    print("notification: %s" % message)
    self.platform.notify(message, icon)

  ## ** persistent dictionary handling * ##

  def getDict(self):
    return self.d

  def setDict(self, d):
    self.d = d

  def watch(self, key, callback, *args):
    """add a callback on an options key"""
    id = self.maxWatchId + 1 # TODO remove watch based on id
    self.maxWatchId = id # TODO: recycle ids ? (alla PID)
    if key not in self.watches:
      self.watches[key] = [] # create the initial list
    self.watches[key].append((id, callback, args))
    return id

  def _notifyWatcher(self, key, value):
    """run callbacks registered on an options key"""
    callbacks = self.watches.get(key, None)
    if callbacks:
      for item in callbacks:
        (id, callback, args) = item
        oldValue = self.get(key, None)
        if callback:
          callback(key, value, oldValue, *args)
        else:
          print("invalid watcher callback :", callback)

  def get(self, key, default):
    """
    get a value from the persistent dictionary
    """
    try:
      return self.d.get(key, default)
    except Exception, e:
      print("options: exception while working with persistent dictionary:\n%s" % e)
      return default

  def set(self, key, value):
    """
    set a value in the persistent dictionary
    """
    self.d[key] = value
    self.options.save()
    if key in self.watches.keys():
      self._notifyWatcher(key, value)

if __name__ == "__main__":
  panora = Panora()



