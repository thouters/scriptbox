#!/bin/bash

IN="`cat`"
if [[ ! -z "$IN" ]]
then
    echo "$IN"|$@
fi
