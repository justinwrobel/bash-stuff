#!/bin/bash
# Move SRC to a date-based directory stucture in DST. The directory structure
# is based on either SRC's exif date tag, or filename.
# ./move-photos.sh $source $destination
#
#   0x010f - Manufacturer
#   0x0110 - Model
#   0x9003 - Date and Time
#   0x0132 - Date and Time (old)
#
# Sources
# http://wiki.bash-hackers.org/scripting/posparams
# https://boredwookie.net/blog/m/bash-101-part-5-regular-expressions-in-conditional-statements
# http://stackoverflow.com/a/2439775/792789

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/common.sh

remove_img() {
  f=$(basename "$1")
  f=${f,,}
  echo ${f//img_/}
}

read_tag() {
  r=$(exif -t $1 -m "$2" 2> /dev/null | tail -n 1)
  echo $r
}

if (( ${#} < 2 )); then
  cat <<- EOF
	NAME
	  move-photos.sh
	
	SYNOPSIS
	  move-photos.sh SRC DEST
	  move-photos.sh SRC... DEST
	
	DESCRIPTION
	  Move SRC to a date-based directory stucture in DST. The directory structure is based on either SRC's exif date tag, or filename.
	
	    move-photos.sh 20200202_131313.jpg foo
	    move-photos.sh VID_20200202_131313.jpg foo
	    move-photos.sh 223.jpg foo # `date -r 223.mp4 --iso-8601=sec` shows 2020-02-02T13:13:13-0600
	    ./foo/2020/02/20200202_131313.jpg
	
	EOF
exit 1
fi

dest="${!#}" # Get last parameter

for src ; do
  if [[ $src == $dest ]] ; then continue; fi
  # ${src,,} convert to lower case
  if [[ "${src,,}" != *"jpg" ]] ; then echo "$src isn't jpg. skipping"; continue; fi

  # Have defaults for everything aside from dst1
  manuf=$(read_tag 0x010f "$src")
  model=$(read_tag 0x0110 "$src")
  if [ -z "$model" ] || [[ $model =~ "ExifData" ]]; then model="unknown"; fi
  dst1=$(read_tag 0x9003 "$src") #2013:07:17 22:28:06, 2019-09-15T00:00:00Z

  datetime_pattern="([0-9]{4})[:-]([0-9]{2})[:-]([0-9]{2}).([0-9]{2})[:-]([0-9]{2})[:-]([0-9]{2})"

  #if dst1 isn't valid date time
  if [[ ! $dst1 =~ $datetime_pattern ]] ; then
    dst2=$(read_tag 0x0132 "$src")
    if [[ ! $dst2 =~ $datetime_pattern ]] || false ; then
      echo "Invalid datetime detected ($dst1, $dst2). skipping $src."
      continue
    fi
  fi

  if [ -z "$model" ] ; then echo "model is missing. skipping $src"; continue; fi
  # BASH_REMATCH has the results of the last =~ comparison
  if [[ ${#BASH_REMATCH[@]} < 7 ]]; then echo "datetime is missing. skipping $src"; continue; fi
  year=${BASH_REMATCH[1]}
  month=${BASH_REMATCH[2]}
  day=${BASH_REMATCH[3]}
  hour=${BASH_REMATCH[4]}
  min=${BASH_REMATCH[5]}
  sec=${BASH_REMATCH[6]}

  # Chop/clean the date up
  dst_dn="${year}/${month}"
  dst_fn="$year$month${day}_$hour$min$sec" #20130713_221330

  # Remove img from filename
  filename=$(remove_img "$src")
  extension="${filename##*.}"

  # Remove extra date pattern from filename
  [[ $filename =~ [-_]?[0-9]{8}[-_][0-9]{6}[-_]? ]] \
   && filename=${filename/${BASH_REMATCH[0]}}

  clean=$(clean_filename "${dst_fn}_${model,,}_${filename,,}")
  clean=${clean/_\./\.} # remove trailing - from blank filename

  # Check if file already exists and increment if needed
  new_filepath="$dest/$dst_dn/$clean"

  if [ ! -f "$new_filepath" ] ; then
    echo $src doesn\'t exist at $new_filepath
  fi
done
