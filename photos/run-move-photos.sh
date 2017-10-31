#!/bin/bash
here=$(pwd)

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPTPATH

remote="/run/user/1000/gvfs/smb-share:server=skylark,share="
src="${remote}multimedia/Pictures/drop"
dst="${remote}pictures/"

# https://stackoverflow.com/a/677212
command -v exif >/dev/null 2>&1 || { echo >&2 "I require exif but it's not installed.  Aborting."; exit 1; }
[ ! -d "$src" ] && echo "$src not mounted" && exit 1
[ ! -d "$dst" ] && echo "$dst not mounted" && exit 1

find ${remote}multimedia/Pictures/drop/ -iname "*.jpg" -exec ./move-photos.sh {} ${remote}pictures/ \;

cd $here
