"""args.py a Panora CLI processor
- it gets the commandline arguments and decides what to do
"""
#noinspection PyCompatibility
import argparse

class Startup():
    def __init__(self):
        parser = argparse.ArgumentParser(description="A flexible re-photography tool.")
        parser.add_argument('-p',
            help="specify the platform", default="pc",
            action="store", choices=["maemo5", "harmattan", "pc"])
        parser.add_argument('--name',
            help="use this project name", default=None,
            action="store", metavar="project name", )
        parser.add_argument('--locale',
            help="override system locale", default=None,
            action="store", metavar="language code", )
        self.args = parser.parse_args()

