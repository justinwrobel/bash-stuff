# photos

This is a collection of scripts to make photo management a little easier. 

Running `./run-move-photos.sh` will move and rename photos from the $src directory to the $$dst directory. It will rename the images based on the following naming scheme:

 * `$date_$model_$orgfilename.$ext`

Although, it may drop the $orgfilename if it resembles the date. Here are some examples:


 * `20170101_015336_lg-h811_hdr.jpg`
 * `20170905_180840_nexus_5x.jpg`

This script will organize the photos into year/month directories. For example, 

 * 2017/01
 * 2016/11
