#!/bin/bash
here=$(pwd)

#https://stackoverflow.com/a/4774063
pushd `dirname $0` > /dev/null
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
popd > /dev/null

cd $SCRIPTPATH

remote="/run/user/1000/gvfs/smb-share:server=skylark,share="
src="${remote}multimedia/Pictures/drop"
dst="${remote}pictures/"


[ ! -d "$src" ] && echo "$src not mounted" && exit 1
[ ! -d "$dst" ] && echo "$dst not mounted" && exit 1

find ${remote}multimedia/Pictures/drop/ -iname "*.jpg" -exec ./move-photos.sh {} ${remote}pictures/ \;

cd $here
