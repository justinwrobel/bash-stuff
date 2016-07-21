# This script will move jpgs in the current directory 
# to year/month/day/$filename directory
#TODO doc invokation
#0x010f - Manufacturer 
#0x0110 - Model
#0x9003 - Date and Time
#0x0132 - Date and Time (old)

#TODO chang to copy rather than move
#TODO copy to ~/tmp/all
clean_filename(){
  f=${1//[^A-Za-z0-9\-\.]/_}
  f=${f,,}
  echo $f 
}

for i in *.jpg; do 

manuf=$(exif -t 0x010f -m $i) 	#2
model=$(exif -t 0x0110 -m $i) 	#
dst1=$(exif -t 0x9003 -m $i) 	#2013:07:17 22:28:06

#if 0x9003 didn't have anything try 0x0132
if [ -z "$dst1" ]; then dst1=$(exif -t 0x0132 -m $i); fi 
dst2=${dst1:0:7} 		#2013:07
dst_dn=${dst2//://}
dst_fn=${dst1//:/}
dst_fn=${dst_fn// /_}
clean=$(clean_filename "${dst_fn}_${manuf}_${model}.jpg")
if [ -z "$dst2" ] && [ -z "$model" ] && [ -z "$manuf" ]; then echo "skipping $i"; continue; fi
mkdir -p $dst_dn &&  mv "$i" "$dst_dn/$clean"
done
