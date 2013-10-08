#!/bin/bash

OU=$(pacman -Quq)
OU=${OU:0:1}
OU=${OU//[abcdefghijklmnopqrstuvwxyz]/1}

echo "$OU" > test
#if [[ "$OU" -eq "b" ]]
#then
#	echo "1" > test
#else
#	echo "0" > test
#fi

