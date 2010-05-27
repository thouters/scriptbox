#!/bin/bash
# Das agile status
VERSION=0.4

PRIMCMD="review"
DONE="0"
if [ $# -gt 0 ] && [ $1 = review ]
then
    rt edit $2 set CF.{agile}="Review"
    let "DONE += 1"
fi

PRIMCMD="$PRIMCMD|comment"
if [ $# -gt 0 ] && [ $1 = comment ]
then
    rt edit $2 set CF.{agile}="Comment"
    let "DONE += 1"
fi

PRIMCMD="$PRIMCMD|done"
if [ $# -gt 0 ] && [ $1 = done ]
then
    rt edit $2 set CF.{agile}="Done"
    let "DONE += 1"
fi

PRIMCMD="$PRIMCMD|reject"
if [ $# -gt 0 ] && [ $1 = reject ]
then
    rt edit $2 set status="rejected"
    let "DONE += 1"
fi

PRIMCMD="$PRIMCMD|accept"
if [ $# -gt 0 ] && [ $1 = accept ]
then
    rt edit $2 set CF.{agile}="Accepted"
    let "DONE += 1"
fi

PRIMCMD="$PRIMCMD|suggest"
if [ $# -gt 0 ] && [ $1 = suggest ]
then
    rt edit $2 set CF.{agile}="Suggestion"
    let "DONE += 1"
fi

PRIMCMD="$PRIMCMD|progress"
if [ $# -gt 0 ] && [ $1 = progress ]
then
    rt edit $2 set CF.{agile}="Progress"
    let "DONE += 1"
fi


TICKCMD="branch"
if [ $# -gt 0 ] && [ $1 = branch ]
then
   TITLE=`rt show $2 -f Subject|grep Subject|cut -d' ' -f2- |sed s/\ /-/g`
   NR=`echo $2|sed s/\ //g`
   TITLE=$NR-$TITLE
   OUT=`git branch -l |grep $TITLE`
   if [ -z $OUT ] 
   then
       git checkout -b $TITLE 
   else
       git checkout $TITLE
   fi
    let "DONE += 1"
fi

TICKCMD="$TICKCMD|show"
if [ $# -gt 0 ] && [ $1 = show ]
then
    rt $@
    let "DONE += 1"
fi

QCMD="create"
if [ $# -gt 0 ] && [ $1 = create ]
then
    rt create -e -t ticket set queue="$2" CF.{agile}="Suggestion"
    let "DONE += 1"
fi

QCMD="$QCMD|show"
if [ $# -gt 0 ] && [ $1 = ls ]
then
    rt list -o CF.{agile} "Queue='$2' AND 'CF.{agile}' NOT LIKE 'Done' AND Status !='rejected'" -f ticket,CF.{agile},subject|awk '{{FS="\t"}printf "%-5s%-20s%-40s\n", $1, $3, $2}'
    let "DONE += 1"
fi

QCMD="$QCMD|show"
if [ $# -gt 0 ] && [ $1 = todo ]
then
    rt list -o CF.{agile} "Queue='$2' AND ('CF.{agile}' LIKE 'Accepted' OR 'CF.{agile}' LIKE 'Progress' OR 'CF.{agile}' LIKE 'Review') AND Status !='rejected'" -f ticket,CF.{agile},subject|awk '{{FS="\t"}printf "%-5s%-20s%-40s\n", $1, $3, $2}'
    let "DONE += 1"
fi

QCMD="$QCMD|untagged"
if [ $# -gt 0 ] && [ $1 = untagged ]
then
    rt ls "Queue='$1' AND 'CF.{agile}' NOT LIKE 'Done' AND 'CF.{agile}' NOT LIKE 'Waiting for review' AND 'CF.{agile}' NOT LIKE 'Accepted' AND 'CF.{agile}' NOT LIKE 'Suggestion' AND Status !='rejected' AND Status !='resolved'" -i
    let "DONE += 1"
fi

if [ $# -lt 1 ] || [ $1 = help ] || [ $DONE -lt 1 ]
then
    cat <<EOF
Das agile script version $VERSION
Usage:
    Setting ticket status:
        [$PRIMCMD] ticketid
    Operations with tickets:
        [$TICKCMD] ticketid
    Operations on queues:
        [$QCMD] queuename
EOF
fi

