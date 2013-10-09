#!/bin/bash

OU=$(pacman -Quq)
OU=${OU:0:1}
OU=${OU//[abcdefghijklmnopqrstuvwxyz]/1}

echo "$OU" > /tmp/conky_pacman_state
