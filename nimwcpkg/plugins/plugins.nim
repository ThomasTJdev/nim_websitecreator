import os, strutils, contra, osproc

when defined(packedjson): import packedjson
else:                     import json

import ../constants/constants


# Order is important here.
include
  "_details",
  "_repo",
  "_download",
  "_delete",
  "_switcher",
  "_settings"
