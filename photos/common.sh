#!/bin/bash

clean_filename(){
  f=${1//[^A-Za-z0-9\-\.]/_} # replace invalid chars with underscores (_)
  f=${f,,}
  echo $f
}

get_ext() {
  echo "${1##*.}"
}

get_uniq_filename() {
  #check if file already exists and increment if needed
  old_filepath="$1"
  new_filepath="$1"
  ext=$(get_ext $new_filepath)
  if [ -f "$new_filepath" ]; then
     echo "Error while processing $src. $new_filepath already exists! Adding an increment."
     inc=0
     #replace .jpg with $inc.jpg 
     while [ -f "$new_filepath" ]; do 
       inc=$((inc+1)) 
       new_filepath="${old_filepath/\.$ext/-$inc\.$ext}"
     done
  fi
  echo $new_filepath
}

move(){
  src=$1
  dst=$2
  mkdir -p "$(dirname $dst)" \
    && rsync -t "$src" "$dst" \
    && rm "$src" \
    && return 0 \
    || echo "$? Issue processing $src" && return 1
}