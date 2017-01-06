#!/bin/bash
# This script will move jpgs in the current directory 
# to year/month/day/$filename directory
#TODO doc invokation
# .../move-photos.sh */* . # move the files from sub dirs using . as a destination
#0x010f - Manufacturer 
#0x0110 - Model
#0x9003 - Date and Time
#0x0132 - Date and Time (old)

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


dest="${!#}"

for i ; do 

  if [[ $i == $dest ]] ; then continue; fi
  if [[ "${i,,}" != *"jpg" ]] ; then echo "$i isn't jpg. skipping"; continue; fi

  #have defaults for everything aside from dst1
  manuf=$(read_tag 0x010f "$i") 	#2
  model=$(read_tag 0x0110 "$i") 	#
  if [ -z "$model" ]; then model="unknown"; fi
  dst1=$(read_tag 0x9003 "$i") 	#2013:07:17 22:28:06

  #if 0x9003 didn't have anything try 0x0132
  if [ -z "$dst1" ]; then dst1=$(read_tag 0x0132 "$i"); fi 

  filename=$(remove_img "$i") 
  extension="${filename##*.}"

  #chop/clean the date up
  dst2=${dst1:0:7} 		#2013:07
  dst_dn=${dst2//://}
  dst_fn=${dst1//:/}
  dst_fn=${dst_fn// /_}		#20130713_221330

  clean=$(clean_filename "${dst_fn}_${model,,}_${filename,,}")
  old_clean=$(clean_filename "${dst_fn}_${manuf}_${model}.${extension}")
  if [ "$i" == "$old_clean" ]; then 
     clean=$(clean_filename "${dst_fn}_${model,,}.${extension}")
  fi
  
  if [ -z "$dst2" ] || [ -z "$model" ] ; then echo "something is missing. skipping $i"; continue; fi

  #check if file already exists and increment if needed
  old_filename="$dest/$dst_dn/$clean" 
  new_filename="$dest/$dst_dn/$clean" 
  #inc=0
  #while [ -f $new_filename ]; do 
  #  inc=$((inc+1)) 
  #  new_filename="$old_filename-$inc.jpg"
  #done
  #if [ $inc -gt 0 ]; then echo $new_filename was created due to conflict; fi

  if [ -f $new_filename ] ; then
    echo $new_filename already exists. Skipping.
  else
    mkdir -p "$dest/$dst_dn" && cp -i "$i" $new_filename 
  fi
done
