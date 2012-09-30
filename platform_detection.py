# Mieru current-platform detection
import os

DEFAULT_DEVICE_MODULE_ID = "pc"
DEFAULT_GUI_MODULE_ID = "QML"

def getBestPlatformModuleId():
  print("** detecting current device **")
  result = _check()
  if result is not None:
    deviceModuleId = result
  else:
    deviceModuleId = DEFAULT_DEVICE_MODULE_ID # use GTK GUI module as fallback
    print("* no known device detected")
  print('** selected "%s" as device module ID **' % deviceModuleId)
  return deviceModuleId


def getBestGUIModuleId():
  return DEFAULT_GUI_MODULE_ID


def _check():
  """
  try to detect current device
  """
  # check CPU architecture
  import subprocess

  proc = subprocess.Popen(['uname', '-m', ], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  return_code = proc.wait()
  arch = proc.stdout.read()
  if ("i686" in arch) or ("x86_64" in arch):
    print("* PC detected")
    return "pc" # we are most probably on a PC

  # check procFS
  if os.path.exists("/proc/cpuinfo"):
    f = open("/proc/cpuinfo", "r")
    cpuinfo = f.read()
    f.close()
    if "Nokia RX-51" in cpuinfo: # N900
      print("* Nokia N900 detected")
      return "maemo5"
    # N9 and N950 share the same device module
    elif "Nokia RM-680" in cpuinfo: # N950
      print("* Nokia N950 detected")
      return "harmattan"
    elif "Nokia RM-696" in cpuinfo: # N9
      print("* Nokia N9 detected")
      return "harmattan"

  return None


