#!/bin/bash
SCRIPTNAME=`basename $0`
while IFS= read -d $'\0' -r file 
do
    mdate=`stat -c %y "$1/$file" | cut -d' ' -f 1 | sed 's/-//'`
    dstfile="$1/${mdate}.txt"

    if [[ -L `dirname "$file"` ]]
    then
        continue
    fi
    dokuwikipath=`echo "$file" |tr '[:upper:]' '[:lower:]' |sed s'/ /_/'g |sed 's/\//:/'`

    if grep "$dokuwikipath" "$dstfile" 2>/dev/null 1>/dev/null
    then
        echo $SCRIPTNAME: "$dstfile" \<= "$file" OK 
    else
        echo "{{:snote:$dokuwikipath}}" >>"$dstfile"
        echo $SCRIPTNAME: "$dstfile" \<= "$file" NEW 
    fi
done < <(find "$1" -type l -iname '*.png' -printf '%P\0' )
