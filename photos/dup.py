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
        myfile.write(f'file://{filename}')
        myfile.write('\n')

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
# - https://www.tutorialspoint.com/python/python_functions.htm
