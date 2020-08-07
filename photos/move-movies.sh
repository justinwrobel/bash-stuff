#{mp4,3gp,mov}
move(){
  src=$1
  dst=$2
  mkdir -p "$(dirname $dst)" \
    && rsync -t "$src" "$dst" \
    && rm "$src" \
    && return 0 \
    || echo "$? Issue processing $src" && return 1
}

if [[ ${#} < 2 ]]; then
  cat <<- EOF
	NAME
	  move-movies.sh
	
	SYNOPSIS
	  move-movies.sh SRC DEST
	  move-movies.sh SRC... DEST
	
	DESCRIPTION
	  Move SRC to a date-based directory stucture in DST. The directory structure is based on either SRC's name or last modified.
	
	    move-movies.sh 20200202_131313.mp4 foo
	    move-movies.sh VID_20200202_131313.MP4 foo
	    move-movies.sh 223.mp4 foo # \`date -r 223.mp4 --iso-8601=sec\` shows 2020-02-02T13:13:13-0600
	    ./foo/2020/02/20200202_131313.mp4
	EOF
exit 1
fi

dest="${!#}" #get last parameter

for src ; do
  if [[ $src == $dest ]] ; then continue; fi
  #${src,,} convert to lower case
  echo "TODO other filetypes"
  if [[ "${src,,}" != *"mp4" ]] ; then echo "$src isn't mp4. skipping"; continue; fi

  # VID_20200614_170537921.mp4
  # 2832.mp4 - get created/modified date
  # 2020-02-02T13:13:13, 20200202_131313
  datetime_pattern="([0-9]{4})[:-]?([0-9]{2})[:-]?([0-9]{2}).?([0-9]{2})[:-]?([0-9]{2})[:-]?([0-9]{2})"
  [[ $src =~ $datetime_pattern ]]
  [[ ${#BASH_REMATCH[@]} < 7 ]] && [[ $(date -r $src --iso-8601=sec) =~ $datetime_pattern ]]
  if [[ ${#BASH_REMATCH[@]} < 7 ]]; then
    echo "datetime is missing. skipping $src"; continue; 
  fi

  year=${BASH_REMATCH[1]}
  month=${BASH_REMATCH[2]}
  day=${BASH_REMATCH[3]}
  hour=${BASH_REMATCH[4]}
  min=${BASH_REMATCH[5]}
  sec=${BASH_REMATCH[6]}

  echo "time $year $month $day $hour $min $sec"
  echo "clean filename"
  echo "do move"
done
