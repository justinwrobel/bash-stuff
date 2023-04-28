#!/bin/bash
here=$(pwd)

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPTPATH

remote="/run/user/1000/gvfs/smb-share:server=skylark,share="
src1="${remote}homes/swille3/Camera Uploads"
src2="${remote}homes/admin/Camera Uploads"
dst="${remote}pictures/"

# https://stackoverflow.com/a/677212
command -v exif >/dev/null 2>&1 || { echo >&2 "I require exif but it's not installed.  Aborting."; exit 1; }
[ ! -d "$src1" ] && echo "$src1 not mounted" && exit 1
[ ! -d "$src2" ] && echo "$src2 not mounted" && exit 1
[ ! -d "$dst" ] && echo "$dst not mounted" && exit 1

find "${src1}" -iname "*.jpg" -exec ./move-photos.sh {} ${dst} \;
find "${src2}" -iname "*.jpg" -exec ./move-photos.sh {} ${dst} \;

#find "${src1}" -iname "*.mp4" -exec ./move-movies-ssh.sh {} ${dst} \;
#find "${src2}" -iname "*.mp4" -exec ./move-movies.sh {} ${dst} \;

# Find files and run using bash5, server only has bash3

find "$src1" -name *mp4 -exec \
  ./move-movies-ssh.sh \
  admin@skylark \
  '{}' \
  "$remote" \
  /share/ \
  /share/Pictures/ \
\;

find "$src2" -name *mp4 -exec \
  ./move-movies-ssh.sh \
  admin@skylark \
  '{}' \
  "$remote" \
  /share/ \
  /share/Pictures/ \
\;

cd $here
