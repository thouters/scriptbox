#!/bin/bash
TMP=`mktemp -d`
MTIME=`stat -c '%Y' "$1"`
echo $0: $1 mtime=$MTIME
TNAME="$1.png"
DIR=`dirname "$1"`
TNAMEGLOB="$1*.png"
EMTIME=`find "$DIR" -name "\`basename "$TNAMEGLOB"\`" -exec stat -c %Y "{}" \; |head -n 1`
UPTODATE=0
if [[ -n $TNAMEGLOB ]]
then
    if [[ $EMTIME -eq $MTIME ]]
    then
        UPTODATE=1
    fi
fi
if [[ $UPTODATE -eq 0 ]]
then
    echo $0: converting "$1" to pngs...
    convert -density 400 -resize 25% "$1" "$TNAME"
    find "$DIR" -name "`basename "$TNAMEGLOB"`" -exec touch -d @$MTIME "{}" \;
else
    echo File is uptodate: $TNAMEGLOB 
fi
find "$DIR" -name "`basename "$TNAMEGLOB"`" -exec ls -al "{}" \;
