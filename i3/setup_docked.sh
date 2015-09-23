#!/bin/bash

DIR=$(dirname $0)
cp $DIR/config-docked $DIR/config
xrandr --output eDP1 --auto --output DP1 --mode 3360x1050 --right-of eDP1 && cat $HOME/.fehbg | bash
i3-msg restart

