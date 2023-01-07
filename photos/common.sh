#!/bin/bash

clean_filename() {
  f=${1//[^A-Za-z0-9\-\.]/_} # replace invalid chars with underscores (_)
  f=${f,,}
  echo $f
}

get_ext() {
  echo "${1##*.}"
}

get_uniq_filename() {
  # Check if file already exists and increment if needed
  old_filepath="$1"
  new_filepath="$1"
  ext=$(get_ext $new_filepath)
  if [ -f "$new_filepath" ]; then
     >&2 echo "Error while processing $src. $new_filepath already exists! Adding an increment."
     inc=0
     # Replace .jpg with $inc.jpg
     while [ -f "$new_filepath" ]; do
       inc=$((inc+1))
       new_filepath="${old_filepath/\.$ext/-$inc\.$ext}"
     done
  fi
  echo $new_filepath
}

rsync_move() {
  src=$1
  dst=$2

  mkdir -p "$(dirname $dst)" \
    && rsync -t "$src" "$dst" \
    && rm "$src" \
    && return 0 \
    || >&2 echo "$? Issue processing $src" && return 1
}

ssh_move() {
  server=$1
  src=$2
  dst=$3

  ssh $server "mkdir -p \"$(dirname $dst)\"" \
    && ssh $server "mv -f \"$src\" \"$dst\"" \
    && return 0 \
    || >&2 echo "$? Issue processing $src to $dst" && return 1
}

move() {
  src=$1
  dst=$2
  mkdir -p "$(dirname $dst)" \
    && mv "$src" "$dst" \
    && return 0 \
    || >&2 echo "$? Issue processing $src to $dst" && return 1
}

# https://stackoverflow.com/a/8574392/792789
element_in() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}
