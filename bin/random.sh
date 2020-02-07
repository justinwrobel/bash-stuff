#!/bin/bash
# https://blogs.warwick.ac.uk/mikewillis/entry/random_words/
WORDFILE=/usr/share/dict/words
# seed random from pid
RANDOM=$$;
# using cat means wc outputs only a number, not number followed by filename
lines=$(cat $WORDFILE  | wc -l);
rnum=$((RANDOM*RANDOM%$lines+1));
sed -n "$rnum p" $WORDFILE;
