"""args.py a Panora CLI processor
- it gets the commandline arguments and decides what to do
"""
#noinspection PyCompatibility
import argparse

class Startup():
  def __init__(self):
    parser = argparse.ArgumentParser(description="A flexible re-photography tool.")
    parser.add_argument('-p',
      help="specify current platform", default=None,
      action="store", choices=["harmattan"])
    # due to the need for magnetic compass & a camera,
    # Panora realy needs to run on a real mobile device :)
    parser.add_argument('--name',
      help="use this project name", default=None,
      action="store", metavar="project name", )
    parser.add_argument('--locale',
      help="override system locale", default=None,
      action="store", metavar="language code", )
    self.args = parser.parse_args()

