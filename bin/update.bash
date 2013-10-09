#!/usr/bin/bash

echo $PASSWORD | sudo -S pacman -Sy --logfile /tmp/conky_pacman.log > /dev/null

