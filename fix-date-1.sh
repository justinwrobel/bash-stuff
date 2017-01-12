#!/bin/bash
#e.g., "03.01.2011 01:34:23"
dt_fmt="([0-9]{2})\.([0-9]{2})\.([0-9]{4}) ([0-9]{2})\:([0-9]{2})\:([0-9]{2})"

for f ; do 
  dt_bad=$(exif -t 0x9003 -m $f)
  if [[ $dt_bad =~ $dt_fmt ]]; then 
    year=${BASH_REMATCH[3]}
    month=${BASH_REMATCH[1]}
    day=${BASH_REMATCH[2]}
    hour=${BASH_REMATCH[4]}
    min=${BASH_REMATCH[5]}
    sec=${BASH_REMATCH[6]}

    dt="$year-$month-$day $hour:$min:$sec" #2013-07-13_22:13:30
    exif -d -c -t 0x9003 --ifd EXIF --set-value "${dt}" -o "$f.jw" "$f" > /dev/null \
      && [ -a "$f.jw" ] && mv -f "$f.jw" "$f"
  fi

done
