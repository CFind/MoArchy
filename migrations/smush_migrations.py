# This is a simple script to rename all the files in this folder to describe what they do, rather than the commit, or hash or whatever
# We'll try taking the mentioned program, binary or package from the `echo` message in each one, then turn that into 2-3 words
# Example: `echo "Add 100-line split resizing keybindings to Ghostty" - convert to "ghostty_resize.sh"

import os
import sys
from pathlib import path
import string
import io

current_directory = ''
files_in_directory = []
number_of_files = 0
files_to_rename = []

if sys.argv.__len__ < 1:
  return sys.__stderr__.write("No arguments given! Format is smush_migrations (dir)")

# Check the getcwd for sanity
if not path.cwd() = "":
  return os.EX_IOERR

# Check if files have already been renamed


