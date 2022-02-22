#!/bin/bash
# Move SRC to a date-based directory stucture in DEST. The directory structure
# is based on either SRC's name or last modified.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/common.sh

remove_vid() {
  f=$(basename "$1")
  f=${f,,}
  echo ${f//vid_/}
}


if ((  ${#} < 2 )); then
  cat <<- EOF
	NAME
	  move-movies.sh
	
	SYNOPSIS
	  move-movies.sh SRC DEST
	  move-movies.sh SRC... DEST
	
	DESCRIPTION
	  Move SRC to a date-based directory stucture in DEST. The directory structure is based on either SRC's name or last modified.
	
	    move-movies.sh 20200202_131313.mp4 foo
	    move-movies.sh VID_20200202_131313.MP4 foo
	    move-movies.sh 223.mp4 foo # \`date -r 223.mp4 --iso-8601=sec\` shows 2020-02-02T13:13:13-0600
	    ./foo/2020/02/20200202_131313.mp4
	EOF
exit 1
fi

dest="${!#}" # Get last parameter

for src ; do
  if [[ $src == $dest ]] ; then continue; fi
  # ${src,,} convert to lower case
  ext=$(get_ext ${src,,})
  file_types=(mp4 mov avi 3gp wmv)
  if ! element_in $ext "${file_types[@]}"; then echo "Error while processing $src: $ext is an unsupported filetype (${file_types[@]}). Skipping."; continue; fi

  # VID_20200614_170537921.mp4
  # 2832.mp4 - get created/modified date
  # 2020-02-02T13:13:13, 20200202_131313
  datetime_pattern="([0-9]{4})[:-]?([0-9]{2})[:-]?([0-9]{2}).?([0-9]{2})[:-]?([0-9]{2})[:-]?([0-9]{2})"
  [[ $src =~ $datetime_pattern ]]
  [[ ${#BASH_REMATCH[@]} < 7 ]] && [[ $(date -r "$src" --iso-8601=sec) =~ $datetime_pattern ]]
  if [[ ${#BASH_REMATCH[@]} < 7 ]]; then
    echo "datetime is missing. skipping $src"
    continue
  fi

  year=${BASH_REMATCH[1]}
  month=${BASH_REMATCH[2]}
  day=${BASH_REMATCH[3]}
  hour=${BASH_REMATCH[4]}
  min=${BASH_REMATCH[5]}
  sec=${BASH_REMATCH[6]}

  filename=$(remove_vid "$src")

  dst_dn="${year}/${month}"
  dst_fn="$year$month${day}_$hour$min$sec" #20130713_221330

  # Remove extra date pattern from filename
  [[ $filename =~ [-_]?[0-9]{8}[-_][0-9]{6}[-_]? ]] \
   && filename=${filename/${BASH_REMATCH[0]}}

  clean=$(clean_filename "${dst_fn}-${filename,,}")
  clean=${clean/-\./\.} # remove trailing - from blank filename

  new_filepath="$dest/$dst_dn/$clean"

  if [ ! -f "$new_filepath" ] ; then
    echo $src doesn\'t exist at $new_filepath
  fi
done
