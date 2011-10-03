#!/bin/bash

# Read Config File
source include/config
cols=`tput cols`
lines=`tput lines`

# If Config has not beed edited, then exit.
if [[ -z $bukkitdir ]]; then
	echo "Plese Edit include/config"
	exit 0
else
	# If screen size too small, adjust. 
	if [[ $cols -lt 120 || $lines -lt 40 ]]; then
		printf '\033[8;40;120t'
		sleep 0.5 
	fi
	# Start the screen sessions.
	screen -c include/screen.conf
fi
