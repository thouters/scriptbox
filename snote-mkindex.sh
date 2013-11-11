#!/bin/bash
while IFS= read -d $'\0' -r file 
do
    mdate=`stat -c %y "$1/$file" | cut -d' ' -f 1`
    dstfile="$1/${mdate}.txt"
    if grep "$file" "$dstfile" 2>/dev/null 1>/dev/null
    then
        echo "$file" found in "$dstfile"
    else
        echo added "$file" to "$dstfile"
        echo "[[$file]]" >>"$dstfile"
    fi
done < <(find "$1" -iname '*.png' -printf '%P\0' )
