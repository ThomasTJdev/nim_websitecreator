import os, strutils, osproc

when defined(packedjson): import packedjson
else:                     import json

import ../constants/constants, ../utils/utils


# Order is important here.
include
  "_detailers",
  "_repos",
  "_downloaders",
  "_deleters",
  "_switchers",
  "_settings"
