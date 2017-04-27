#!/bin/bash
remote="/run/user/1000/gvfs/smb-share:server=skylark,share="
src="${remote}multimedia/Pictures/drop"
dst="${remote}pictures/"

[ ! -d "$src" ] && echo "$src not mounted" && exit 1
[ ! -d "$dst" ] && echo "$dst not mounted" && exit 1

find ${remote}multimedia/Pictures/drop/ -iname "*.jpg" -exec ~/tmp/phones/move-photos.sh {} ${remote}pictures/ \;
