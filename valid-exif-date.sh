#/bin/bash
# sample invocation: ~/tmp/phones/set-exif-date.sh *
# This script will set the exif date on file without one. 
# It attempts to resolve the date from the directory or a previously processed file.
#  

read_tag(){
  r=$(exif -d -t $1 -m "$2" 2> /dev/null | tail -n 1)
  echo $r
}
exit_code=0
for i; do

  #get datetime from file
  meta_date=$(read_tag 0x9003 "$i") 	#2013:07:17 22:28:06

  #if 0x9003 didn't have anything try 0x0132
  if [ -z "$meta_date" ] || [[ $meta_date == *"ExifLoader"* ]]; then meta_date=$(read_tag 0x132 "$i"); fi 
  if [[ $meta_date == *"ExifLoader"* ]]; then 
     echo "$i is missing meta_date";
     exit_code=1
  fi


done
exit $exit_code
