#{mp4,3gp,mov}
for i in *.MP4; do 
dst2=`date -r $i +%Y/%d/%m`
if [ -z "$dst2" ]; then echo "skipping $i"; continue; fi
mkdir -p ${dst2//://} && mv "$i" "${dst2//://}/$i"
done
