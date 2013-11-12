#!/bin/bash
while IFS= read -d $'\0' -r file 
do
    filename=`basename "$file"`
    normalised=`echo "$filename" |tr '[:upper:]' '[:lower:]' |sed s'/ /_/'g`
    dirname=$1/`dirname "$file"`
    echo filename=$filename
    echo dirname=$dirname
    cd "$dirname"
    ln -sf "$filename" "$normalised"
done < <(find "$1" -iname "$2" -printf '%P\0' )
