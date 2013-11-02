#!/bin/bash
TMP=`mktemp -d`
MTIME=`stat -c '%Y' "$1"`
unzip "$1" -d $TMP >/dev/null
FOUND=`find $TMP -iname 'snb_thumbnailimage*.jpg'` 
for THUMB in $FOUND
do 
    TMTIME=`stat -c %Y "$THUMB"`
    ID=`echo $THUMB|sed 's/.*snb_thumbnailimage//'`
    TNAME="$1-$ID"
    UPTODATE=0
    if [[ -e $TNAME ]]
    then
        EMTIME=`stat -c %Y "$TNAME"`
        if [[ $EMTIME -eq $MTIME ]]
        then
            UPTODATE=1
        fi
    fi
    if [[ $UPTODATE -eq 0 ]]
    then
        echo $THUMB
        cp "$THUMB" "$TNAME"
        touch -d @$MTIME "$TNAME"
    else
        echo File is uptodate: $THUMB >/dev/null
    fi
done
rm -r $TMP
