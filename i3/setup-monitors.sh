#!/bin/bash

DIR=$(dirname $0)
#OUT=$(lsusb -d 413c:2513 2>&1)
#
#echo $OUT
#
#notify-send -u normal "$OUT"

lsusb -d 413c:2513 2>&1 > /tmp/debug && $DIR/setup_docked.sh || $DIR/setup_undocked.sh
