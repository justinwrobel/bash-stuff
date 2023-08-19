#/bin/bash
# sample invocation: ~/tmp/phones/set-exif-date.sh *
# This script will set the exif date on file without one. 
# It attempts to resolve the date from the directory or a previously processed file.
#  

read_tag(){
  r=$(exif -d -t $1 -m "$2" 2> /dev/null | tail -n 1)
  echo $r
}

last_folder=""
for i; do

  #get current folder
  t=$(readlink -f "$i")
  current_folder=$(dirname "$t")

  #update last_date from folder structure if the folder has changed
  [ "$current_folder" != "$last_folder" ] \
   && [[ $current_folder =~ ([0-9]{4})[:-]([0-9]{2})[:-]([0-9]{2}) ]] \
   && last_date="${BASH_REMATCH[1]}-${BASH_REMATCH[2]}-${BASH_REMATCH[3]} 00:00:00"\

  file_date=$(date -r $i "+%Y-%m-%d %H:%M:%S")
  echo "last_date set to $file_date"

  exif -d -c -t 0x9003 --ifd EXIF --set-value "${file_date//-/:}" -o "$i.jw" "$i" > /dev/null \
      && [ -a "$i.jw" ] && mv -f "$i.jw" "$i"

  # remove comment
  exif -d -c -t 0x9286 --ifd EXIF --set-value "" -o "$i.jw" "$i" > /dev/null \
      && [ -a "$i.jw" ] && mv -f "$i.jw" "$i"

  touch -d "$file_date" $i

  continue
  echo "no skip?"

  if [[ "${i,,}" != *"jpg" ]] ; then echo "$i isn't jpg. skipping"; continue; fi

  #get datetime from file
  meta_date=$(read_tag 0x9003 "$i") 	#2013:07:17 22:28:06

  #if 0x9003 didn't have anything try 0x0132
  if [ -z "$meta_date" ] || [[ $meta_date == *"ExifLoader"* ]]; then meta_date=$(read_tag 0x132 "$i"); fi
  if [[ $meta_date == *"ExifLoader"* ]]; then 
     echo "$i is missing meta_date"; 
     if [ -z "$last_date" ]; then
       echo "last_date isn't set. Please set or abort. e.g., 2016-12-23 00:00:00"
       read last_date
     fi

     #increment last_date
     td=$(date +"%s" -d "$last_date") #read into epoch seconds
     td=$(($td+5))
     last_date=$(date +"%Y-%m-%d %H:%M:%S" -d "@$td")
     echo "fixing date on $i to $last_date. press enter when ready"
     read
     exif -d -c -t 0x9003 --ifd EXIF --set-value "${last_date//-/:}" -o "$i.jw" "$i" > /dev/null \
      && [ -a "$i.jw" ] && mv -f "$i.jw" "$i"
  fi

  #if meta_data is fine convert to acutal date
  if [[ $meta_date =~ ([0-9]{4})[:-]([0-9]{2})[:-]([0-9]{2})\ ([0-9]{2}:[0-9]{2}:[0-9]{2}) ]]; then
    last_date="${BASH_REMATCH[1]}-${BASH_REMATCH[2]}-${BASH_REMATCH[3]} ${BASH_REMATCH[4]}"
  fi


  last_folder=$current_folder

done
