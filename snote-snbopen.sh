#!/bin/bash
TMP=`mktemp -d`
MTIME=`stat -c '%Y' "$1"`
TNAME="$1.pdf"
UPTODATE=0
DIR=`dirname "$1"`
echo $0 : $1 mtime=$MTIME
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
    echo $0: Updating $TNAME
    snbopen.py "$1" "$TNAME"
    find "$DIR" -name "`basename "$TNAME"`" -exec touch -d @$MTIME "{}" \;
else
    echo File is uptodate: $TNAME
fi
find "$DIR" -name "`basename "$TNAME"`" -exec ls -al "{}" \;
