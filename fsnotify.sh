#!/bin/bash

DIR=$1
INDEX=$2
shift 
shift

mkdir -p `dirname $INDEX`
NEWIDX=`mktemp $INDEX.indexXXXXX`
CF=`mktemp $INDEX.createdXXXXX`
DF=`mktemp $INDEX.deletedXXXXX`
DIFF=`mktemp $INDEX.diffXXXXX`
REPORT=`mktemp $INDEX.reportXXXXX`

find $DIR 2&>/dev/null >$NEWIDX

if [ ! -f $INDEX ]
then
    echo subject: indexed $DIR
    echo Created initial index....
    cat $NEWIDX>$INDEX
else
    diff $INDEX $NEWIDX>$DIFF
    if [ `wc -l <$DIFF` -gt 0 ]
    then
        SUBJ=""
        PLEN=`echo $DIR|wc -m`
        PLEN=`echo $PLEN + 1|bc`

        grep \> <$DIFF|cut -d" " -f2-|cut -c$PLEN- >$CF
        NC=`wc -l < $CF`
#        NC=`echo $NC - 1|bc`
        
        grep \< <$DIFF|cut -d" " -f2-|cut -c$PLEN->$DF
        ND=`wc -l<$DF`
#        ND=`echo $ND - 1|bc`
        
        echo changes to $DIR: >$REPORT
        
        if [ $NC -gt 0 ]
        then
            echo "New files ($NC):" >>$REPORT
            sed s/\^/\ \ \ \ / <$CF >> $REPORT
        fi
        
        if [ $ND -gt 0 ]
        then
            echo "Deleted files ($ND):" >>$REPORT
            sed s/\^/\ \ \ \ / <$DF >> $REPORT
        fi
        
        if [ $NC -gt 1 ]; then
            SUBJ="$SUBJ $NC new files "
        elif [ $NC -gt 0 ]; then
            C=`cat $CF`
            SUBJ="$SUBJ new file: $C "
        fi

        if [ $ND -gt 1 ]; then
            SUBJ="$SUBJ $ND deleted files "
        elif [ $ND -gt 0 ]; then
            D=`cat $DF`
            SUBJ="$SUBJ deleted file: $D "
        fi
        
        echo subject: [fsnotify `basename $DIR`] $SUBJ
        echo
        cat $REPORT
        cat $NEWIDX>$INDEX
    fi
fi

rm $NEWIDX $DIFF $REPORT $CF $DF
