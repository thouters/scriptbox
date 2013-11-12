#!/bin/bash
SCRIPTNAME=`basename $0`
while IFS= read -d $'\0' -r file 
do
    filename=`basename "$file"`
    normalised=`echo "$filename" |tr '[:upper:]' '[:lower:]' |sed s'/ /_/'g`
    dirname=$1/`dirname "$file"`
    cd "$dirname"

    MTIME=`stat -c '%Y' "$filename"`
    EMTIME=`stat -c '%Y' "$normalised" 2>/dev/null`

    if [[ $EMTIME -eq $MTIME ]]
    then 
        echo $SCRIPTNAME: $filename \<= $normalised OK
    else
        ln -sf "$filename" "$normalised"
        touch -hd @$MTIME "$normalised"
        echo $SCRIPTNAME: $filename \<= $normalised NEW $MTIME
        MTIME=`stat -c '%Y' "$filename"`
        EMTIME=`stat -c '%Y' "$normalised" 2>/dev/null`
        if [[ $EMTIME -ne $MTIME ]]
        then
            echo $SCRIPTNAME: ERROR: 
            ls -al "$filename"
            ls -al "$normalised"
            exit 0
        fi
    fi
done < <(find "$1" "$@" -printf '%P\0' )
