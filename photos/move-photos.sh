#!/bin/bash
# This script will move jpgs in the current directory 
# to year/month/day/$filename directory
# ./move-photos.sh $source $destination
#0x010f - Manufacturer 
#0x0110 - Model
#0x9003 - Date and Time
#0x0132 - Date and Time (old)
#Sources
# http://wiki.bash-hackers.org/scripting/posparams
# https://boredwookie.net/blog/m/bash-101-part-5-regular-expressions-in-conditional-statements
# http://stackoverflow.com/a/2439775/792789

clean_filename(){
  f=${1//[^A-Za-z0-9\-\.]/_}
  f=${f,,}
  echo $f
}

remove_img(){
  f=$(basename "$1")
  f=${f,,}
  echo ${f//img_/}
}

read_tag(){
  r=$(exif -t $1 -m "$2" 2> /dev/null | tail -n 1)
  echo $r
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

if [[ $# < 1 ]] ; then echo "missing dest"; exit 1; fi

dest="${!#}" #get last parameter

for src ; do

  if [[ $src == $dest ]] ; then continue; fi
  #${src,,} convert to lower case
  if [[ "${src,,}" != *"jpg" ]] ; then echo "$src isn't jpg. skipping"; continue; fi

  #have defaults for everything aside from dst1
  manuf=$(read_tag 0x010f "$src") 	#2
  model=$(read_tag 0x0110 "$src") 	#
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

  extension="${filename##*.}"

  #chop/clean the date up
  dst_dn="${year}/${month}"
  dst_fn="$year$month${day}_$hour$min$sec" #20130713_221330

  #remove img from filename
  filename=$(remove_img "$src")

  #remove extra date pattern from filename
  [[ $filename =~ [-_]?[0-9]{8}[-_][0-9]{6}[-_]? ]] \
   && filename=${filename/${BASH_REMATCH[0]}}

  clean=$(clean_filename "${dst_fn}_${model,,}_${filename,,}")
  clean=${clean/_\./\.} # remove trailing _
  old_clean=$(clean_filename "${dst_fn}_${manuf}_${model}.${extension}")
  if [ "$src" == "$old_clean" ]; then 
     clean=$(clean_filename "${dst_fn}_${model,,}.${extension}")
  fi

  #check if file already exists and increment if needed
  old_filepath="$dest/$dst_dn/$clean"
  new_filepath="$dest/$dst_dn/$clean"
  if [ -f "$new_filepath" ]; then
     echo "Error while processing $src. $new_filepath already exists! Adding an increment."
     inc=0
     #replace .jpg with $inc.jpg 
     while [ -f "$new_filepath" ]; do 
       inc=$((inc+1)) 
       new_filepath="${old_filepath/\.jpg/-$inc\.jpg}"
     done
  fi

  if [ -f "$new_filepath" ] ; then
    echo $new_filepath already exists. Skipping.
  else
    # Retry from https://unix.stackexchange.com/a/82610/169986
    for i in {1..5}; do move "$src" "$new_filepath" && break || sleep 1; done
  fi
done
