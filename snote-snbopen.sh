#!/bin/bash
SCRIPTNAME=`basename $0`
TMP=`mktemp -d`
MTIME=`stat -c '%Y' "$1"`
TNAME="$1.pdf"
UPTODATE=0
DIR=`dirname "$1"`
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
    echo $SCRIPTNAME: $TNAME \<= $1 ...
    snbopen.py "$1" "$TNAME"
    find "$DIR" -name "`basename "$TNAME"`" -exec touch -d @$MTIME "{}" \;
else
    echo $SCRIPTNAME: $TNAME \<= $1 OK
fi
#find "$DIR" -name "`basename "$TNAME"`" -exec ls -al "{}" \;
