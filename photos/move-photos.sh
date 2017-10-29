#!/bin/bash
# This script will move jpgs in the current directory 
# to year/month/day/$filename directory
#TODO doc invokation
# .../move-photos.sh */* . # move the files from sub dirs using . as a destination
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
  r=$(exif -d -t $1 -m "$2" 2> /dev/null | tail -n 1)
  echo $r
}

if [[ $# < 1 ]] ; then echo "missing dest"; exit 1; fi

dest="${!#}" #get last parameter

for i ; do 

  if [[ $i == $dest ]] ; then continue; fi
#${i,,} convert to lower case
  if [[ "${i,,}" != *"jpg" ]] ; then echo "$i isn't jpg. skipping"; continue; fi

  #have defaults for everything aside from dst1
  manuf=$(read_tag 0x010f "$i") 	#2
  model=$(read_tag 0x0110 "$i") 	#
  if [ -z "$model" ] || [[ $model =~ "ExifData" ]]; then model="unknown"; fi
  dst1=$(read_tag 0x9003 "$i") 	#2013:07:17 22:28:06

  datetime_pattern="([0-9]{4})[:-]([0-9]{2})[:-]([0-9]{2})\ ([0-9]{2})[:-]([0-9]{2})[:-]([0-9]{2})"

  #if dst1 isn't valid date time
  if [[ ! $dst1 =~ $datetime_pattern ]] ; then 
    dst1=$(read_tag 0x0132 "$i");
    if [[ ! $dst1 =~ $datetime_pattern ]] || false ; then 
      echo "Invalid datetime detected. skipping $i."
      continue 
    fi
  fi 

  if [ -z "$model" ] ; then echo "model is missing. skipping $i"; continue; fi
  if [[ ${#BASH_REMATCH[@]} < 7 ]]; then echo "datetime is missing. skipping $i"; continue; fi
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
  filename=$(remove_img "$i") 

  #remove extra date pattern from filename 
  [[ $filename =~ [-_]?[0-9]{8}[-_][0-9]{6}[-_]? ]] \
   && filename=${filename/${BASH_REMATCH[0]}}

  clean=$(clean_filename "${dst_fn}_${model,,}_${filename,,}")
  clean=${clean/_\./\.} # remove trailing _ 
  old_clean=$(clean_filename "${dst_fn}_${manuf}_${model}.${extension}")
  if [ "$i" == "$old_clean" ]; then 
     clean=$(clean_filename "${dst_fn}_${model,,}.${extension}")
  fi

  #check if file already exists and increment if needed
  old_filepath="$dest/$dst_dn/$clean" 
  new_filepath="$dest/$dst_dn/$clean" 
  if [ -f $new_filepath ]; then
     echo "Error while processing $i. $new_filepath already exists!"
     inc=0
     #replace .jpg with $inc.jpg 
     while [ -f $new_filepath ]; do 
       inc=$((inc+1)) 
       new_filepath=${old_filepath/\.jpg/-$inc\.jpg}
     done

  fi


  if [ -f "$new_filepath" ] ; then
    echo $new_filepath already exists. Skipping.
  else
#    echo  $new_filepath
#    mkdir -p "$dest/$dst_dn" && cp -i "$i" "$new_filepath" #copy
    mkdir -p "$dest/$dst_dn" && mv -i "$i" "$new_filepath" #move 
  fi
done
