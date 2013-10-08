#!/usr/bin/bash

echo password | sudo -S pacman -Sy --logfile /tmp/conky_pacman.log > /dev/null

