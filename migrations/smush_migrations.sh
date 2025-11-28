#!/usr/bin/bash
# This is a simple script to rename all the files in this folder to describe what they do, rather than the commit, or hash or whatever
# We'll try taking the mentioned program, binary or package from the `echo` message in each one, then turn that into 2-3 words
# Example: `echo "Add 100-line split resizing keybindings to Ghostty" - convert to "ghostty_resize.sh"


DIR_TO_RENAME_FILES="$($1)"
FILES_IN_DIR=*
FILES_TO_RENAME=()
NUMBER_OF_FILES=$



