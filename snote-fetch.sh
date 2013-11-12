#!/bin/bash
#snote-fetch.sh tabula.vpn:/sdcard/S\\\ Note/ /home/thomas/S\ Note 
if [ $# -lt 2 ]
then
    echo usage: $0 remote-device-url local-path
    exit 0
fi
REMOTEDIR="$1"
LOCALDIR="$2"
if rsync -vra "$REMOTEDIR"  "$LOCALDIR"/
then
    find "$LOCALDIR" -iname '*.snb' -exec `dirname $0`/snote-snbopen.sh "{}" \;
    find "$LOCALDIR" -iname '*.pdf' -exec `dirname $0`/pdf2png-timestamped.sh "{}" \;
    make-lowercase-symlinks.sh "$LOCALDIR" -type f -iname '*.png'
    make-lowercase-symlinks.sh "$LOCALDIR" -type d 
    snote-mkindex.sh "$LOCALDIR"
fi
