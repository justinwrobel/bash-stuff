#!/usr/bin/env python3
from wand.image import Image
import os
import sys
from pathlib import Path

# identify -verbose -format "%#" filename

# This command outputs the filename of an 
# image to a file with the signature as its name

# https://stackoverflow.com/a/52249882/792789
filename=sys.argv[1]
img = Image(filename=filename) 

#TODO add debug mode
#    print(filename)
#    print(img.signature)
# TODO read file and add filenames to a dict 
# TODO only write if missing
home = str(Path.home())
dup_dir = f'{home}/dups'
if not os.path.exists(dup_dir):
    os.makedirs(dup_dir)

with open(f'{dup_dir}/{img.signature}', "a") as myfile:
    myfile.write(filename)
    myfile.write('\n')
