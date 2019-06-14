#!/usr/bin/env python3
from wand.image import Image
import os
import sys
from pathlib import Path

# identify -verbose -format "%#" filename

# This command outputs the filename of an 
# image to a file with the signature as its name

# https://stackoverflow.com/a/52249882/792789
def process(filename):
    _filename = os.path.abspath(filename)
    # TODO is really an image?
    try:
        img = Image(filename=_filename) 
        added_filename = f'file://{_filename}'

        #TODO add debug mode
        home = str(Path.home())
        dup_dir = f'{home}/dups'
        dup_sig = f'{dup_dir}/{img.signature}'
        if not os.path.exists(dup_dir):
            os.makedirs(dup_dir)

        already_added = False
        if os.path.isfile(dup_sig):
            with open(dup_sig, "r") as f:
                for line in f:
                    already_added = line.strip() == added_filename

        if not already_added:
            with open(dup_sig, "a") as f:
                f.write(added_filename)
                f.write('\n')
    except:
        e = sys.exc_info()[0]
        print(f'Error while processing {filename} {e}')


if len(sys.argv) > 1:
    process(sys.argv[1])
else:
    for line in sys.stdin:
        process(line.rstrip())

### Resouces
# - https://stackoverflow.com/questions/3383892/is-it-possible-to-detect-duplicate-image-files/52249882#52249882
# - https://stackoverflow.com/questions/1274405/how-to-create-new-folder#1274465
# - https://stackoverflow.com/questions/4028904/how-to-get-the-home-directory-in-python#4028943
# - https://stackoverflow.com/questions/5423381/checking-if-sys-argvx-is-defined#5423400
# - https://stackoverflow.com/questions/4028904/how-to-get-the-home-directory-in-python#4028943
# - https://www.tutorialspoint.com/python/python_functions.htm
