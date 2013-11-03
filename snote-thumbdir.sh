#!/bin/bash
find "$1" -iname '*.snb' -exec `dirname $0`/snote-thumb.sh "{}" \;
find "$1" -iname '*.snb' -exec `dirname $0`/snote-snbopen.sh "{}" \;
