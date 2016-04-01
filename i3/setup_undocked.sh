#!/bin/bash

DIR=$(dirname $0)
cp $DIR/config-base $DIR/config
cat $DIR/config-undocked >> $DIR/config
cat $DIR/config-tail >> $DIR/config
(xrandr --output eDP1 --auto --output DP1 --mode 1680x1050 --right-of eDP1 || xrandr --output eDP1 --auto --output DP1 --off) && cat $HOME/.fehbg | bash
i3-msg restart
